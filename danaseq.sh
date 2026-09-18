#LAUNCH DANASEQ PIPELINE FOR BINNING, GENE CALLING, AND FUNCTIONAL ANNOTATION (this runs everything but the visualization step, which is buggy)**
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /path/to/directory/samplenames.txt)
mkdir -p /scratch/asanger/Elliott_Meta2026/fastq_33/danaseq/${sample}
module load apptainer
/path/to.apptainer/run-mag-analysis.sh --apptainer \
  --sif /path/to/sif/danaseq-mag-analysis-custom.sif \
  --annotator bakta \
  --bakta_extra \
  --run_semibin true \
  --run_maxbin true \
  --run_lorbin true \
  --run_comebin true \
  --run_vamb true \
  --run_binette true \
  --run_magscot true \
  --run_kraken2 true \
  --run_rrna true \
  --run_metabolism true \
  --run_antismash true \
  --run_eukaryotic true \
  --run_metaeuk true \
  --run_marferret true \
  --run_gtdbtk true \
  --run_kaiju true \
  --run_genomad true \
  --run_checkv true \
  --run_defensefinder true \
  --run_integronfinder true \
  --run_islandpath true \
  --run_macsyfinder true \
  --assembly /path/to/directory/fastq_33/MEGAHIT_assembly/${sample}-contigsdir/${sample}-renamedcontigs.fa \
  --depths /path/to/directory/fastq_33/MEGAHIT_assembly/BAM_files_minimap2/${sample}/depths.txt \
  --bam_dir /path/to/directory/fastq_33/MEGAHIT_assembly/BAM_files_minimap2/${sample} \
  --tnf /path/to/directory/fastq_33/MEGAHIT_assembly/TNFs/${sample}_tnf.tsv \
  --store_dir /path/to/directory/fastq_33/danaseq/${sample} \
  --workdir ${SLURM_TMPDIR}/work \
  --db_dir /path/to/databases
