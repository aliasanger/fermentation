#!/bin/bash
#SBATCH --account=%ACCOUNT%
#SBATCH --job-name=minimap2
#SBATCH --cpus-per-task=16
#SBATCH --mem=50G
#SBATCH --time=04:00:00
#SBATCH --array=1-8 

module load StdEnv/2023
module load minimap2
module load samtools
module load metabat

cd /path/to/directory
#Set sample_list to loop through
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samplenames.txt)


assembly_dir="/path/to/directory/fastq_33/MEGAHIT_assembly/${sample}-contigsdir"
reads_dir="/path/to/directory/fastq_33"  
outdir="/path/to/directory/fastq_33/MEGAHIT_assembly/BAM_files_minimap2/${sample}"

mkdir -p "$outdir"

echo "Running sample: $sample"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $(hostname)"
date

# Map paired-end reads to FASTA, filter unmapped, sort, and save BAM
minimap2 \
    -ax sr \
    -t $SLURM_CPUS_PER_TASK \
    ${assembly_dir}/${sample}-renamedcontigs.fa \
    ${reads_dir}/${sample}_R1_001.fastq.gz ${reads_dir}/${sample}_R2_001.fastq.gz | \
samtools view -b -F 4 | \
samtools sort -@ $SLURM_CPUS_PER_TASK -o ${outdir}/${sample}.sorted.bam

echo "Mapping complete. Indexing BAM..."

# Index BAM
samtools index ${outdir}/${sample}.sorted.bam

echo "Done!"
date
