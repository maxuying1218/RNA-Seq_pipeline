#!/usr/bin/Rscript --vanilla
library("optparse")
library(ggplot2)
library(ggrepel)


option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="Input file of DEseq output. Format: gene_name, log2FC, Pvalue.", 
              metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out.pdf",
              help="output file name [default= %default]", metavar="character"),
  make_option("--log2FC", type="numeric", default=1.58,
              help="Log2(Fold change) to define DEGs. Default: 1.58."),
  make_option("--Pvalue", type="numeric", default=0.5,
              help="Pvalue of DEGs. Default: 0.5.", metavar="numeric"),
  make_option("--title_text", type="character", default=" ",
              help="Figure title."),
  make_option("--fig_inch_each", type="character", default="6.5,5",
              help="Figure width and height. Default: 6,5"),
  make_option("--xlim_value", type="character", default="n",
              help="Ylim value for plot.Example:1,2. Default:min*0.95,max*1.05", metavar="character"),
  make_option("--ylim_value", type="character", default="n",
              help="Ylim value for plot.Example:1,2. Default:min*0.95,max*1.05", metavar="character")
)


opt_parser = OptionParser(usage="%prog: Plot DEGs volcano plot.", option_list=option_list);
opt = parse_args(opt_parser)

opt$fig_inch_each=as.numeric(unlist(strsplit(opt$fig_inch_each, ",")))
if(opt$xlim_value != "n"){opt$xlim_value=as.numeric(unlist(strsplit(opt$xlim_value, ",")))}else{opt$xlim_value=c()}
if(opt$ylim_value != "n"){opt$ylim_value=as.numeric(unlist(strsplit(opt$ylim_value, ",")))}else{opt$ylim_value=c()}


volcano_plot <- function(input,log2FC, Pvalue, title_text,xlim_value,ylim_value){
	data=read.table(file=input,header=T,row.names=1)
	data[is.na(data)]=0
	idx1=which(data[,1]==0)
	idx2=which(data[,1]=="-Inf")
	idx3=which(data[,1]=="Inf")
	idx=c(idx1,idx2,idx3)
	if (length(idx) != 0 ){data=data[-idx,]}
	###########
	data=cbind(data,class=rep("no_change",dim(data)[1]),gene=rownames(data))
	data[,3]=as.character(data[,3])
	data[which(data[,1] > log2FC & data[,2]< Pvalue),3]="up"
	data[which(data[,1] < -log2FC & data[,2]< Pvalue),3]="down"
	
	num_up=length(data[data[,3]=="up",3])
	num_down=length(data[data[,3]=="down",3])
	num_no_change=length(data[data[,3]=="no_change",3])
	lab_up=paste("up:",num_up,sep="")
	lab_down=paste("down:",num_down,sep="")
	lab_no_change=paste("no_change:",num_no_change,sep="")
	
	#############
	data[which(data[,2]==0),2]=0.00000001
	data[,2]=-log10(data[,2])
	data[,4]=as.character(data[,4])
	colnames(data)=c("log2FC","Pvalue","class","gene")

	if (length(xlim_value)==0){
		x_max=max(abs(min(data[,1])),max(data[,1]))
		if (x_max==Inf){x_max=quantile(data[,1],0.95)}
		xlim_value=c(-x_max,x_max)
	}
	if (length(ylim_value)==0){
		y_max=max(data[,2])
		if (y_max==Inf){y_max=quantile(data[,2],0.95)}
		ylim_value=c(0,y_max)
	}
	
	data[,3]=factor(data[,3],levels=c("up","down","no_change"))
	d1=data[which(data[,3]=="no_change"),]
	d2=data[which(data[,3]=="up"),]
	d3=data[which(data[,3]=="down"),]
	data=rbind(d1,d2,d3)
	####
	
	p = ggplot(data,aes(x=log2FC,y=Pvalue,colour=class)) 
	p = p + geom_point()
	p = p + scale_colour_manual(values=c(down="blue",no_change="grey",up="red"),labels=c(lab_up,lab_down,lab_no_change))
	p = p + theme_classic()
	p = p + xlim(xlim_value) + ylim(ylim_value)
	p = p + labs(x="log2(Fold change)", y="-log10(Pvalue)", title=title_text)
	p = p + theme(axis.text.x=element_text(size=rel(1.5), color = "black",hjust = 1),
	              axis.text.y=element_text(size=rel(1.5), color = "black"),
	              axis.title.x=element_text(size=rel(1.5), color = "black"),
	              axis.title.y=element_text(size=rel(1.5), color = "black"),
	              plot.title=element_text(size=rel(2), color = "black",hjust=0.5),
	              legend.text = element_text(size=rel(1.25),color="black"),
	              legend.title = element_text(size=rel(1.25),color="black"),
	              panel.border=element_rect(colour="black",fill=NA,size=1))
	p = p + geom_vline(xintercept=c(-log2FC,log2FC),lty=4,col="grey",lwd=0.8) +
	        geom_hline(yintercept = -log10(Pvalue),lty=4,col="grey",lwd=0.8)
	p = p + annotate("text", label = paste("Pvalue<=",Pvalue,"\n|log2FC|>",log2FC,sep=""), x = 7.5, y = 0.5, size = 3, colour = "black")
    return(p)
}


p = volcano_plot(input=opt$input,log2FC=opt$log2FC, Pvalue=opt$Pvalue,title_text=opt$title_text,xlim_value=opt$xlim_value,ylim_value=opt$ylim_value)
pdf(opt$out,width=opt$fig_inch_each[1], height=opt$fig_inch_each[2])
p
dev.off()

outpng=gsub("pdf","png",opt$out)
png(outpng,width=opt$fig_inch_each[1], height=opt$fig_inch_each[2], units = "in", res=300)
p
dev.off()

