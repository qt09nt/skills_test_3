
# load library haven
library(haven)
library(plotly)      #for plotting PCA
library(data.table)  #for reading in text files
library(tidyr)
library(tidyverse)

#set working directory to VerifyBamID/input
#for windows:
setwd("C:/Users/qt09n/Desktop/verifyBamID-master/input/")
#for mac:
setwd("/Users/queenietsang/Desktop/VerifyBamID-master/input")

#import data
ref_pop <- read.table("1000G_reference_populations.txt", stringsAsFactors = FALSE, quote = "", header = FALSE, sep = "\t", check.names = FALSE)
resource_1000g <-read.table("1000g.phase3.100k.b38.txt", stringsAsFactors = FALSE, quote = "", header = FALSE, sep = "\t", check.names = FALSE)

#rename row names for resource_1000g and ref_pop dataframes using individual study names
row.names(resource_1000g)<-resource_1000g$V1
row.names(ref_pop)<-ref_pop$V1

#combine the precomputed PCs from 1000g.phase3.100k.b38(resource_1000g) and population labels from  1000G_reference_populations(ref_pop)
reference <- cbind(resource_1000g, ref_pop)

#remove redundant sample columns
reference = subset(reference, select = -c(1, 6))

#rename the labels column "population
colnames(reference)[5]<-"population"

#rename the columns containing the pre-computed principal components
colnames(reference)[1:4]<-c("PC1","PC2","PC3","PC4")

#set as a dataframe
reference <-as.data.frame(reference)

#plot PC1 and PC2 from the reference 
fig <- plot_ly(reference, x = ~PC1, y = ~PC2, color = ~reference$population, colors = c('#636EFA','#EF553B','#00CC96'), type = 'scatter', mode = 'markers')%>%
    layout(
      legend=list(title=list(text='color')),
      plot_bgcolor='#e5ecf6',
      xaxis = list(
        title = "PC1",
        zerolinecolor = "#ffff",
        zerolinewidth = 2,
        gridcolor='#ffff'),
      yaxis = list(
        title = "PC2",
        zerolinecolor = "#ffff",
        zerolinewidth = 2,
        gridcolor='#ffff'))
  
fig
 
#function for plotting PCA 
#input arguments are pca_df which is a dataframe containing the sample names, principal components columns, 
#population column which contains the labels ie. (i.e. EUR, EAS, AMR, SAS, and AFR), type column
#which indicates either "reference" or "study".
#the argument "firstpc" is a string which indicates the column name of the first principal component of interest to plot
#the argument "secondpc" is a string which indicates the column name of the second principal component of interest to plot
plot_pca<- function(pca_df, firstpc, secondpc){
  fig <- plot_ly(pca_df, x = ~pca_df[,firstpc], y = ~pca_df[,secondpc], color = ~pca_df$population, symbol = ~pca_df$type, colors = c('#636EFA','#EF553B','#00CC96'), type = 'scatter', mode = 'markers')%>%
    layout(
      legend=list(title=list(text='color')),
      plot_bgcolor='#e5ecf6',
      xaxis = list(
        title = paste0(firstpc),
        zerolinecolor = "#ffff",
        zerolinewidth = 2,
        gridcolor='#ffff'),
      yaxis = list(
        title = paste0(secondpc),
        zerolinecolor = "#ffff",
        zerolinewidth = 2,
        gridcolor='#ffff'))
  
  fig  
  
}

# Create the following 4 scatter plots visualizing reference individuals and 10 study individuals in
# the same space: 
# Color reference individuals by their population labels (see plots in the example/ folder).

# PC1 vs PC2
plot_pca(pca_df = reference, firstpc = "PC1", secondpc = "PC2")

# PC2 vs PC3
plot_pca(pca_df = reference, firstpc = "PC2", secondpc = "PC3")

# PC3 vs PC4
plot_pca(pca_df = reference, firstpc = "PC3", secondpc = "PC4")

#PC1 vs PC2 vs PC3 (i.e. 3 dimensional plot).
fig <- plot_ly(reference, x = ~PC1, y = ~PC2, z = ~PC3, color = ~reference$population, colors = c('#636EFA','#EF553B','#00CC96') ) %>%
  add_markers(size = 12)

fig

#
#read in individual results.Ancestry files which have been renamed by the individual sample identifier
#for windows:
setwd("C:/Users/qt09n/Desktop/verifyBamID/output")
setwd("/Users/queenietsang/Desktop/VerifyBamID-master/output")

#create a list object which contains all the files containing "HGDP" and ends in ".txt"
filelist = list.files(pattern = glob2rx("HGDP*.txt"))

#merge all individual ancestry results files into a single dataframe
DT <- rbindlist(sapply(filelist, fread, simplify = FALSE),
                use.names = TRUE, idcol = "FileName")

#get rid of Contaminating Sample Column
DT <- DT[,!"ContaminatingSample"]

#spread the values of the principal components (found in IntendedSample column) from 1 column to 4 separate PC columns
DT_wide<- DT %>%
  spread(PC, IntendedSample)

#get rid of the ".txt" portion of the individual sample names
DT_wide$FileName <- gsub(".txt", "", (DT_wide$FileName))

#set individual sample names as row names
DT_wide<- DT_wide %>% 
  remove_rownames %>% 
  column_to_rownames(var="FileName")

#rename DT_wide dataframe with names of the 4 principal components
colnames(DT_wide)<- c("PC1", "PC2", "PC3", "PC4")

#create some new columns annotating source of data
DT_wide$population<-"unknown"

#create a "type" column in the reference and study dataframe which indicates the type of sample
reference$type <- "reference"
DT_wide$type <- "study"

#combine reference and study PCA dataframes into single dataframe
combined<- rbind(reference, DT_wide)

#plot different combinations of principal components
plot_pca(pca_df = combined, firstpc = "PC1", secondpc = "PC2")
plot_pca(pca_df = combined, firstpc = "PC2", secondpc = "PC3")
plot_pca(pca_df = combined, firstpc = "PC3", secondpc = "PC4")

#PC1 vs PC2 vs PC3 (i.e. 3 dimensional plot).
#symbol 200 is filled circle, 22 = filled square
fig <- plot_ly(combined, x = ~PC1, y = ~PC2, z = ~PC3, color = ~combined$population, 
               mode = 'markers', symbol = ~type, symbols = c('200','22'),    
               text = ~ row.names(combined),
               colors = c('#636EFA','#EF553B','#00CC96') ) %>%
  add_markers(size = 12)

fig


######label the study individuals dataframe with population labels in the population column
DT_wide["HGDP01310",5]<-"EAS"
DT_wide["HGDP00563",5]<- "AMR"
DT_wide["HGDP00669",5] <-"EUR"
DT_wide["HGDP00450",5] <-"AFR"
DT_wide["HGDP01225",5] <-"EAS"
DT_wide["HGDP00575",5] <-"EUR"
DT_wide["HGDP00082",5] <-"SAS"
DT_wide["HGDP00859",5] <-"AMR"
DT_wide["HGDP00843",5]<- "AMR"
DT_wide["HGDP00525",5]<- "EUR"

DT_wide$SAMPLE <- row.names(DT_wide)

#re-order the Populations dataframe to have SAMPLE as the first column, followed by principal components columns
Populations<-cbind(DT_wide$SAMPLE, DT_wide[,1:5])

#rename first column of Populations dataframe to "SAMPLE" and last column as "POPULATION"
colnames(Populations)[1]<- "SAMPLE"
colnames(Populations)[6]<- "POPULATION"
rownames(Populations)<- NULL

#save Populations table to Populations.txt 
write.table(Populations, file = "Populations.txt", sep = "\t",
            row.names = FALSE, col.names = TRUE)
