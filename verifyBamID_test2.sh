#!/bin/bash

cd /Users/queenietsang/Desktop/VerifyBamID-master/output

#create a new file called Contamination.txt
touch Contamination.txt

#clear contents of Contamination.txt if existing file 
: > Contamination.txt

#create 2 columns titles called “SAMPLE” and “FREEMIX” in Contamination.txt
echo SAMPLE FREEMIX > Contamination.txt  

#find all files with .selfSM and append all contents of .selfSM files into a new file called all.txt
find . -type f -name '*.selfSM' -exec cat {} + > all.txt

#append SAMPLE column(column 1)  and FREEMIX column (column 7) to Contamination.txt file
awk '{print$1, $7}' all.txt >> Contamination.txt
