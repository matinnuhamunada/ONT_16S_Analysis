import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version
from pathlib import Path
import yaml

min_version("7.32.3")

##### load config and sample sheets #####

configfile: "config/config.yaml"
#validate(config, schema="../schemas/config.schema.yaml")

# set up sample
samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
samples.index.names = ["sample_id"]
#validate(samples, schema="../schemas/samples.schema.yaml")

# set up units
units = pd.read_table(config["units"], dtype=str).set_index(
    ["sample"], drop=False
)
#validate(units, schema="../schemas/units.schema.yaml")

##### Wildcard constraints #####
wildcard_constraints:
    sample="|".join(samples.index),
    unit="|".join(units["unit"]),

##### Helper functions #####

SAMPLES = samples['sample'].to_list()
TAX_DB = [config["EMU_PREBUILT_DB"]]
ILLUMINA = {k: v for (k,v) in units.illumina_reads.to_dict().items()}
NANOPORE = {k: v for (k,v) in units.nanopore_reads.to_dict().items()}
NANOPORE_FAST5 = {k: v for (k,v) in units.nanopore_fast5.to_dict().items()}