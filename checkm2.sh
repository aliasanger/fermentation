#!/bin/bash
#SBATCH --time=02:30:00
#SBATCH --mem=30G
#SBATCH --cpus-per-task=20
#SBATCH --account=%ACCOUNT%
#SBATCH --job-name=drep
#Run CHECKM2 for future dereplication with dRep (weird workaround since Compute Canada is mean). Just input the collection of MAGs you get from the danaseq pipeline (Requires Apptainer)

set -euo pipefail
set -x
module load apptainer
SIF=/path/to/drep/drep.sif
# Re-bind the CheckM data and any scratch/project paths the job needs

apptainer exec \
 --bind /path/to/databases/checkm2_db/ \
 --bind /path/to/directory/fastq_33/danaseq/dastool_bins/checkm2_output \
 --bind /path/to/directory/fastq_33/danaseq/dastool_bins \
 ${SIF} \
 checkm2 predict \
 --threads 20 \
 --input /path/to/directory/fastq_33/danaseq/dastool_bins/*.fa \
 --output-directory /path/to/directory/fastq_33/danaseq/dastool_bins/checkm2_output \
 --database_path //path/to/databases/checkm2_db/CheckM2_database/uniref100.KO.1.dmnd \
 --force
