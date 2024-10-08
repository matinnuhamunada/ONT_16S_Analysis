

rule emu_database:
    output: 
        db=directory("resources/database/{tax_db}")
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
        fastq='data/interim/qc/{sample}/nanopore/min1kb.fq',
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

rule emu_copy_table:
    input: 
        table='data/processed/emu/{sample}/{sample}_{tax_db}_rel-abundance.tsv'
    output:
        table=temp('data/processed/emu/{sample}_{tax_db}_rel-abundance.tsv')
    shell:
        """
        cp {input.table} {output.table}
        """

rule emu_compile:
    input: 
        table=expand('data/processed/emu/{sample}_{tax_db}_rel-abundance.tsv', sample=SAMPLES, tax_db=TAX_DB),
    output:
        table='data/processed/emu/emu-combined-{rank}.tsv',
    conda:
        "../envs/emu.yaml"
    log:
        "logs/emu/abundance/compile-{rank}.log"
    threads: 4
    shell:
        """
        echo {wildcards.rank} 
        emu combine-outputs data/processed/emu {wildcards.rank} 2>> {log}
        """