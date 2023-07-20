//
// GENOME ASSEMBLY
//
/*
========================================================================================
   VALIDATE INPUTS
========================================================================================
*/

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/
include { UNICYCLER                     } from '../../modules/nf-core/unicycler/main'
include { GUNZIP as GUNZIP_SCAFFOLDS    } from '../../modules/nf-core/gunzip/main'
include { GUNZIP as GUNZIP_GFA          } from '../../modules/nf-core/gunzip/main'
include { QUAST                         } from '../../modules/nf-core/quast/main'
include { BANDAGE_IMAGE                 } from '../../modules/nf-core/bandage/image/main'
//include { BAKTA                         } from '../../modules/nf-core/bakta/main'
//include { PROKKA                        } from '../../modules/nf-core/prokka/main'


/*
========================================================================================
    RUN  SUBWORKFLOW
========================================================================================
*/
workflow GENOME_ASSEMBLY{
    take:
    reads       // channel : [ val(meta), [reads], [] ] 
    fasta       // channel : [ fasta ]
    gff         // channel : [ gff ] 

    main:
    ch_versions = Channel.empty()
    ch_multiqc  = Channel.empty()

    //
    // MODULE: Genome Assembly
    //
    UNICYCLER ( reads )
    ch_versions = ch_versions.mix(UNICYCLER.out.versions)

    //
    // GUNZIP scaffolds and GFA file
    //
    GUNZIP_SCAFFOLDS (
        UNICYCLER.out.scaffolds
    )
    GUNZIP_SCAFFOLDS
        .out
        .gunzip
        .filter { meta, scaffold -> scaffold.size() > 0 }
        .set { ch_scaffolds }

    GUNZIP_GFA (
        UNICYCLER.out.gfa
    )
    GUNZIP_GFA
        .out
        .gunzip
        .filter { meta, gfa -> gfa.size() > 0 }
        .set { ch_gfa }
    ch_versions = ch_versions.mix(GUNZIP_SCAFFOLDS.out.versions.first())
    ch_versions = ch_versions.mix(GUNZIP_GFA.out.versions.first())
    
    // MODULE: QUALITY ASSESSMENT OF GENOME ASSEMBLIES
    QUAST ( 
        ch_scaffolds.collect{ it[1] },
        [],
        [],
        false,
        false
    )
    ch_multiqc  = ch_multiqc.mix(QUAST.output.tsv)
    ch_versions = ch_versions.mix(QUAST.out.versions.first())

    // MODULE: Visualization of assemblies with Bandage
    ch_bandage_png = Channel.empty()
    ch_bandage_svg = Channel.empty()
    if (!params.skip_bandage) {
        BANDAGE_IMAGE (
            ch_gfa
        )
        ch_bandage_png = BANDAGE_IMAGE.out.png
        ch_bandage_svg = BANDAGE_IMAGE.out.svg
        ch_versions    = ch_versions.mix(BANDAGE_IMAGE.out.versions.first())
    }
/*
    // Module: Genome annotation
// <!-- SPSP TODO: if prodigal is provided, then params.proteins is required. Otherwise it will break-->
    if (!params.skip_annotation && params.annotation_tool == 'bakta'){
        BAKTA (
            ch_scaffolds.map{ meta, scaffolds -> [meta, [scaffolds]] },
            params.baktadb,
            [],
            []
        )
        ch_versions = ch_versions.mix(BAKTA.out.versions)
    } else if (!params.skip_annotation && params.annotation_tool == 'prokka'){
        PROKKA (
            ch_scaffolds.map{ meta, scaffolds -> [meta, [scaffolds]] },
            ch_proteins,
            ch_prodigal
        )
        ch_versions = ch_versions.mix(PROKKA.out.versions)
    }
*/
    emit:
    scaffolds       = ch_scaffolds                      // channel: [ val(meta), [ scaffolds ] ]
    gfa             = ch_gfa                            // channel: [ val(meta), [ gfa ] ]

    quast_results   = QUAST.out.results                 // channel: [ val(meta), [ results ] ]
    quast_tsv       = QUAST.out.tsv                     // channel: [ val(meta), [ tsv ] ]

    bandage_png     = ch_bandage_png                    // channel: [ val(meta), [ png ] ]
    bandage_svg     = ch_bandage_svg                    // channel: [ val(meta), [ svg ] ]

    versions        = ch_versions                       // channel: [ versions.yml ]
    multiqc_files   = ch_multiqc                        // channel: [ multiqc_files ]
}