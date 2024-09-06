# ONT_16S_Analysis

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.15.1-brightgreen.svg)](https://snakemake.github.io)

This is a work in progress pipeline to process full-length 16s rRNA data from ONT.

## Basecalling
To run the basecalling:
```bash
snakemake --use-conda -c 16 --snakefile workflow/Basecalling.smk -n #remove -n to start the job
```
## Tutorial
### Step 1: Clone the workflow

[Clone](https://help.github.com/en/articles/cloning-a-repository) this repository to your local system, into the place where you want to perform the data analysis. 

    git clone git@github.com:matinnuhamunada/ONT_16S_Analysis.git
    cd ONT_16S_Analysis

### Step 2: Prepare the input data
Structure your raw read data from ONT to look like this:
```shell
data
└── raw
    ├── fastq_pass-20230814T144538Z-001.zip
    ├── fastq_pass
    │   ├── barcode01
    │   │   └── FAW91967_pass_barcode01_a80fe2bd_f92c8855_28.fastq.gz
...
```
### Step 3: Configure workflow
#### Setting Up Your Samples Information
Configure the workflow according to your needs via editing the files in the `config/` folder. Adjust `config.yaml` to configure the workflow execution, and `samples.tsv` to specify the samples for analysis. The file `units.tsv` contains the location of the paired illumina and nanopore reads for each sample.

`samples.tsv` example:

|  sample       |       description |
|--------------:|------------------:|
| barcode01 | Stool |

`units.tsv` example:

|  sample       |  unit |    illumina_reads |               nanopore_reads |
|--------------:|------:|------------------:|-----------------------------:|
| barcode01 | 1     |                   | data/raw/GCF_000012125.1     |

### Step 3: Install Snakemake

Installing Snakemake using [Mamba](https://github.com/mamba-org/mamba) is advised. In case you don’t use [Mambaforge](https://github.com/conda-forge/miniforge#mambaforge) you can always install [Mamba](https://github.com/mamba-org/mamba) into any other Conda-based Python distribution with:

    conda install -n base -c conda-forge mamba

Then install Snakemake with:

    mamba create -c conda-forge -c bioconda -c panoptes-organization -n snakemake snakemake panoptes-ui

For installation details, see the [instructions in the Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

### Step 4: Executing the workflow

Activate the conda environment:

    conda activate snakemake

Run panoptes to monitor jobs:

    tmux new-session -A -s panoptes \; send -t panoptes "conda activate snakemake && panoptes" ENTER \; detach -s panoptes # run panoptes in background at http://127.0.0.1:5000

Do a dry-run:

    snakemake --use-conda --cores $N --wms-monitor http://127.0.0.1:5000 -n

We can then open `http://127.0.0.1:5000` to monitor our jobs
![panoptes](workflow/report/figures/panoptes.png)

See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further snakemake CLI details.

## Data Analysis

Install qiime2:
```bash
mamba env create -n qiime2-amplicon-2024.5 --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py39-linux-conda.yml
```