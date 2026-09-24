#!/bin/bash
#SBATCH --job-name=MegaHIT_assembly
#SBATCH --time=8:00:00
#SBATCH --mem=96G
#SBATCH --cpus-per-task=64
#SBATCH --account=%ACCOUNT%
#SBATCH --array=1-8

cd /path/to/directory
set -euo pipefail
set -x

#Set sample_list to loop through
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samplenames.txt)

# Create output folder for logs
logdir="./fastq_33/megahit_assembly_logs"
mkdir -p "$logdir"
exec > "$logdir/${sample}_${SLURM_JOB_ID}.out"
exec 2> "$logdir/${sample}_${SLURM_JOB_ID}.err"

echo "Running sample: $sample"
echo "Job ID: $SLURM_JOB_ID"
echo "Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $(hostname)"
date

# Run MEGAHIT with non-interleaved paired-end reads
module load StdEnv/2020
module load megahit
# -m 0.99: memory,  max memory in byte to be used in SdBG construction (if set between 0-1, fraction of the machine's total memory) [0.9]; Sam had at 0.99
# mem flag SdBG builder memory mode. 0: minimum; 1: moderate; others: use all memory specified by '-m/--memory' [1]
megahit \
    -1 ./fastq_33/${sample}_R1_001.fastq.gz \
    -2 ./fastq_33/${sample}_R2_001.fastq.gz \
    -t $SLURM_CPUS_PER_TASK \
    -m 0.99 \
    --mem-flag 0 \
    -o ./fastq_33/MEGAHIT_assembly/${sample}

echo "Assembly complete for $sample"
date

