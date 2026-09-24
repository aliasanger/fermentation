#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=5G
#SBATCH --cpus-per-task=1
#SBATCH --account=%ACCOUNT%
#SBATCH --job-name=tnf_calculation
#SBATCH --array=1-8

#SLURM REQUEST TO CALCULATE TETRANUCLEOTIDE FREQUENCY (this connects to the pythons script tnf.py)**
# BEFORE RUNNNING UPLOAD THE FILE checkm_requirement.txt to your directory 

set -euo pipefail
set -x
threads=$SLURM_CPUS_PER_TASK

#Set sample_list to loop through
export sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /path/to/directory/samplenames.txt)
#Load modules in Nibi cluster (Compute Canada)
module load python/3.11
module load pplacer
module load hmmer
module load prodigal
echo "Running sample: $sample"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $(hostname)"
date

srun --ntasks $SLURM_NNODES --tasks-per-node=1 bash << EOF
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install -r /path/to/directory/fastq_33/checkm_requirements.txt
checkm data setRoot
EOF

# activate only on main node
source $SLURM_TMPDIR/env/bin/activate;
# srun exports the current env, which contains $VIRTUAL_ENV and $PATH variables
chmod +x /path/to/directory/fastq_33/tnf.py
python /path/to/directory/fastq_33/tnf.py;
