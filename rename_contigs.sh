##Script for renaming scaffolds within the assembly file and copying it to new directory
#when you use this script, do ./rename_contigs.sh <path to OG file(no slash at end)> <OG filename> <unique sanmple ID>

#rename the final.contigs.fa and then,
#rename the scaffolds with the sample name with 'scaffold'
mkdir $3-contigsdir &&
cp $1/$2 $3-contigs.fa &&
sed "s/^>/>$3/" $3-contigs.fa >> $3-renamedcontigs.fa &&
sed -i 's/k.*_/_scaffold_/g' $3-renamedcontigs.fa &&
sed -i 's/\s.*//g' $3-renamedcontigs.fa
mv $3-contigs.fa $3-contigsdir &&
mv $3-renamedcontigs.fa $3-contigsdir &&
echo "done!"
