minimap2 \
    -ax sr \
    -t $SLURM_CPUS_PER_TASK \
    ${assembly_dir}/${sample}-renamedcontigs.fa \
    ${reads_dir}/${sample}_R1_001.fastq.gz ${reads_dir}/${sample}_R2_001.fastq.gz | \
samtools view -b -F 4 | \
samtools sort -@ $SLURM_CPUS_PER_TASK -o ${outdir}/${sample}.sorted.bam
