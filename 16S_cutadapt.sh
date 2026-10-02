conda activate cutadapt
cutadapt --version # 2.3
for sample in $(cat samples_5)
do

    echo "On sample: $sample"
    
    cutadapt -a ^GTGYCAGCMGCCGCGGTAA...AAACTYAAAKRAATTGRCGG \
             -A ^CCGYCAATTYMTTTRAGTTT...TTACCGCGGCKGCTGRCAC \
             -m 215 --discard-untrimmed \
             -o ${sample}_R1_001_trimmed.fastq.gz -p ${sample}_R2_001_trimmed.fastq.gz \
             ${sample}_R1_001.fastq.gz ${sample}_R2_001.fastq.gz \
             >> cutadapt_primer_trimming_stats.txt 2>&1

done

# check how many reads were retained
paste samples_5 <(grep "passing" cutadapt_primer_trimming_stats.txt | cut -f3 -d "(" | tr -d ")") <(grep "filtered" cutadapt_primer_trimming_stats.txt | cut -f3 -d "(" | tr -d ")")
# c2 fraction of reads were retained in each sample - all above 99% 
# c3: fraction of bps were retained in each sample - all above 92%

mkdir trimmed_fastqfiles
fastqc *_trimmed.fastq.gz -o trimmed_fastqfiles 
cd trimmed_fastqfiles
multiqc . --title trimmed_samples

#inspect report 
# No samples found with any adapter contamination > 0.1%
# FastQC: Mean Quality Scores; extremely high quality, all over 30 phred throughout entire length of sequence (Position bp) 
# FastQC: Sequence Length Distribution; <10 seq below 270 bp, most (up to 160k per sample) above 278)
# Low reads in some samples: Sanger31_S324_L001 (VP_28C_EXP_2_10/2), Sanger33_S253_L001 (Control_RT_EXP_2_7/7), Sanger58_S268_L001 (blank) - also flagged by IMR sequencing centre

