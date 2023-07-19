#!/usr/bin/env nextflow
/*
======================================================
    WGS Bacteria || ratb-isciii Lab
======================================================
*/

// -- TODO: Log info
// -- TODO: Schema parsing
// -- TODO: Help man page
// -- TODO: Validate input
// -- TODO: Check mandatory params
if (!params.readsPath && !params.input) { exit 1, "No input file o path provided. Pleas use '--input sampleSheet.csv' or '--inputDir /pathTo/*_R{1,2}.fastq.gz'"}
if (params.inputPath) { ch_pairs = Channel.fromFilePairs( params.inputPath, checkIfExists: true ) }
if (params.input)     { ch_input = file( params.input, checkIfExists: true ) }

// -- TODO: Check accesory params

/*
======================================================
    LOCAL MODULES/SUBWORKFLOWS
======================================================
*/
include { TRIMMOMMATIC_FASTQC   } from '../subworkflows/local/preprocessing'
include { GENOME_ASSEMBLY       } from '../subworkflows/local/genomeassembly'
include { REPORT_MASH_SCREEN    } from '../modules/local/report_mash_screen'
/*
======================================================
    NF-CORE MODULES/SUBWORKFLOWS
======================================================
*/
include { INPUT_CHECK           } from '../subworkflows/local/input_check'
include { CAT_FASTQ             } from '../modules/nf-core/cat/fastq/main'
include { MASH_SCREEN           } from '../modules/nf-core/mash/screen/main'               

/*
======================================================
    RUN MAIN WORKFLOW
======================================================
*/

workflow WGS_BACTERIA {
    ch_versions = Channel.empty()

    //
    // SUBWORKFLOW: Read samplesheet, validate and stage input files
    //
    // -- FIXME: Seems that insead of appearing reads in the multiple branch, they appear into the single branch. Why?. 
    INPUT_CHECK (
        ch_input
    )
    .reads
    .map {
        meta, fastq ->
            new_id = meta.id - ~/_T\d+/
            [ meta + [id: new_id], fastq ]
    }
    .branch {
        meta, fastq ->
            single  : fastq.size() == 1
                return [ meta, fastq.flatten() ]
            multiple: fastq.size() > 1
                return [ meta, fastq.flatten() ]
    }
    .set { ch_fastq }

    //
    // MODULE: Concatenate FastQ files from same sample if required
    //
    CAT_FASTQ (
        ch_fastq.multiple
    )
    .reads
    .mix(ch_fastq.single)
    .set { ch_cat_fastq }
    
    ch_versions = ch_versions.mix(CAT_FASTQ.out.versions.first().ifEmpty(null))

    // SUBWORKFLOW: QC AND PREPROCESSING
    TRIMMOMMATIC_FASTQC(
        ch_cat_fastq
    )
    .trimmed_reads
    .set { ch_trimmed_reads }

    ch_versions = ch_versions.mix(TRIMMOMMATIC_FASTQC.out.versions)

    // MODULE: SCREEN FOR CONAMINANTS
    // TODO: replace MASH_SCREEN with CUSTMO_MASH_SCREEN (add ratb lablog steps)
    // TODO: collect this output and passit to ratb's py script
    MASH_SCREEN ( 
        ch_trimmed_reads.transpose(),
        params.mash_screen_db
    )
    ch_versions = ch_versions.mix(MASH_SCREEN.out.versions)
    
    REPORT_MASH_SCREEN(
        MASH_SCREEN.out.screen.collect{ it[1] }
    )
    ch_versions = ch_versions.mix(REPORT_MASH_SCREEN.out.versions)

    // SUBWORKFLOW: GENOME ASSEMBLY
    GENOME_ASSEMBLY(
        ch_trimmed_reads.map{ meta, fastq -> [meta, fastq, []] },
        null, // ch_fasta,
        null, // ch_gff
    )

    // MODULE: VERSION CONTROL
}