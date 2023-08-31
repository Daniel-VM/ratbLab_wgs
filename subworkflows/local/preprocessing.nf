//
// NGS preprocessing using Trimmomatic & FastQC
// 

// Import local modules
include { FASTQC as FASTQC_RAW      } from '../../modules/nf-core/fastqc/main'
include { TRIMMOMATIC               } from '../../modules/nf-core/trimmomatic/main'
include { FASTQC as FASTQC_ONTRIM   } from '../../modules/nf-core/fastqc/main'

// RUN MAIN SUBWORKFLOW
workflow TRIMMOMMATIC_FASTQC {
    take:
    ch_fastq

    main:
    ch_versions = Channel.empty()
    ch_multiqc  = Channel.empty()

    // MODULE: FASTQC
    FASTQC_RAW(
        ch_fastq    
    )

    // MODULE: TRIMMOMATIC
    TRIMMOMATIC(
        ch_fastq
    )
    ch_versions         = ch_versions.mix(TRIMMOMATIC.out.versions.first())
    ch_trimmed_reads    = TRIMMOMATIC.out.trimmed_reads
    ch_multiqc          = ch_multiqc.mix( TRIMMOMATIC.out.log ).collect{it[1]}.ifEmpty([])

    // MODULE: FASTQC OF TRIMMED READS
    FASTQC_ONTRIM(
        ch_trimmed_reads    
    )
    ch_versions         = ch_versions.mix(FASTQC_ONTRIM.out.versions.first())
    ch_multiqc          = ch_multiqc.mix( FASTQC_ONTRIM.out.zip ).collect{it[1]}.ifEmpty([])

    emit:
    multiqc_files   = ch_multiqc
    trimmed_reads   = ch_trimmed_reads  // channel: [ val(meta), path(reads) ]
    versions        = ch_versions       // channel: [ path(versions.yml) ]
}