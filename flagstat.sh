#!/bin/bash
#SBATCH --account=%ACCOUNT%
#SBATCH --job-name=bam_stats
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=01:00:00
#SBATCH --array=1-8

set -euo pipefail
set -x

cd /path/to/directory
#Set sample_list to loop through
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samplenames.txt)


module load StdEnv/2023
module load samtools

BAM="/path/to/directory/BAM_files_minimap2/${sample}/${sample}.sorted.bam"

outfile="/path/to/directory/BAM_files_minimap2/${sample}/${sample}_flagstat.txt"

echo "Full flagstat:" > $outfile
samtools flagstat $BAM >> $outfile

echo "" >> $outfile
echo "Mapped reads:" >> $outfile
samtools view -c -F 4 $BAM >> $outfile

echo "" >> $outfile
echo "Total reads:" >> $outfile
samtools view -c $BAM >> $outfile
