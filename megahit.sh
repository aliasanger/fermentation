megahit \
    -1 ./fastq_33/${sample}_R1_001.fastq.gz \
    -2 ./fastq_33/${sample}_R2_001.fastq.gz \
    -t $SLURM_CPUS_PER_TASK \
    -m 0.99 \
    --mem-flag 0 \
    -o ./fastq_33/MEGAHIT_assembly/${sample}
