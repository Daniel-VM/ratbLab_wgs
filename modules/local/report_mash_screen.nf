process REPORT_MASH_SCREEN {
    label 'process_single'

    conda (params.enable_conda ? 'conda-forge::pandas=1.5.2' : null )
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/pandas:1.5.2' :
    'biocontainers/pandas:1.5.2--cbb54fcf8730' }"

    input:
    path (screen), stageAs: "screen_dir/"

    output:
    path    "contamination.report"      , emit: report
    path    "contamination_report.log"  , emit: log  
    path    "versions.yml"              , emit: versions

    script:
    """
    contamination_report_mash.py --input screen_dir --output contamination.report > contamination_report.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | awk '{print \$2}')
    END_VERSIONS
    """
}