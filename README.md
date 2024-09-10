# RNA-Seq_pipeline
A RNA-Seq pipeline

### Software requirement
- For mapping and counting: hisat2, stringtie, samtools, htseq  
- For DEGs calculating: DESeq2, optparse  
- For plot: FactoMineR, ggplot2, ggrepel

### Step1 Mapping and counting
[1.RNASeq_pipeline.sh](https://github.com/maxuying1218/RNA-Seq_pipeline/blob/main/1.mapping_counting/1.RNASeq_pipeline.sh) is a script to use hisat2 to map reads to reference genome and use stringtie and htseq to count FPKM/TPM and reads count.  
[2.PCA_cal_plot.R](https://github.com/maxuying1218/RNA-Seq_pipeline/blob/main/1.mapping_counting/2.PCA_cal_plot.R) is a scirpt to do PCA and plot results using FPKM/TPM/count. Here is an example:  
![image](https://github.com/maxuying1218/RNA-Seq_pipeline/blob/main/figures/1.PCA_example.png)
The code is stored at [1.mapping_counting](1.mapping_counting).
#### Usage 
sh 1.RNASeq_pipeline.sh fq_r1 fq_r2 out_dir out_label ht2_index cpu gtf  

Rscript  2.PCA_cal_plot.R -i count_matrix -o output.pdf --labels c1,c2,c3,t1,t2 --group c,c,c,t,t --col_text red,blue
```
        -i CHARACTER, --input=CHARACTER
                Input gene expression matrix.File has header .Format: gene_name, sample1, sample2 .....

        -o CHARACTER, --output=CHARACTER
                output pdf.

        --labels_text=CHARACTER
                Labels for samples of input file, seperate by comma.

        --title_text=CHARACTER
                Whether to plot title.Default: FALSE.

        --fig_size=CHARACTER
                Figure width and height.Default:5,3.5.

        --col_text=CHARACTER
                Colors of groups for plot lines, seperate by command.Default: Rainbow colors.

        --group=CHARACTER
                Groups of every sample

        -h, --help
                Show this help message and exit
```
### Step2 calculate DEGs
