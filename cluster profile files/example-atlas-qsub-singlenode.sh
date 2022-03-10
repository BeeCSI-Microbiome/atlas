#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 8
#$ -V

# These lines enable Conda and activate the base environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate atlasenv

#add additional snakemake commands as needed for troubleshooting. 
atlas run all --jobs 16 --latency-wait 600 
