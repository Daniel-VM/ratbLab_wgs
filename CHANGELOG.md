# nf-core/ratbLab_wgs: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0dev - [date]

Initial release of Daniel-VM/ratbLab_wgs, created with the [nf-core](https://nf-co.re/) template.

### `Added`

In this first implementation I have included:

    - Sample input check modules
    - NGS preprocessing subworkflow 
    - Contamination screen with Mash
    - De novo genome assembly with Unicycler plus extra modules to check assemblies quality
    - worfklow configuration parameters
    - Main readme plus other documentation

### `Fixed`

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `trimmomatic`    | -     | 0.39      |
| `fastqc` | -      | 0.11.9        |
| `unicycler`    | -      | 0.4.8      |
| `quast`    | -      | 5.2.0      |
| `bandage`    | -      | 0.8.1      |
| `mash`    | -      | 2.3      |


### `Deprecated`
