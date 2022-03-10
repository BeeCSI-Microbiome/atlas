# Metagenome-Atlas

[![Version](https://anaconda.org/bioconda/metagenome-atlas/badges/version.svg)](https://anaconda.org/bioconda/metagenome-atlas)
[![Bioconda](https://img.shields.io/conda/dn/bioconda/metagenome-atlas.svg?label=Bioconda )](https://anaconda.org/bioconda/metagenome-atlas)
[![Documentation Status](https://readthedocs.org/projects/metagenome-atlas/badge/?version=latest)](https://metagenome-atlas.readthedocs.io/en/latest/?badge=latest)
[![Gitter](https://badges.gitter.im/metagenome-atlas/community.svg)](https://gitter.im/metagenome-atlas/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![follow on twitter](https://img.shields.io/twitter/follow/SilasKieser.svg?style=social&label=Follow)](https://twitter.com/search?f=tweets&q=%40SilasKieser%20%23metagenomeAtlas&src=typd)


Metagenome-atlas is a easy-to-use metagenomic pipeline based on snakemake. It handles all steps from QC, Assembly, Binning, to Annotation.

![scheme of workflow](resources/images/atlas_list.png?raw=true)

You can start using atlas with three commands:
```
    conda install -y -c bioconda -c conda-forge metagenome-atlas
    atlas init --db-dir databases path/to/fastq/files
    atlas run all
```

# Webpage

[metagenome-atlas.github.io](https://metagenome-atlas.github.io/)

# Documentation

https://metagenome-atlas.readthedocs.io/

[Tutorial](https://github.com/metagenome-atlas/Tutorial)

# Citation

> ATLAS: a Snakemake workflow for assembly, annotation, and genomic binning of metagenome sequence data.  
> Kieser, S., Brown, J., Zdobnov, E. M., Trajkovski, M. & McCue, L. A.   
> BMC Bioinformatics 21, 257 (2020).  
> doi: [10.1186/s12859-020-03585-4](https://doi.org/10.1186/s12859-020-03585-4)


# Development/Extensions

Here are some ideas I work or want to work on when I have time. If you want to contribute or have some ideas let me know via a feature request issue.

- Optimized MAG recovery (e.g. [Spacegraphcats](https://github.com/spacegraphcats/spacegraphcats))
- Integration of viruses/plasmid that live for now as [extensions](https://github.com/metagenome-atlas/virome_atlas)
- Add statistics and visualisations as in [atlas_analyze](https://github.com/metagenome-atlas/atlas_analyze)
- Implementation of most rules as snakemake wrapper
- Cloud execution
- Update to new Snakemake version and use cool reports.

# Biocluster Specific Instructions - *(Detailed Instructions [Here](https://github.com/BeeCSI-Microbiome/atlas/blob/master/Biocluster%20step-by-step%20Guide.md))*

1) ### Please review installing conda on biolcuster if you have not already install conda.
 
2) ### Follow Atlas' main page for installation procedures [Installation Guide](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#getting-started)

3) ### After Atlas is installed please initialize a directory [Initialization Guide](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#start-a-new-project)

4) ### Set up your Databases
    - create a symbolic link in your Atlas database directory for "GTDB_V06" and "EggNOG_V5"
    - databases can be found at /isilon/reference-databases/databases/
    - example code (if in your Atlas working directory) "ln -s /isilon/reference-databases/gtdb/release202    databases/GTDB_V06"

5) ### Modify your config file
    - Add in any host / filter genomes to the config file path.
    - Add in any additional modifications for extensions (see the abricate extension for more details).

6) ### Cluster Configuration
    - Please start by adding Atlas' cluster configuration steps  [Cluster Guide](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#set-up-of-cluster-execution)
    - After that you can copy the provided files from "cluster profile files" into the ~/.config/snakemake/cluster (where "cluster" = what you called your cluster profile).

# Abricate Extension
    - You can find the abricate extension and relatedc files on the "atlas_abricate_extension" branch. 
    - Currently the abricate "extension" requires using the additionally provided config file in "modified config files" else it will not work.
    - Currently the abricate extension runs all databases this is intended to be changed using the config file in the future. 
    - The addition of the abricate.yaml, abricate.smk, the modified config file, and the changes to the Snakefile are all that is required to use this extension. So it can be easily added to a current Atlas (2.8.1) pipeline as of 2022-03-07. 
