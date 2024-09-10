#!/usr/bin/Rscript --vanilla
library("optparse")
library(ggplot2)
library(ggrepel)
library(FactoMineR)

option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="Input profile files.File has header .Format: gene_name, sample1, sample2 .....",
              metavar="character"),
  make_option(c("-o", "--output"), type="character", default=NULL,
              help="output pdf.", metavar="character"),
  make_option("--labels_text", type="character", default="n",
              help="Labels for samples of input file, seperate by comma.", metavar="character"),
  make_option("--title_text", type="character", default="n",
              help="Whether to plot title.Default: FALSE.", metavar="character"),
  make_option("--fig_size", type="character", default="5,3.5",
              help="Figure width and height.Default:5,3.5.", metavar="character"),
  make_option("--col_text", type="character", default="n",
              help="Colors of groups for plot lines, seperate by command.Default: Rainbow colors.", metavar="character"),
  make_option("--group",type="character", default="n",
              help="Groups of every sample",metavar="character")
)


opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)



if(opt$title_text == "n"){opt$title_text=""}
opt$col_text=unlist(strsplit(opt$col_text,","))
opt$labels_text=unlist(strsplit(opt$labels_text,","))
opt$group=unlist(strsplit(opt$group,","))
opt$fig_size=as.numeric(unlist(strsplit(opt$fig_size, ",")))

title_text <- opt$title_text
col_text <- opt$col_text
group <- opt$group
label_text <- opt$labels_text


data <- read.table(opt$input,header = T,row.names = 1)

group_list <- as.data.frame(cbind(label_text,group))
colnames(group_list) <- c("samples","group")
data <- t(data)
data <-PCA(data, ncp = 2, scale.unit = TRUE, graph = FALSE)                            
pca_sample <- data.frame(data$ind$coord[ ,1:2])
#head(pca_sample)
pca_eig1 <- round(data$eig[1,2], 2)
pca_eig2 <- round(data$eig[2,2], 2)
#group <- group_list[rownames(pca_sample),]
pca_sample <- cbind(pca_sample, group_list)
pca_sample$samples <- group_list$samples  


p <- ggplot(data = pca_sample, aes(x = Dim.1, y = Dim.2)) +
  geom_point(aes(color = group), size = 3) + 
  labs(title = title_text)+ 
  scale_color_manual(values = col_text) + 
  theme(panel.grid = element_blank(), panel.background = element_rect(color = 'black', fill = 'transparent'),
        legend.key = element_rect(fill = 'transparent'), 
        plot.title = element_text(size = 18,face = "bold", vjust = 0.5, hjust = 0.5)) +
  labs(x = paste('PC1:', pca_eig1, '%'), y = paste('PC2:', pca_eig2, '%'), color = '') 

p <- p +
  geom_text_repel(aes(label = samples), size = 3, show.legend = FALSE,box.padding = unit(0.5, 'lines'))


pdf(opt$output,width=opt$fig_size[1],height=opt$fig_size[2])
p
dev.off()

outpng=gsub("pdf","png",opt$output)
png(outpng,width=opt$fig_size[1],height=opt$fig_size[2],units = "in", res=300)
p
dev.off()
