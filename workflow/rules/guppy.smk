if config["guppy"]["GPU_basecalling"]:
    guppy_type = "ont-guppy"
    gpu_params = "--device cuda:0"
else:
    guppy_type = "ont-guppy-cpu"
    gpu_params = ""

if config["guppy"]["config"] is not None:
    basecalling_config = f'--config {config["guppy"]["config"]}'
else:
    basecalling_config = f'--flowcell {config["guppy"]["flowcell"]} --kit {config["guppy"]["kit"]}'

rule download_guppy:
    output: directory(f"resources/{guppy_type}")
    params:
        guppy_version = "6.5.7", 
        guppy_type = guppy_type
    log: f"logs/guppy/download_{guppy_type}.log"
    shell: 
        """
        tar_file="{params.guppy_type}_{params.guppy_version}_linux64.tar.gz"
        wget -P resources/ https://cdn.oxfordnanoportal.com/software/analysis/$tar_file -nc 2>> {log}
        tar -xzvf resources/$tar_file -C resources/ &>> {log}
        """

rule guppy_basecalling:
    input:
        guppy = f"resources/{guppy_type}",
        fast5 = lambda wildcards: NANOPORE_FAST5[wildcards.sample]
    output: directory("data/interim/reads/{sample}")
    params:
        config = basecalling_config,
        gpu_params = gpu_params
    shell:
        """
        {input.guppy}/bin/guppy_basecaller --input_path {input.fast5} --save_path {output} \
            {params.gpu_params} --do_read_splitting --compress_fastq {params.config}
        """