DBDIR = config["database_dir"]

# <!> It may be better to use Abricates internal file handler instead. See what the Examples look like. 

rule abricate_get_genomes:
    output:

rule abricate_annotation:
    input:
        fasta="genomes/genomes/{genome}.fasta", # name genome is
        # id = config["abricate_id"], # this breaks can I just put these in resources or somewhere else? 
        # coverage = config["abricate_coverage"], # this breaks
    output: # There is a better way to do this...
        out="genomes/annotations/abricate/{genome}/ncbi_{genome}.tab",
        outRes="genomes/annotations/abricate/{genome}/resfinder_{genome}.tab",
        outPlas="genomes/annotations/abricate/{genome}/plasmidfinder_{genome}.tab",
        outMega="genomes/annotations/abricate/{genome}/megares_{genome}.tab",
        outEcoh="genomes/annotations/abricate/{genome}/ecoh_{genome}.tab",
        outVfdb="genomes/annotations/abricate/{genome}/vfdb_{genome}.tab",
        outEcoV="genomes/annotations/abricate/{genome}/ecoli_vf_{genome}.tab",
        outArga="genomes/annotations/abricate/{genome}/argannot_{genome}.tab",
        outCard="genomes/annotations/abricate/{genome}/card_{genome}.tab",
    threads: config["threads"]
    resources:
        mem=config["simplejob_mem"],
        time=config["runtime"]["default"],
    conda:
        "../envs/abricate.yaml"
    log:
        "log/abricate/{genome}.log", 
    params:
        coverage = config["abricate_coverage"],
        id = config["abricate_id"],   
    benchmark:
        "log/benchmarks/abricate/{genome}.tsv"
    shell:
        # add <A> when I figure out how to fix the config issues.  
        # <A> " abricate --summary --minid{input.id} --mincov{input.coverage} --threads {threads} --db resfinder {input.fasta} > {output.outdir}/resfinder.results.tab "        
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db resfinder {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/resfinder_{wildcards.genome}.tab >> genomes/annotations/abricate/resfinder_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db plasmidfinder {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/plasmidfinder_{wildcards.genome}.tab >> genomes/annotations/abricate/plasmidfinder_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db megares {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/megares_{wildcards.genome}.tab >> genomes/annotations/abricate/megares_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db ecoh {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/ecoh_{wildcards.genome}.tab >> genomes/annotations/abricate/ecoh_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db vfdb {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/vfdb_{wildcards.genome}.tab >> genomes/annotations/abricate/vfdb_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db ecoli_vf {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/ecoli_vf_{wildcards.genome}.tab >> genomes/annotations/abricate/ecoli_vf_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db ncbi {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/ncbi_{wildcards.genome}.tab >> genomes/annotations/abricate/ncbi_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db argannot {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/argannot_{wildcards.genome}.tab >> genomes/annotations/abricate/argannot_summary.tab" 
        " ; "
        " abricate --minid {params.id} --mincov {params.coverage} --threads {threads} --quiet --db card {input.fasta} >> genomes/annotations/abricate/{wildcards.genome}/card_{wildcards.genome}.tab >> genomes/annotations/abricate/card_summary.tab" 


def get_all_abricate(wildcards): 
    
    all_genomes = get_genomes_(wildcards) # this may have to get changed to the output files. 
    
    # below is probably a bad idea but it works temporarily. May change when have to deal w/ database wild cards. 
    return expand(rules.abricate_annotation.output.out, genome=all_genomes)



rule all_abricate:
    input:
        get_all_abricate,
    output:
        touch(f"finished_abricate"),
    conda:
        "../envs/abricate.yaml"
    shell:
        " abricate --help "