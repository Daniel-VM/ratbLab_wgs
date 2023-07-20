//
// NGS preprocessing using Trimmomatic & FastQC
// 

// Import local modules
include { TRIMMOMATIC } from '../../modules/nf-core/trimmomatic/main'
include { FASTQC      } from '../../modules/nf-core/fastqc/main'

// RUN MAIN SUBWORKFLOW
workflow TRIMMOMMATIC_FASTQC {
    take:
    ch_fastq

    main:
    ch_versions = Channel.empty()
    ch_multiqc  = Channel.empty()

    // MODULE: TRIMMOMATIC
    TRIMMOMATIC(
        ch_fastq
    )
    ch_versions         = ch_versions.mix(TRIMMOMATIC.out.versions.first())
    ch_trimmed_reads    = TRIMMOMATIC.out.trimmed_reads
    ch_multiqc          = ch_multiqc.mix( TRIMMOMATIC.out.log ).collect{it[1]}.ifEmpty([])

    // MODULE: FASTQC
    FASTQC(
        ch_trimmed_reads    
    )
    ch_versions         = ch_versions.mix(FASTQC.out.versions.first())
    ch_multiqc          = ch_multiqc.mix( FASTQC.out.zip ).collect{it[1]}.ifEmpty([])

    emit:
    multiqc_files   = ch_multiqc
    trimmed_reads   = ch_trimmed_reads  // channel: [ val(meta), path(reads) ]
    versions        = ch_versions       // channel: [ path(versions.yml) ]
}