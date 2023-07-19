# ratbLab_wgs: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

* [Trimmomatic](#trimmomatic) - Adapter trimming
* [FastQC](#fastqc) - trimmed read QC
* [Mash](#mash) - screen contamnation
* [Unicycler](#unicycler) - de novo assembly
* [Quast](#quast) - quality control of de novo assembly
* [Bandage](#bandage) - Visualization of *de novo* assemblies
* [MultiQC](#multiqc) - Aggregate report describing results and QC from the whole pipeline
* [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### Trimmomatic

<details markdown="1">
<summary>Output files</summary>

* `processing/trimmomatic`
    * `*{paired,unpaired}.trim_{1,2}.fastq.gz*`: Trimmed reads.
    * `*.summary`: Summary of adapter trimming.

[Trimmomatic](https://github.com/usadellab/Trimmomatic) is a software tool commonly used in bioinformatics and genomics research for quality control and preprocessing of high-throughput sequencing data, particularly from Next-Generation Sequencing (NGS) technologies. It helps to remove adapter sequences, low-quality reads, and other artifacts from raw sequencing data, resulting in cleaner and more reliable data for downstream analysis.
</details>

### FastQC

<details markdown="1">
<summary>Output files</summary>

* `processing/fastqc/`
    * `*_fastqc.html`: FastQC report containing quality metrics.
    * `*_fastqc.zip`: Zip archive containing the FastQC report, tab-delimited data file and plot images.

</details>

[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) gives general quality metrics about your sequenced reads. It provides information about the quality score distribution across your reads, per base sequence content (%A/T/G/C), adapter contamination and overrepresented sequences. For further reading and documentation see the [FastQC help pages](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/).

![MultiQC - FastQC sequence counts plot](images/mqc_fastqc_counts.png)

![MultiQC - FastQC mean quality scores plot](images/mqc_fastqc_quality.png)

![MultiQC - FastQC adapter content plot](images/mqc_fastqc_adapter.png)

> **NB:** The FastQC plots displayed in the MultiQC report shows _untrimmed_ reads. They may contain adapter sequence and potentially regions with low quality.


### Mash

<details markdown="1">
<summary>Output files</summary>

* `contamination_screen/screen`
    * `*.trim_{1,2}.screen`: Mash screen output. 

[Mash](https://github.com/marbl/Mash) is a bioinformatics tool used for fast genome and metagenome distance estimation. It calculates pairwise distances between genomic sequences or metagenomic samples based on their k-mer content. Mash is commonly used to identify relatedness between genomes, classify strains, detect contamination, and perform large-scale genomic comparisons. It is known for its speed and scalability, making it useful for analyzing large datasets in a time-efficient manner.

</details>

### Unicycler

<details markdown="1">
<summary>Output files</summary>

* `assembly/unicycler`
    * `*.scafolds.fa.gz`: Genome *de novo* assemblies
    * `*.assembly.gfa.gz`: 
    * `*.unicycler.log` : Assembly logs

[Unicycler](https://github.com/rrwick/Unicycler) is a bioinformatics tool used for hybrid assembly of bacterial genomes. It combines the strengths of both de novo assembly and read mapping approaches to generate high-quality, complete genome assemblies from Illumina short reads and long-read sequencing technologies such as Oxford Nanopore or PacBio. Unicycler employs a multi-step process that involves initial assembly, read mapping, error correction, and polishing to generate a single circularized contig representing the complete genome. It is widely used in bacterial genomics research to obtain accurate and comprehensive genome assemblies.

</details>

### Quast

<details markdown="1">
<summary>Output files</summary>

* `assembly/unicycler/quast`
    * `*.`: 

[QUAST](https://github.com/ablab/quast) is a bioinformatics tool used for quality assessment of genome assemblies. It stands for "Quality Assessment Tool for Genome Assemblies" and is commonly used to evaluate the completeness, accuracy, and overall quality of assembled genomes. Quast compares the assembly to a reference genome (if available) or generates various statistics and metrics to assess factors such as assembly size, contiguity, misassemblies, gene annotation, and coverage. It provides a comprehensive analysis of genome assemblies and helps researchers assess the quality and reliability of their genomic data.

</details>

### Bandage

<details markdown="1">
<summary>Output files</summary>

* `assembly/unicycler/bandage`
    * `*.{png,svg}`: Banage image to visualize genome assemblies

[Bandage](https://rrwick.github.io/Bandage/) is a bioinformatics visualization tool used for the exploration and analysis of genome assembly graphs. It is designed specifically for visualizing and manipulating large-scale assembly graphs generated from de novo assembly methods, such as those produced by long-read sequencing technologies like PacBio or Oxford Nanopore. Bandage allows users to visualize and navigate through the complex connections and relationships within the assembly graph, aiding in the identification of structural variations, repetitive regions, and potential assembly errors. It is a valuable tool for gaining insights into the structure and organization of genomes.

</details>

### MultiQC

<details markdown="1">
<summary>Output files</summary>

* `multiqc/`
    * `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
    * `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
    * `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

[MultiQC](http://multiqc.info) is a visualization tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in the report data directory.

Results generated by MultiQC collate pipeline QC from supported tools e.g. FastQC. The pipeline has special steps which also allow the software versions to be reported in the MultiQC output for future traceability. For more information about how to use MultiQC reports, see <http://multiqc.info>.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

* `pipeline_info/`
    * Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
    * Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
    * Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
