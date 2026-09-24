#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4
#SBATCH --account=%ACCOUNT HERE%
#SBATCH --job-name=generate_depth_files
#SBATCH --array=1-8

set -euo pipefail
module load metabat
module load samtools
module load bamtools

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /path/to/directory/samplenames.txt)
BAM_DIR=/path/to/directory/fastq_33/MEGAHIT_assembly/BAM_files_minimap2${sample}

echo "[INFO] Generating depth file from renamed BAMs..."

jgi_summarize_bam_contig_depths \
  --outputDepth "${BAM_DIR}/depths.txt" \
  "${BAM_DIR}/${sample}.sorted.bam"

echo "[INFO] Depth file written: ${BAM_DIR}/depths.txt"
