rule clean_nanopore:
    input: 
        lambda wildcards: NANOPORE[wildcards.strains]
    output:
        temp('data/interim/qc/{strains}/nanopore/porechop.fq'),
    conda:
        "../envs/utilities.yaml"
    threads: 4
    log:
       "logs/qc/{strains}/clean_nanopore-{strains}.log"
    shell:
        """
        porechop -t {threads} -i {input} -o {output} &>> {log}
        """

rule filter_length:
    input: 
        'data/interim/qc/{strains}/nanopore/porechop.fq',
    output:
        'data/interim/qc/{strains}/nanopore/min1kb.fq'
    conda:
        "../envs/utilities.yaml"
    log:
        "logs/qc/{strains}/filter_length-{strains}.log"
    params:
        min_length = 1000,
        keep_percent = 95
    shell:
        """
        filtlong --min_length {params.min_length} --keep_percent {params.keep_percent} {input} > {output} 2>> {log}
        """
