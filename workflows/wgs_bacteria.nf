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

/*
======================================================
    NF-CORE MODULES/SUBWORKFLOWS
======================================================
*/
include { INPUT_CHECK } from '../subworkflows/local/input_check'

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
    .groupTuple()
    .branch {
        meta, fastq ->
            single  : fastq.size() == 1
                return [ meta, fastq.flatten() ]
            multiple: fastq.size() > 1
                return [ meta, fastq.flatten() ]
    }
    .set { ch_fastq }
}