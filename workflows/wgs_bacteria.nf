#!/usr/bin/env nextflow
/*
======================================================
    WGS Bacteria || ratb-isciii Lab
======================================================
*/
def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

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
    CONFIG FILES
======================================================
*/
ch_multiqc_config           = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config    = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()
workflow_summary            = WorkflowratbLab_wgs.paramsSummaryMultiqc(workflow, summary_params)
ch_workflow_summary         = Channel.value(workflow_summary)


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
include { INPUT_CHECK                   } from '../subworkflows/local/input_check'
include { CAT_FASTQ                     } from '../modules/nf-core/cat/fastq/main'
include { MASH_SCREEN                   } from '../modules/nf-core/mash/screen/main'        
include { CUSTOM_DUMPSOFTWAREVERSIONS   } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { MULTIQC                       } from '../modules/nf-core/multiqc/main'

/*
======================================================
    RUN MAIN WORKFLOW
======================================================
*/

workflow WGS_BACTERIA {
    ch_versions         = Channel.empty()
    ch_multiqc_files    = Channel.empty()

    //
    // SUBWORKFLOW: Read samplesheet, validate and stage input files
    //
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

/*
    // MODULE: SCREEN FOR CONAMINANTS
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
*/
    // MODULE: JOIN QC METRICS
    ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(TRIMMOMMATIC_FASTQC.out.multiqc_files)

//    ch_multiqc_files = ch_multiqc_files.mix(GENOME_ASSEMBLY.out.multiqc_files)
//    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())

    MULTIQC(
        ch_multiqc_files.collect()
    )

    // MODULE: Unify program versions
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
        )
}