#!/usr/bin/env python3
import subprocess
import os
import sys

# Get sample name from environment (set in SLURM script)
sample = os.environ.get("sample")

# Define output directory
outdir = "/path/to/directory/fastq_33/MEGAHIT_assembly/TNFs"
input_fasta = f"/path/to/directory/fastq_33/MEGAHIT_assembly/{sample}-contigsdir/{sample}-renamedcontigs.fa"
os.makedirs(outdir, exist_ok=True)

if not sample:
    sys.exit("ERROR: 'sample' environment variable not set.")

subprocess.run(["checkm", "tetra", input_fasta, f"{outdir}/{sample}_tnf.tsv"], check=True)
