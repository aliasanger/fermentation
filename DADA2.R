library(dada2)
library(microViz)
library(phyloseq)
library(vegan)
library(dplyr)
library(vctrs)
library(patchwork)
library(ggplot2)
library(decontam)

#Establish path to FASTQ files
input_path <- "/path/to/directory/" # CHANGE ME to the directory containing the fastq files after unzipping. Replace back slashes with forward slashes
list.files(input_path)
output_path <- "/path/to/directory/"

## first we're setting a few variables we're going to use ##
# one with all sample names, by scanning our "samples" file we made earlier
samples <- scan(file.path(input_path,"samples_5"), what="character")

# paths to trimmed files from 16S_cutadapt.sh
# one holding the file names of all the forward reads, note unzipped
forward_reads <- file.path(input_path, paste0(samples, "_R1_001_trimmed.fastq"))
# and one with the reverse
reverse_reads <- file.path(input_path, paste0(samples, "_R2_001_trimmed.fastq"))

# # and variables holding file names for the forward and reverse
# # filtered reads we're going to generate below
filtered_forward_reads <- file.path(output_path, paste0(samples, "_R1_001_filtered.fastq.gz"))
filtered_reverse_reads <- file.path(output_path, paste0(samples, "_R2_001_filtered.fastq.gz"))

# updated trim length to 270 on July 9th 2026, note minLen isn't useful here 
#After trimming primers, the reads are at slightly different lengths. After looking at the multiQC report (Sequence Length Distribution plot) for the average length of reads per sample, we will truncate to a consistent length of 270.The other parameters (quality based) are left on default from the DADA2 pipeline.
filtered_out <- filterAndTrim(forward_reads, filtered_forward_reads,
                              reverse_reads, filtered_reverse_reads, maxEE=c(2,2),
                              rm.phix=TRUE, truncLen=c(270,270))

# from https://benjjneb.github.io/dada2/tutorial.html
# The DADA2 algorithm makes use of a parametric error model (err) and every amplicon dataset has a different set of error rates. 
# The learnErrors method learns this error model from the data, by alternating estimation of the error rates and inference of sample composition until they converge on a jointly consistent solution. 
# As in many machine-learning problems, the algorithm must begin with an initial guess, for which the maximum possible error rates in this data are used (the error rates if only the most abundant sequence is correct and all the rest are errors).
err_forward_reads <- learnErrors(filtered_forward_reads)
# err_forward_reads <- learnErrors(filtered_forward_reads, multithread=TRUE) 
err_reverse_reads <- learnErrors(filtered_reverse_reads)
# err_reverse_reads <- learnErrors(filtered_reverse_reads, multithread=TRUE) 
plotErrors(err_forward_reads, nominalQ=TRUE)
plotErrors(err_reverse_reads, nominalQ=TRUE)

### Dereplication
derep_forward <- derepFastq(filtered_forward_reads, verbose=TRUE)
names(derep_forward) <- samples # the sample names in these objects are initially the file names of the samples, this sets them to the sample names for the rest of the workflow
derep_reverse <- derepFastq(filtered_reverse_reads, verbose=TRUE)
names(derep_reverse) <- samples

dada_forward <- dada(derep_forward, err=err_forward_reads, pool="pseudo", multithread=FALSE)
dada_reverse <- dada(derep_reverse, err=err_reverse_reads, pool="pseudo", multithread=FALSE)

# we used 515F and 926R primers 
# expect 150 bp overlaps, did minOverlap 100 
merged_amplicons <- mergePairs(dada_forward, derep_forward, dada_reverse,
                               derep_reverse, trimOverhang=TRUE, minOverlap=100)

# Generate a count table 
seqtab <- makeSequenceTable(merged_amplicons)
class(seqtab) # matrix
dim(seqtab) 
#The core dada method corrects substitution and indel errors, but chimeras remain. Fortunately, the accuracy of sequence variants after denoising makes identifying chimeric ASVs simpler than when dealing with fuzzy OTUs. Chimeric sequences are identified if they can be exactly reconstructed by combining a left-segment and a right-segment from two more abundant “parent” sequences.
seqtab.nochim <- removeBimeraDenovo(seqtab, verbose=T)
sum(seqtab.nochim)/sum(seqtab) # 0.9394707 # 7% in terms of abundance

getN <- function(x) sum(getUniques(x))
summary_tab <- data.frame(row.names=samples, dada2_input=filtered_out[,1],
                          filtered=filtered_out[,2], dada_f=sapply(dada_forward, getN),
                          dada_r=sapply(dada_reverse, getN), merged=sapply(merged_amplicons, getN),
                          nonchim=rowSums(seqtab.nochim),
                          final_perc_reads_retained=round(rowSums(seqtab.nochim)/filtered_out[,1]*100, 1))
write.table(summary_tab, "read-count-tracking.tsv", quote=FALSE, sep="\t", col.names=NA)
# inspect how many reads were lost at each step; overall, the minimum final_perc_reads_retained was 84%

####################################### ASSIGN TAXONOMY TO ASVs ################################################################
# https://www.arb-silva.de/current-release/DADA2/1.36.0/SSU 
taxa <- assignTaxonomy(seqtab.nochim, file.path(input_path, "silva_nr99_v138.2_toSpecies_trainset.fa.gz"), multithread=TRUE) 
taxa <- addSpecies(taxa, file.path(input_path, "silva_v138.2_assignSpecies.fa.gz"))

# giving our seq headers more manageable names (ASV_1, ASV_2...)
asv_seqs <- colnames(seqtab.nochim)
asv_headers <- vector(dim(seqtab.nochim)[2], mode="character")

for (i in 1:dim(seqtab.nochim)[2]) {
  asv_headers[i] <- paste(">ASV", i, sep="_")
}

# making and writing out a fasta of our final ASV seqs:
asv_fasta <- c(rbind(asv_headers, asv_seqs))
write(asv_fasta, "ASVs.fa")

# count table:
asv_tab <- t(seqtab.nochim)
row.names(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, "ASVs_counts.tsv", sep="\t", quote=F, col.names=NA)

# tax table:
asv_tax <- taxa
# Use the actual column names from your taxa object, or create custom ones
colnames(asv_tax) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species", "Species_refined")

# Set any unclassified taxa as NA
asv_tax[asv_tax == ""] <- NA
asv_tax[!is.na(asv_tax) & grepl("unclassified", asv_tax, ignore.case = TRUE)] <- NA
# Set the row names to match your ASV headers
rownames(asv_tax) <- sub(">", "", asv_headers)
write.table(asv_tax, "ASVs_taxonomy.tsv", sep = "\t", quote=F, col.names=NA)

############################ REMOVE ASVs THAT APPEAR IN CONTROL SAMPLE -- BLANK FILTER #############################################
library(decontam)
packageVersion("decontam") #‘1.26.0’
sample_names <- colnames(asv_tab)
vector_for_decontam <- sample_names == "Sanger58_S268_L001"
contam_df <- isContaminant(t(asv_tab), neg=vector_for_decontam)

table(contam_df$contaminant) # identified 3 as contaminants
# getting vector holding the identified contaminant IDs
contam_asvs <- row.names(contam_df[contam_df$contaminant == TRUE, ])
asv_tax[row.names(asv_tax) %in% contam_asvs, ]
# Domain     Phylum           Class                 Order                Family                      Genus             Species    
# ASV_83  "Bacteria" "Bacillota"      "Bacilli"             "Erysipelotrichales" "Erysipelatoclostridiaceae" "Catenibacterium" "mitsuokai"
# ASV_85  "Bacteria" "Pseudomonadota" "Gammaproteobacteria" "Burkholderiales"    "Burkholderiaceae"          "Ralstonia"       "insidiosa"
# ASV_105 "Bacteria" "Bacillota"      "Bacilli"             "Staphylococcales"   "Staphylococcaceae"         "Staphylococcus"  "aureus"

neg_control_depth <- sum(asv_tab[, "Sanger58_S268_L001"])
total_median_depth <- median(colSums(asv_tab))

cat("Negative control total reads:", neg_control_depth, "\n")
# Negative control total reads: 338 
cat("Median sample total reads:", total_median_depth, "\n")
# Median sample total reads: 78083.5 
cat("Negative control as % of median sample depth:", 
    round(neg_control_depth / total_median_depth * 100, 2), "%\n")
# Negative control as % of median sample depth: 0.43 %

contam_indices <- which(asv_fasta %in% paste0(">", contam_asvs))
dont_want <- sort(c(contam_indices, contam_indices + 1))
asv_fasta_no_contam <- asv_fasta[- dont_want]

# make a new count table
asv_tab_no_contam <- asv_tab[!row.names(asv_tab) %in% contam_asvs, ]

# make a new taxonomy table
asv_tax_no_contam <- asv_tax[!row.names(asv_tax) %in% contam_asvs, ]

write(asv_fasta_no_contam, "ASVs-no-contam.fa")
write.table(asv_tab_no_contam, "ASVs_counts-no-contam.tsv",
            sep="\t", quote=F, col.names=NA)
write.table(asv_tax_no_contam, "ASVs_taxonomy-no-contam.tsv",
            sep="\t", quote=F, col.names=NA)



