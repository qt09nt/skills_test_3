(a) a list of all open-source software tools (and their versions) which were used;


R version 4.1.1
RStudio version 2022.12.0 Build 353

VerifyBamID2 from https://github.com/Griffan/VerifyBamID

R Libraries Used:
haven version 2.5.1
plotly version 2.0     
data.table version version 1.14.6
tidyverse version 1.3.1 

(b) any additional requirements for the operating system and/or system libraries; 
Operating Systems: macOS Monterey version 12.5.1, Windows 11

(c) any compilation instructions if such exists 
N/A

(d) detailed step-by-step description on how to run the tool.

Part 1. Estimating DNA contamination and genetic ancestry. 
1) Install VerifyBamID as per instructions at https://github.com/Griffan/VerifyBamID.
2) In the VerifyBamID-master directory create a folder called "input"
3) download all input files from https://github.com/CERC-Genomic-Medicine/skills_test_3/tree/main/input
 and move them into the directory VerifyBamID-master/input
4) Copy verifyBamID_test.sh into the VerifyBamID-master directory
5) Open a Terminal window and navigate to VerifyBamID-master directory
6) Run verifyBamID_test.sh by typing "./verifyBamID_test.sh". This should 
generate *.Ancestry and *.selfSM output files for each study individual and 
move them into separate folder named for each study individual.
7) Run verifyBamID_test2.sh by typing "./verifyBamID_test2.sh". This step creates
the Contamination.txt file which concatenates the SAMPLE column and FREEMIX column
from all the *.selfSM output files generated from step 6.

Part 2. Visualizing estimated ancestry PCs and Part 3. Assigning most likely super population.
1) Rename result.Ancestry files for each individual study sample by opening 
the result.Ancestry file and copying contents into a new text file that
is named for each individual sample identifier ie. HGDP00082.txt.
Place these files in the directory verifyBamID-master/output
2) Copy contents of 1000g.phase3.100k.b38.dat.V into 1000g.phase3.100k.b38.txt and place file in VerifyBamID-master/input
2) Open RStudio.
3) Run PCA.R by pressing highlighting all code and pressing "Run" button or
run each line individually with CTRL + ENTER or CMD + return.




