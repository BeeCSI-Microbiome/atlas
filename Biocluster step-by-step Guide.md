# Atlas Step-By-Step Guide On Biocluster

## Disclaimer
The following instructions are intended solely for Agriculture and Agri-Food Canada employees and collaborators that are using the biocluster.

## Installing Atlas 
1. Make sure you have **conda** installed. If not see the biocluster guide on how to do that. 
2. Follow Atlas' [Installation Guide](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#getting-started) as of [2022-03-10], the guide is approximately the following...
- In your terminal enter: 
```bash
conda create -y -n atlasenv metagenome-atlas
```
- Note: You can also clone either ours or Atlas' main repo via github as an alternative if there is a problem with the above version.
- Additionally, if you are having problems with the main Branch of ATLAS, our version often has minor "bug" fixes and workarounds as required.  


## Initialize Your Atlas Directory
1. Navigate to or make a new directory where all of your Atlas results and files will be stored. 
2. In your terminal enter:
```bash
atlas init --db-dir databases {path/to/fastq_files}
```
- Note: By default you will initialize a new database folder in your working directory, you can change this or re-use an old database by substituting "`databases`" in the above command for the path the alternative database. 


## Set Up Your Databases
- As of [2022-03-10] several of the Atlas databases are not downloading correctly due to deadlinks. To save time, space, and headaches we recommend following the procedure below. 
1. Navigate to your database folder specified in the initialization step (if you left this as "`databases`" it will be in your Atlas projects working directory).
2. Create a symbolic link to the EggNog database by entering the following:  
```bash
ln -s /isilon/common/reference/databases/EggNOG_V5/EggNOG_V5/ EggNOG_V5
```
3. Create a symbolic link to the GTDB database by entering the following:  
```bash
ln -s /isilon/common/reference/databases/gtdb/release202/ GTDB_V06
```
4. Copy the most recent DRAM config file to the database folder:  
```bash
cp /isilon/common/reference/databases/DRAM_db/DRAM_db_20220415/DRAM_db_20220415_without_uniref.conf DRAM.config
```


## Modify Your `config.yaml` File 
1. Please review the `config.yaml` file in your Atlas directory and double check that all of the parameters are correct.
2. A common change is the addition of contaminant/host genomes, the `config.yaml` file specifies how to do this around line 61 if you require instructions.


## Configure Atlas for Cluster Execution
1. Please review [Atlas Cluster Configuration](https://metagenome-atlas.readthedocs.io/en/latest/usage/getting_started.html#set-up-of-cluster-execution)
2. General Steps for running on Biocluster...
- Enter in Terminal:  
```bash
cookiecutter --output-dir ~/.config/snakemake https://github.com/metagenome-atlas/clusterprofile.git
```
- Enter in Terminal:  
```bash
cd /home/AAFC-AAC/{$USER}/.config/snakemake/cluster
```
- Copy, make, or overwrite the **`key_mapping.yaml, sge-jobscript.sh, sge-status.py, sge-submit.py, cluster.yaml, cluster_config.yaml, and config.yaml`** files from [here](https://github.com/BeeCSI-Microbiome/atlas/tree/master/cluster%20profile%20files) to the directory you have just navigated to. If you want to download these files from the above mentioned location, you can enter the following lines into your terminal:
```bash
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/key_mapping.yaml
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/sge-jobscript.sh
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/sge-status.py
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/sge-submit.py
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/cluster.yaml
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/cluster_config.yaml
wget https://raw.githubusercontent.com/BeeCSI-Microbiome/atlas/master/cluster%20profile%20files/config.yaml
```


## Running Atlas on a single node
- Please submit a `qsub` script (see below) or start a qlogin job. See biocluster for more information. 
1. Activate atlas by entering the following in the terminal:
```bash
conda activate atlasenv
```
2. Run all jobs by entering the following from your Atlas working directory:  
```bash
atlas run all --jobs {# of threads, 2x the number of cores}
```


## Example "qsub" Scripts
[Single Node](https://github.com/BeeCSI-Microbiome/atlas/blob/master/cluster%20profile%20files/example-atlas-qsub-singlenode.sh) 

[Cluster Submission](https://github.com/BeeCSI-Microbiome/atlas/blob/master/cluster%20profile%20files/example-atlas-qsub-cluster.sh)
