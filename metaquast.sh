#!/bin/bash
#SBATCH --account=%ACCOUNT%
#SBATCH --job-name=metaquast
#SBATCH --cpus-per-task=60
#SBATCH --mem=30G
#SBATCH --time=04:00:00
#SBATCH --array=1-8

#Set sample_list to loop through
cd /path/to/directory
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samplenames.txt)
echo "Running sample: $sample"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $(hostname)"
date

module load StdEnv/2020 gcc/9.3.0 python/3.9
module load quast/5.2.0

metaquast.py /path/to/directory/fastq_33/MEGAHIT_assembly/${sample}-contigsdir/${sample}-renamedcontigs.fa \
    -o  /path/to/directory/fastq_33/MEGAHIT_assembly/${sample}-contigsdir
    -t 60
