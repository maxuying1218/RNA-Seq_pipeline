
counts=$1 ### two count files seperate by comma
out_dir=$2
out_label=$3
sample_labels=$4 ### seperated by comma


out_dir=`cd $out_dir|pwd`/${out_dir}
DESeq_out_dir=${out_dir}/1.DESeq_out
DESeq_5col_dir=${out_dir}/2.DESeq_5col
DESeq_3col_dir=${out_dir}/2.DESeq_3col
volcano_dir=${out_dir}/4.volcano_plot

mkdir -p ${DESeq_out_dir} ${DESeq_5col_dir} $DESeq_3col_dir $MA_dir $volcano_dir


##DESeq_out
DESeq_out=${DESeq_out_dir}/${out_label}.DESeq.txt
Rscript /picb/epigenome/usr/maxuying/tools/1.DESeq_no_rep.2samples.R $counts $DESeq_out $sample_labels 
###


DESeq_5col=${DESeq_5col_dir}/${out_label}.DESeq_5col.txt
cut -f 1,3,4,6,7 $DESeq_out > $DESeq_5col

######
DESeq_3col=${DESeq_3col_dir}/${out_label}.DESeq_3col.txt
cut -f 1,6,7 $DESeq_out > $DESeq_3col

#### Volcano plot
volcano_1=${volcano_dir}/${out_label}.P0.01_log2FC1.volcano.pdf
volcano_2=${volcano_dir}/${out_label}.P0.01_log2FC2.volcano.pdf
volcano_3=${volcano_dir}/${out_label}.P0.1_log2FC1.volcano.pdf
volcano_4=${volcano_dir}/${out_label}.P0.1_log2FC2.volcano.pdf

Rscript ./DEG_volcano_plot.R -i $DESeq_3col -o ${volcano_1} --title_text $out_label --Pvalue 0.01 --log2FC 1
Rscript ./DEG_volcano_plot.R -i $DESeq_3col -o ${volcano_2} --title_text $out_label --Pvalue 0.01 --log2FC 2
Rscript ./DEG_volcano_plot.R -i $DESeq_3col -o ${volcano_3} --title_text $out_label --Pvalue 0.1 --log2FC 1
Rscript ./DEG_volcano_plot.R -i $DESeq_3col -o ${volcano_4} --title_text $out_label --Pvalue 0.1 --log2FC 2


