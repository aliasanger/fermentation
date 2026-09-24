# fermentation
This repository contains all the code used to generate MAGs for xx 

The order of analysis is as follows 

**STEP 1: run fastp https://github.com/opengene/fastp**
A tool designed to provide ultrafast all-in-one preprocessing and quality control for FastQ data.

[fastp.sh](https://github.com/aliasanger/fermentation/blob/97475f47bce62e12f412740b86a04f66d42f46c4/fastp.sh)

**STEP 2: run assembly using megaHIT https://github.com/voutcn/MEGAHIT**

[megahit.sh](https://github.com/aliasanger/fermentation/blob/97475f47bce62e12f412740b86a04f66d42f46c4/megahit.sh)

**STEP 3: rename contigs using custom script from Baker lab**

rename_contigs.sh

**STEP 4: run metaquast for genome assembly evaluation https://github.com/ablab/quast**
QUAST stands for QUality ASsessment Tool. It evaluates genome/metagenome assemblies by computing various metrics. The current QUAST toolkit includes the general QUAST tool for genome assemblies, MetaQUAST, the extension for metagenomic datasets,

metaquast.sh 

**STEP 5: map with minimap2 https://github.com/lh3/minimap2**
minimpa2 is a versatile sequence alignment program that aligns dna or rna sequences against a reference, our use case is aligning Illumina single- or paired-end reads

[minimap2.sh](https://github.com/aliasanger/fermentation/blob/97475f47bce62e12f412740b86a04f66d42f46c4/minimap2.sh)

**STEP 6: flagstat https://www.htslib.org/doc/samtools-flagstat.html**

[flagstat.sh](https://github.com/aliasanger/fermentation/blob/a9675c5f640a4b838a24bbe22e5e952bf92f2ff5/flagstat.sh)

**STEP 7: depths**

[depths.sh ](https://github.com/aliasanger/fermentation/blob/01c45fce80ad8e2297b3195963a63eaafb45fc22/tnf_batch_all.sh)

**STEP 8: tnfs, calculate tetranucleotide frequency**

upload [checkm_requirements.txt ](https://github.com/aliasanger/fermentation/blob/42629d568aa2698f78cfa22d90bd474efe223fd8/checkm_requirements.txt)

[tnf_batch_all.sh ](https://github.com/aliasanger/fermentation/blob/01c45fce80ad8e2297b3195963a63eaafb45fc22/tnf_batch_all.sh)

[tnf.py](https://github.com/aliasanger/fermentation/blob/9357d085485749d6eb5ef26f9f2f2c0427bbf174/tnf.py)

**STEP 9: danaseq https://github.com/rec3141/danaSeq**
danaseq does binning (comebin, lorbin, magscot, mabin, metabat, semibin, vamb) -> dastool to pick the best from each + annotation with bakta and some other add ons 

[danaseq.sh](https://github.com/aliasanger/fermentation/blob/97475f47bce62e12f412740b86a04f66d42f46c4/danaseq.sh)

**STEP 10: checkm2 https://github.com/chklovski/CheckM2**

[checkm2.sh](https://github.com/aliasanger/fermentation/blob/895d59f3856fdbe9f9eeb9670af072b32c254aff/checkm2.sh)

**STEP 11: dereplication with dRep https://github.com/MrOlm/drep**
dRep is a python program for rapidly comparing large numbers of genomes. dRep can also "de-replicate" a genome set by identifying groups of highly similar genomes and choosing the best representative genome for each genome set.

[drep_apptainer_comp90_con5.sh](https://github.com/aliasanger/fermentation/blob/cad0b774003132616efc2b60daa229922b04347d/drep_comp90_con5)

