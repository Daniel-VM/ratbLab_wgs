#!/usr/bin/env nextflow
/*
======================================================
    WGS bacteria workflow || ratb-isciii Lab

    git: https://github.com/Daniel-VM/ratbLab_wgs/tree/dev
======================================================
*/

nextflow.enable.dsl = 2

/*
======================================================
    VALIDATE AND PRINT PARAMETERS SUMMARY
======================================================
*/
WorkflowMain.initialise(workflow, params, log)

/*
======================================================
    NAMED WORKFLOW FOR PIPELINE
======================================================
*/

include { WGS_BACTERIA } from './workflows/wgs_bacteria'

//
// WORKFLOW: Run main analysis pipeline
//

workflow RATBLAB_WGS {
    WGS_BACTERIA()
}

/*
======================================================
    RUN ALL WORKFLOWS
======================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
//

workflow {

    RATBLAB_WGS()

}

/*
======================================================
    THE END
======================================================
*/



