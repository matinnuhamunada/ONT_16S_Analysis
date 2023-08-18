include: "rules/common.smk"

##### Target rules #####
rule all:
    input:
        expand("data/interim/reads/{sample}", sample=SAMPLES)

##### Modules #####
include: "rules/guppy.smk"
