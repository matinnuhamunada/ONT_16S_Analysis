rule concat_fastq:
    input: 
        fastq=lambda wildcards: NANOPORE[wildcards.sample]
    output:
        temp('data/interim/fastq/nanopore/{sample}.fastq.gz'),
    conda:
        "../envs/emu.yaml"
    log:
        "logs/fastq/nanopore/{sample}_concat.log"
    shell:
        """
        cat {input.fastq}/*.fastq.gz > {output} 2>> {log}
        """

rule emu_database:
    output: 
        db="resources/database/{tax_db}"
    conda:
        "../envs/emu.yaml"
    log:
        "logs/emu/database/{tax_db}.log"
    threads: 4
    shell:
        """
        mkdir -p {output.db} 2>> {log}
        (cd {output.db} && osf -p 56uf7 fetch osfstorage/emu-prebuilt/{wildcards.tax_db}.tar && tar -xvf {wildcards.tax_db}.tar) 2>> {log}
        """

rule emu_abundance:
    input: 
        fastq='data/interim/fastq/nanopore/{sample}.fastq.gz',
        db="resources/database/{tax_db}"
    output:
        table='data/processed/emu/{sample}/{sample}_{tax_db}_rel-abundance.tsv',
        distribution="data/processed/emu/{sample}/{sample}_{tax_db}_read-assignment-distributions.tsv",
        sam="data/processed/emu/{sample}/{sample}_{tax_db}_emu_alignments.sam"
    conda:
        "../envs/emu.yaml"
    log:
        "logs/emu/abundance/{sample}_{tax_db}.log"
    threads: 4
    params:
        type='map-ont'
    shell:
        """
        emu abundance --type {params.type} --db {input.db} --output-dir data/processed/emu/{wildcards.sample} --output-basename {wildcards.sample}_{wildcards.tax_db} --keep-files --keep-counts --keep-read-assignments --output-unclassified --threads {threads} {input.fastq} 2>> {log}
        """