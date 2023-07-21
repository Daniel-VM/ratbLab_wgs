# WGS BACTERIAL ASSEMBLY

Bacterial assembly workflow following the RATB/ISCIII lab practices.

# Documentation

See the [documentation](docs/) for a more detailed information of the workflow usage, paramers and output files.

# Structure 

The ratbLab_wgs workflow has been implemented in Nextflow DSL2.


# Steps

1. Input sample check
2. Concatenate FastQ samples
3. Addapter trimming [Trimmomatic](https://github.com/usadellab/Trimmomatic) and quality check [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) of short-reads
4. Screen for contamnants with [Mash](https://github.com/marbl/Mash)
5. Genomme assembly (*de novo*):
    
    5.1 Genome assembly of short-reads [UNICYCLER](https://github.com/rrwick/Unicycler)
    
    5.2 Quality check of assemblies with [QUAST](https://github.com/ablab/quast)
    
    5.3 Visualization of *de novo* assemblies with [Bandage](https://rrwick.github.io/Bandage/)
6. Workflow statistics with [MultiQC](https://github.com/ewels/MultiQC)

