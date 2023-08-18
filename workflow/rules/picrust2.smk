rule convert_biom:
    input:
        distribution="data/processed/emu/{sample}/{sample}_{tax_db}_read-assignment-distributions.tsv"
    output:
        biom="data/interim/picrust2/{sample}/{sample}_{tax_db}.biom"
    log: "logs/picrust2/convert_biom/{sample}_{tax_db}.log"
    run:
        table = pd.read_csv(input.distribution, index_col=0, sep="\t")
        table.index.name='#OTU ID'
        table.fillna(0).to_csv(output.biom, sep="\t")

rule convert_sam:
    input:
        sam="data/processed/emu/{sample}/{sample}_{tax_db}_emu_alignments.sam"
    output:
        fasta="data/interim/picrust2/{sample}/{sample}_{tax_db}.fna"
    log: "logs/picrust2/convert_sam/{sample}_{tax_db}.log"
    conda: "../envs/picrust2.yaml"
    shell:
        """
        samtools fasta {input.sam} > {output.fasta} 2>> {log}
        """

rule picrust2_pipeline:
    input:
        fasta="data/interim/picrust2/{sample}/{sample}_{tax_db}.fna",
        biom="data/interim/picrust2/{sample}/{sample}_{tax_db}.biom"
    output:
        metagenome=directory("data/interim/picrust2/{sample}/{sample}_{tax_db}_metagenome_out")
    log: "logs/picrust2/picrust2_pipeline/{sample}_{tax_db}.log"
    conda: "../envs/picrust2.yaml"
    threads: 24
    shell:
        """
        picrust2_pipeline.py -s {input.fasta} -i {input.biom} -o {output.metagenome} --processes {threads} --verbose &>> {log}
        """