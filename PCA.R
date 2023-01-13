#https://plotly.com/r/pca-visualization/


# load library haven
library(haven)
library(plotly)      #for plotting PCA
library(data.table)  #for reading in text files

setwd("C:/Users/qt09n/Desktop/verifyBamID/input/")

data(iris)

X <- subset(iris, select = -c(Species))
prin_comp <- prcomp(X)
components <- prin_comp[["x"]]
components <- data.frame(components)

#import data
ref_pop <- read.table("1000G_reference_populations.txt", stringsAsFactors = FALSE, quote = "", header = FALSE, sep = "\t", check.names = FALSE)
resource_1000g <-read.table("1000g.phase3.100k.b38.txt", stringsAsFactors = FALSE, quote = "", header = FALSE, sep = "\t", check.names = FALSE)

row.names(resource_1000g)<-resource_1000g$V1
row.names(ref_pop)<-ref_pop$V1

#combine the precomputed PCs from 1000g.phase3.100k.b38(resource_1000g) and population labels from  1000G_reference_populations(ref_pop)
reference <- cbind(resource_1000g, ref_pop)

#remove redundant sample columns
reference = subset(reference, select = -c(1, 6))

colnames(reference)[5]<-"population"

colnames(reference)[1:4]<-c("PC1","PC2","PC3","PC4")

reference <-as.data.frame(reference)


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
# PC1 vs PC2, 
# PC2 vs PC3, 
# PC3 vs PC4, 
# PC1 vs PC2 vs PC3 (i.e. 3 dimensional plot).
# Color reference individuals by their population labels (see plots in the example/ folder).

plot_pca(pca_df = reference, firstpc = "PC1", secondpc = "PC2")
plot_pca(pca_df = reference, firstpc = "PC2", secondpc = "PC3")
plot_pca(pca_df = reference, firstpc = "PC3", secondpc = "PC4")

#PC1 vs PC2 vs PC3 (i.e. 3 dimensional plot).
fig <- plot_ly(reference, x = ~PC1, y = ~PC2, z = ~PC3, color = ~reference$population, colors = c('#636EFA','#EF553B','#00CC96') ) %>%
  add_markers(size = 12)

fig


#read in individual results.Ancestry files which have been renamed by the individual sample identifier
setwd("C:/Users/qt09n/Desktop/verifyBamID/output")

filelist = list.files(pattern = "HGDP*")

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

colnames(DT_wide)<- c("PC1", "PC2", "PC3", "PC4")

#create some new columns annotating source of data
DT_wide$population<-"unknown"

reference$type <- "reference"
DT_wide$type <- "study"

#combine reference and study PCA dfs into single df
combined<- rbind(reference, DT_wide)

plot_pca(pca_df = combined, firstpc = "PC1", secondpc = "PC2")
plot_pca(pca_df = combined, firstpc = "PC2", secondpc = "PC3")
plot_pca(pca_df = combined, firstpc = "PC3", secondpc = "PC4")

#PC1 vs PC2 vs PC3 (i.e. 3 dimensional plot).
fig <- plot_ly(combined, x = ~PC1, y = ~PC2, z = ~PC3, color = ~combined$population, 
               mode = 'markers', symbol = ~type, symbols = c('200','5'), colors = c('#636EFA','#EF553B','#00CC96') ) %>%
  add_markers(size = 12)

fig



########### plotly symbols

vals <- schema(F)$traces$scatter$attributes$marker$symbol$values
vals <- grep("-", vals, value = T)
plot_ly() %>%
  add_markers(
    x = rep(1:12, each = 11, length.out = length(vals)),
    y = rep(1:11, times = 12, length.out = length(vals)),
    text = vals,
    hoverinfo = "text",
    marker = list(
      symbol = vals,
      size = 30,
      line = list(
        color = "black",
        width = 2
      )
    )
  )
