
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

