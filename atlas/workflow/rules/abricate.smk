# Maybe try to make a local rule for each database to reduce the amount of environments calls that are required.
# Potentially Collapse it to the individual databases

DBDIR = config["database_dir"]


rule abricate_get_genomes:
    output:


rule abricate_MAG_annotation:
    input:
        fasta="genomes/genomes/{genome}.fasta", 
    output: 
        out="genomes/annotations/abricate/MAGs/{genome}/mag_{database}_{genome}.tab",
    threads: config["threads"]
    resources:
        mem=config["simplejob_mem"],
        time=config["runtime"]["default"],
    conda:
        "../envs/abricate.yaml"
    log:
        "log/abricate/MAGs/{genome}.{database}.MAGs.log", 
    params:
        coverage = config["abricate_coverage"],
        id = config["abricate_id"],   
    benchmark:
        "log/benchmarks/abricate/MAGs/{genome}.{database}.MAGs.tsv"
    shell:
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db {wildcards.database} {input.fasta} >> genomes/annotations/abricate/MAGs/{wildcards.genome}/mag_{wildcards.database}_{wildcards.genome}.tab "
        " ; "
        " cat genomes/annotations/abricate/MAGs/{wildcards.genome}/mag_{wildcards.database}_{wildcards.genome}.tab >> genomes/annotations/abricate/summary_mag_{wildcards.database}.tab " 


rule abricate_bin_annotation:
    input:
        bins = "{sample}/binning/DASTool/bins", #Das tools hardcoded fix later
    output: 
        out="genomes/annotations/abricate/bins/summary_bin_{database}_{sample}.tab",
    threads: config["threads"]
    resources:
        mem=config["simplejob_mem"],
        time=config["runtime"]["default"],
    conda:
        "../envs/abricate.yaml"
    log:
        "log/abricate/bins/{sample}.{database}.log", 
    params:
        coverage = config["abricate_coverage"],
        id = config["abricate_id"], 
    benchmark:
        "log/benchmarks/abricate/bins/{sample}.{database}.tsv"
    shell:
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db {wildcards.database} {input.bins}/* >> genomes/annotations/abricate/bins/summary_bin_{wildcards.database}_{wildcards.sample}.tab "
        " ; "
        " cat genomes/annotations/abricate/bins/summary_bin_{wildcards.database}_{wildcards.sample}.tab >> genomes/annotations/abricate/summary_bin_{wildcards.database}.tab " 


rule abricate_contig_annotation:
    input:
        contigs = "{sample}/{sample}_contigs.fasta",
    output:
        out="genomes/annotations/abricate/{sample}/contig_{database}_{sample}.tab",
    threads: config["threads"]
    resources:
        mem=config["simplejob_mem"],
        time=config["runtime"]["default"],
    conda:
        "../envs/abricate.yaml"
    log:
        "log/abricate/{sample}.{database}.contigs.log", 
    params:
        coverage = config["abricate_coverage"],
        id = config["abricate_id"],   
    benchmark:
        "log/benchmarks/abricate/{sample}.{database}.contigs.tsv"
    shell:
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db {wildcards.database} {input.contigs} >> genomes/annotations/abricate/{wildcards.sample}/contig_{wildcards.database}_{wildcards.sample}.tab " 
        " ; "
        " cat genomes/annotations/abricate/{wildcards.sample}/contig_{wildcards.database}_{wildcards.sample}.tab >> genomes/annotations/abricate/summary_contig_{wildcards.database}.tab "

def get_all_abricate(wildcards): 
    
    all_genomes = get_genomes_(wildcards) # this may have to get changed to the output files. 
    abricate_databases = config["abricatedb"] #maybe
     
    return expand(rules.abricate_MAG_annotation.output.out, genome=all_genomes, database=abricate_databases)


# the below expand rules are incomplete as they do not cover all output files this should change when database wildcards added. 
rule all_abricate:
    input:
        get_all_abricate,
        expand(rules.abricate_bin_annotation.output.out, 
            sample = SAMPLES,
            database=config["abricatedb"],
        ),
        expand(rules.abricate_contig_annotation.output.out,  contigs=expand("{sample}/{sample}_contigs.fasta",
        sample = SAMPLES,
        ),
        sample = SAMPLES,
        database=config["abricatedb"], ),
    output:
        touch(f"finished_abricate"),
    conda:
        "../envs/abricate.yaml"
    shell:
        " abricate --help "
