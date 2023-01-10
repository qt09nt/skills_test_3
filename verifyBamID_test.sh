#!/bin/bash

#https://linuxhandbook.com/bash-automation/
cd /Users/queenietsang/desktop/VerifyBamID-master/input 

#get all the names of the individuals
find . -type f -name \*.cram > indiv_crams.txt

#remove the first 2 characters "./" from each line of indiv_crams.txt and output to test.txt
cat indiv_crams.txt | sed 's/^..//'>test.txt


#get the CRAM file names of the 10 study individuals
individuals=$(cat test.txt)

#set the VERIFY_BAM_ID_HOME to the main VerifyBamID-master directory
export VERIFY_BAM_ID_HOME=/Users/queenietsang/Desktop/VerifyBamID-master

mkdir -p output

cd output
   
for i in $individuals; do
echo $i

$VERIFY_BAM_ID_HOME/bin/VerifyBamID  
--SVDPrefix $VERIFY_BAM_ID_HOME/resource/1000g.phase3.100k.b38.vcf.gz.dat 
--Reference $VERIFY_BAM_ID_HOME/input/GRCh38_full_analysis_set_plus_decoy_hla.fa 
--BamFile $VERIFY_BAM_ID_HOME/input/$i
--NumPC 4

#create new folder with individual name
mkdir $i

#move results files into folder for each individual
mv *.Ancestry *.selfSM $i

done

