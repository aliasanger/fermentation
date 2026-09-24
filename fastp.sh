#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=96G
#SBATCH --cpus-per-task=16
#SBATCH --account=%ACCOUNT%
#SBATCH --job-name=merged_fastq_1_fastq_33
#SBATCH --array=1-8   # update to number of samples
module load StdEnv/2020
module load fastp

cd /path/to/directory

#Some flags to stop the whole pipeline if an error occurs
set -euo pipefail
set -x
threads=$SLURM_CPUS_PER_TASK
#Set sample_list to loop through
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samplenames.txt)
logdir="./fastq_logs"
mkdir -p "$logdir"
exec > "$logdir/fastp_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${sample}.out"
exec 2> "$logdir/fastp_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${sample}.err"

#Making all the directories we will use
mkdir -p ./fastq_33/readcounts/ #creates folder if it doesnt exist
readcount_log=./fastq_33/readcounts/${sample}_readcounts.txt

# Define file paths
current_R1=./${sample}_R1_001.fastq.gz
current_R2=./${sample}_R2_001.fastq.gz

tmp_R1=./fastq_33/${sample}_tmp_R1_001.fastq.gz
tmp_R2=./fastq_33/${sample}_tmp_R2_001.fastq.gz

# Log read counts BEFORE fastp
echo "=== Read counts BEFORE fastp ===" >> $readcount_log
echo "before,$(zcat $current_R1 | wc -l | awk '{print $1/4}'),$(zcat $current_R2 | wc -l | awk '{print $1/4}')" >> $readcount_log

fastp \
    -i $current_R1 \
    -o $tmp_R1 \
    -I $current_R2 \
    -O $tmp_R2 \
    --low_complexity_filter \
    --overrepresentation_analysis \
    --trim_poly_g --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    --trim_poly_x \
    --cut_right --cut_right_window_size 5 --cut_right_mean_quality 15 \
    --qualified_quality_phred 33 \
    --length_required 50 \
    --html ./fastq_33/${sample}_fastplog.html -R "NAME_OF_FILE" \
    --json ./fastq_33/${sample}_fastplog.json \
    --thread $SLURM_CPUS_PER_TASK

mv $tmp_R1 ./fastq_33/${sample}_R1_001.fastq.gz
mv $tmp_R2 ./fastq_33/${sample}_R2_001.fastq.gz

# Log read counts AFTER fastp
echo "=== Read counts AFTER fastp ===" >> $readcount_log
echo "after,$(zcat $current_R1 | wc -l | awk '{print $1/4}'),$(zcat $current_R2 | wc -l | awk '{print $1/4}')" >> $readcount_log
