rule get_nanoclust_db:
    output:
        db=directory("resources/nanoclust/16S_ribosomal_RNA"),
        tax=directory("resources/nanoclust/db/taxdb"),
    log:
        "logs/nanoclust/nanoclust_download_db.log"
    shell:
        """
        mkdir -p {output.tax}
        mkdir -p {output.db}
        (wget https://ftp.ncbi.nlm.nih.gov/blast/db/16S_ribosomal_RNA.tar.gz && tar -xzvf 16S_ribosomal_RNA.tar.gz -C {output.db}) &>> {log}
        (wget https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz && tar -xzvf taxdb.tar.gz -C {output.tax}) &>> {log}
        """

rule get_nanoclust:
    output:
        dir=directory("resources/nanoclust/NanoCLUST")
    log:
        "logs/nanoclust/get_nanoclust.log"
    shell:
        """
        (cd resources/nanoclust && git clone https://github.com/genomicsITER/NanoCLUST.git) 2>> {log}
        """

rule nanoclust:
    input:
        reads='data/interim/qc/{sample}/nanopore/min1kb.fq',
        db="resources/nanoclust/16S_ribosomal_RNA",
        tax="resources/nanoclust/db/taxdb",
        dir="resources/nanoclust/NanoCLUST"
    output:
        directory("data/processed/nanoclust/{sample}"),
    log:
        "logs/nanoclust/nanoclust_{sample}.log"
    params:
        pipeline="resources/nanoclust/NanoCLUST/main.nf",
        profile="docker",
    conda:
        "../envs/nextflow.yaml"
    handover: True
    shell:
        """
        nextflow run {params.pipeline} -profile {params.profile} --reads {input.reads} --db {input.db} --tax {input.tax} --outdir {output} &>> {log}
        """
