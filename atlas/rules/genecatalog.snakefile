import os

localrules: concat_genes
rule concat_genes:
    input:
        faa= expand("{sample}/annotation/predicted_genes/{sample}.faa", sample=SAMPLES),
        fna= expand("{sample}/annotation/predicted_genes/{sample}.fna", sample=SAMPLES)
    output:
        faa=temp("Genecatalog/all_predicted_genes.faa"),
        fna = "Genecatalog/all_predicted_genes_unfiltered.fna",
    params:
        min_length=100
    shell:
        " cat {input.faa} >  {output.faa} ;"
        " cat {input.fna} > {output.fna}"


rule filter_genes:
    input:
        temp("Genecatalog/all_predicted_genes_unfiltered.fna")
    output:
        all_genes= temp("Genecatalog/all_predicted_genes.fna"),
        lhist= "Genecatalog/stats/length_hist.txt"
    log:
        "log/Genecatalog/filter_genes.fasta"
    conda:
        "%s/required_packages.yaml" % CONDAENV
    threads:
        config.get("threads", 1)
    resources:
        mem = config.get("java_mem", JAVA_MEM),
        java_mem = int(config.get("java_mem", JAVA_MEM) * JAVA_MEM_FRACTION)
    params:
        min_length=100
    shell:
        " reformat.sh "
        " in={input}"
        " minlength={params.min_length} "
        " lhist={output.lhist} "
        " ow=t out={output.all_genes} "
        " 2> {log} "

# localrules: remove_asterix
# rule remove_asterix:
#     input:
#         "{file}_with_asterix.faa",
#     output:
#         temp("{file}.faa")
#     run:
#         with open(input[0]) as f, open(output[0],'w') as fo:
#             for line in f:
#                 fo.write(line.replace('*',''))
#


rule cluster_proteins:
    input:
        faa= "Genecatalog/all_predicted_genes.faa"
    output:
        tmpdir= temp(directory(os.path.join(config['tmpdir'],"mmseqs"))),
        db=temp("Genecatalog/all_predicted_genes.db"),
        clusterdb = "Genecatalog/clustering/protein_clusters.db",
    conda:
        "%s/mmseqs.yaml" % CONDAENV
    log:
        "logs/Genecatalog/clustering/cluster_proteins.log"
    threads:
        config.get("threads", 1)
    shell:
        """
            mmseqs createdb {input.faa} {output.db} 2> {log}

            mmseqs cluster --threads {threads} {output.db} {output.clusterdb} {output.tmpdir} 2> {log}
        """


rule get_rep_proteins:
    input:
        db=temp("Genecatalog/all_predicted_genes.db"),
        clusterdb = "Genecatalog/clustering/protein_clusters.db",
    output:
        cluster_attribution = temp("Genecatalog/genes2proteins_oldnames.tsv"),
        rep_seqs_db = temp("Genecatalog/protein_catalog.db"),
        rep_seqs = temp("Genecatalog/protein_catalog_oldnames.faa")
    conda:
        "%s/mmseqs.yaml" % CONDAENV
    log:
        "logs/Genecatalog/clustering/get_rep_proteins.log"
    threads:
        config.get("threads", 1)
    shell:
        """
        mmseqs createtsv {input.db} {input.db} {input.clusterdb} {output.cluster_attribution} 2> {log}

        mmseqs result2repseq {input.db} {input.clusterdb} {output.rep_seqs_db} 2>> {log}
        mmseqs result2flat {input.db} {input.db} {output.rep_seqs_db} {output.rep_seqs} 2>> {log}

        """

def gen_names_for_range(N,prefix='',start=1):
    n_leading_zeros= len(str(N))
    format_int=prefix+'{:0'+str(n_leading_zeros)+'d}'
    return [format_int.format(i) for i in range(start,N+start)]
localrules: rename_protein_catalog
rule rename_protein_catalog:
    input:
        cluster_attribution = "Genecatalog/genes2proteins_oldnames.tsv",
        rep_seqs = "Genecatalog/protein_catalog_oldnames.faa"
    output:
        cluster_attribution = "Genecatalog/genes2proteins.tsv",
        rep_seqs = "Genecatalog/protein_catalog.faa"
    run:
        import pandas as pd
        gene2proteins= pd.read_table(input.cluster_attribution,index_col=0, header=None)
        Ngenes= gene2proteins.shape[0]

        gene2proteins['new_name'] = gen_names_for_range(Ngenes,'geneproduct')
        gene2proteins['new_name'].to_csv(output.cluster_attribution,sep='\t',header=False)

        map_names = dict(zip(gene2proteins[1],gene2proteins['new_name']))

        with open(output.rep_seqs,'w') as fout:
            with open(input.rep_seqs) as fin :
                for line in fin:
                    if line[0]=='>':
                        fout.write(">{new_name}\n".format(new_name=map_names[line[1:].strip()]))
                    else:
                        fout.write(line)


rule cluster_catalog:
    input:
        rules.concat_genes.output # change
    output:
        "Genecatalog/Genecatalog.fna",
        "Genecatalog/Genecatalog.clstr"
    conda:
        "%s/cd-hit.yaml" % CONDAENV
    log:
        "logs/Genecatalog/cluster_genes.log"
    threads:
        config.get("threads", 1)
    resources:
        mem=20
    params:
        prefix= lambda wc,output: os.path.splitext(output[0])[0],
        coverage=0.9,
        identity=0.95
    shell:
        """
            cd-hit-est -i {input} -T {threads} \
            -M {resources.mem}000 -o {params.prefix} \
            -c {params.identity} -n 9  -d 0 \
            -aS {params.coverage} -aL {params.coverage} &> >(tee {log})
            mv {params.prefix} {output[0]}
        """



# generalized rule so that reads from any "sample" can be aligned to contigs from "sample_contigs"
rule align_reads_to_Genecatalog:
    input:
        unpack(get_quality_controlled_reads),
        fasta = "Genecatalog/Genecatalog.fna",
    output:
        sam = temp("Genecatalog/alignments/{sample}.sam")
    params:
        input = lambda wc, input : input_params_for_bbwrap(wc, input),
        maxsites = 2,
        ambiguous = 'all',
        min_id = 0.95,
        maxindel = 1 # default 16000 good for genome deletions but not necessarily for alignment to contigs
    shadow:
        "shallow"
    log:
        "logs/Genecatalog/alignment/{sample}_map.log"
    conda:
        "%s/required_packages.yaml" % CONDAENV
    threads:
        config.get("threads", 1)
    resources:
        mem = config.get("java_mem", JAVA_MEM),
        java_mem = int(config.get("java_mem", JAVA_MEM) * JAVA_MEM_FRACTION)
    shell:
        """
        bbwrap.sh nodisk=t \
            local=t \
            ref={input.fasta} \
            {params.input} \
            trimreaddescriptions=t \
            outm={output.sam} \
            threads={threads} \
            minid={params.min_id} \
            mdtag=t \
            xstag=fs \
            nmtag=t \
            sam=1.3 \
            local=t \
            ambiguous={params.ambiguous} \
            secondary=t \
            saa=f \
            maxsites={params.maxsites} \
            -Xmx{resources.java_mem}G \
            2> {log}
        """


rule pileup_Genecatalog:
    input:
        sam = "Genecatalog/alignments/{sample}.sam",
        bam = "Genecatalog/alignments/{sample}.bam"
    output:
        covstats = temp("Genecatalog/alignments/{sample}_coverage.tsv"),
        basecov = temp("Genecatalog/alignments/{sample}_base_coverage.txt.gz"),
    params:
        pileup_secondary = 't' # a read maay map to different genes
    log:
        "logs/Genecatalog/alignment/{sample}_pileup.log"
    conda:
        "%s/required_packages.yaml" % CONDAENV
    threads:
        config.get("threads", 1)
    resources:
        mem = config.get("java_mem", JAVA_MEM),
        java_mem = int(config.get("java_mem", JAVA_MEM) * JAVA_MEM_FRACTION)
    shell:
        """pileup.sh in={input.sam} \
               threads={threads} \
               -Xmx{resources.java_mem}G \
               covstats={output.covstats} \
               basecov={output.basecov} \
               secondary={params.pileup_secondary} \
                2> {log}
        """

localrules: combine_gene_coverages
rule combine_gene_coverages:
    input:
        covstats = expand("Genecatalog/alignments/{sample}_coverage.tsv",
            sample=SAMPLES)
    output:
        "Genecatalog/counts/median_coverage.tsv",
        "Genecatalog/counts/Nmapped_reads.tsv",
    run:

        import pandas as pd
        import os

        combined_cov={}
        combined_N_reads={}
        for cov_file in input:

            sample= os.path.split(cov_file)[-1].split('_')[0]
            data= pd.read_table(cov_file,index_col=0)
            data.loc[data.Median_fold<0,'Median_fold']=0
            combined_cov[sample]= data.Median_fold
            combined_N_reads[sample] = data.Plus_reads+data.Minus_reads

        pd.DataFrame(combined_cov).to_csv(output[0],sep='\t')
        pd.DataFrame(combined_N_reads).to_csv(output[1],sep='\t')



localrules: get_Genecatalog_annotations
rule get_Genecatalog_annotations:
    input:
        Genecatalog= 'Genecatalog/Genecatalog.fna',
        eggNOG= expand('{sample}/annotation/eggNOG.tsv',sample=SAMPLES),
        refseq= expand('{sample}/annotation/refseq/{sample}_tax_assignments.tsv',sample=SAMPLES),
        scg= expand("Genecatalog/annotation/single_copy_genes_{domain}.tsv",domain=['bacteria','archaea'])
    output:
        annotations= "Genecatalog/annotations.tsv",
    run:
        import pandas as pd

        gene_ids=[]
        with open(input.Genecatalog) as fasta_file:
            for line in fasta_file:
                if line[0]=='>':
                    gene_ids.append(line[1:].strip().split()[0])

        eggNOG=pd.DataFrame()
        for annotation_file in input.eggNOG:
            eggNOG=eggNOG.append(pd.read_table(annotation_file, index_col=0))

        refseq=pd.DataFrame()
        for annotation_file in input.refseq:
            refseq=refseq.append(pd.read_table(annotation_file, index_col=1))

        scg=pd.DataFrame()
        for annotation_file in input.scg:
            d= pd.read_table(annotation_file, index_col=0,header=None)
            d.columns = 'scg_'+ os.path.splitext(annotation_file)[0].split('_')[-1] # bacteria or archaea
            scg=scg.append(d)


        annotations= refseq.join(eggNOG).join(scg).loc[gene_ids]
        annotations.to_csv(output.annotations,sep='\t')


rule predict_single_copy_genes:
    input:
        "Genecatalog/Genecatalog.fna"
    output:
        "Genecatalog/annotation/single_copy_genes_{domain}.tsv",
    params:
        script_dir = os.path.dirname(os.path.abspath(workflow.snakefile)),
        key = lambda wc: wc.domain[:3] #bac for bacteria, #archaea
    conda:
        "%s/DASTool.yaml" % CONDAENV # needs pearl
    threads:
        config['threads']
    shell:
        " DIR=$(dirname $(which DAS_Tool)) "
        ";"
        " {params.script_dir}/rules/scg_blank_diamond.rb diamond"
        " {input} "
        " $DIR\/db/{params.key}.all.faa "
        " $DIR\/db/{params.key}.scg.faa "
        " $DIR\/db/{params.key}.scg.lookup "
        " {threads} "
        " &> >(tee {log}) "
        " mv {input[0]}.{wildcards.domain}.scg > {output}"




#
# ############## Canopy clustering
#
# rule reformat_for_canopy:
#         input:
#             "mapresults/Genecatalog_CE/combined_Nmaped_reads.tsv"
#         output:
#             "mapresults/Genecatalog_CE/nseq.tsv"
#         run:
#             import pandas as pd
#
#             D= pd.read_table(input[0], index_col=0)
#             D.index= D.index.map(lambda s: s.split()[0])
#             D=D.astype(int)
#             D.to_csv(output[0],sep='\t',header=False)
#
#
# rule canopy_clustering:
#     input:
#         rules.reformat_for_canopy.output
#     output:
#         cluster="mapresults/Genecatalog_CE/canopy_cluster.tsv",
#         profile="mapresults/Genecatalog_CE/cluster_profiles.tsv",
#     params:
#         canopy_params=config.get("canopy_params","")
#     log:
#         "mapresults/Genecatalog_CE/canopy.log"
#     benchmark:
#         "logs/benchmarks/canopy_clustering.txt"
#     conda:
#         "%s/canopy.yaml" % CONDAENV
#     threads:
#         12
#     resources:
#         mem= 220
#     shell:
#         """
#         canopy -i {input} -o {output.cluster} -c {output.profile} -n {threads} --canopy_size_stats_file {log} {params.canopy_params} 2> >(tee {log})
#
#         """
