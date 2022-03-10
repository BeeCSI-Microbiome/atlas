# Atlas Step-By-Step Guide On Biocluster

## Installing Atlas 
1. Make sure you have **conda** installed. If not see the biocluster guide on how to do that. 
2. Follow Atlas' [Installation Guide](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#getting-started) as of [2022-03-10] the guide is approximately the following...
- In your terminal enter: conda create –y –n atlasenv metagenome-atlas
- Note: You can also clone either ours or Atlas' main repo via github as an alternative if there is a problem with the above version. 


## Initialize Your Atlas Directory
1. Navigate to or make a new directory where all of your Atlas results and files will be stored. 
2. In your terminal enter: atlas init --db-dir databases {path/to/fastq_files}
- Note: By default you will initialize a new database folder in your working directory, you can change this or re-use an old database by substituting "databases" in the above command for the path the alternative database. 


## Set Up Your Databases
- As of [2022-03-10] several of the Atlas databases are not downloading correctly due to deadlinks. To save time, space, and headaches we recommend following the procedure below. 
1. Navigate to your database folder specified in the initialization step (if you left this as "databases" it will be in your Atlas projects working directory).
2. Create a symbolic link to the EggNog database by entering the following: ln -s /isilon/reference-databases/databases/EggNOG_V5/EggNOG_V5/ EggNOG_V5
3. Create a symbolic link to the GTDB database by entering the following: ln -s /isilon/reference-databases/databases/gtdb/release202/ GTDB_V06
4. Copy the most recent DRAM config file to the database folder: cp /isilon/reference-databases/databases/dram_db_21Feb2022/config_dram_db_21Feb2022.txt DRAM.config


## Modify Your Config File 
1. Please review the config file in your Atlas directory and double check that all of the parameters are correct.
2. A common change is the addition of contaminant/host genomes the config file specifies how to do this ~line 61 if you require instruction. 


## Configure Atlas for Cluster Execution
1. Please review [Atlas Cluster Configuration](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#set-up-of-cluster-execution)
2. General Steps for running on Biocluster...
- Enter in Terminal: cookiecutter --output-dir ~/.config/snakemake https://github.com/metagenome-atlas/clusterprofile.git
- Enter in Terminal: cd /home/AAFC-AAC/{$USER}/.config/snakemake/cluster
- Copy, make, or overwrite the **key_mapping.yaml, sge-jobscript.sh, sge-status.py, sge-submit.py, cluster.yaml, cluster_config, and config.yaml** files from [here](https://github.com/BeeCSI-Microbiome/atlas/tree/master/cluster%20profile%20files) to the directory you have just navigated to.


## Running Atlas on a single node
- Please submit a qsub script (see below) or start a qlogin job. See biocluster for more information. 
1. Activate atlas by entering the following in the terminal: conda activate atlasenv
2. Run all jobs by entering the following from your Atlas working directory: atlas run all --jobs {# of threads, 2x the number of cores}


## Example "qsub" Scripts
[Single Node](https://github.com/BeeCSI-Microbiome/atlas/blob/master/cluster%20profile%20files/example-atlas-qsub-singlenode.sh) 
[Cluster Submission](https://github.com/BeeCSI-Microbiome/atlas/blob/master/cluster%20profile%20files/example-atlas-qsub-cluster.sh)
