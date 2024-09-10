#!/usr/bin/env bash


fq_r1=${1//,/ }
fq_r2=${2//,/ }
out_dir=$3
out_label=$4
ht2_index=$5
cpu=$6
gtf=$7

if [ ! -d ${out_dir} ]
then
    mkdir ${out_dir}
else
    echo ${out_dir}" exist!!!"
fi


out_dir=`cd $out_dir|pwd`/${out_dir}
ht2_dir=${out_dir}/hisat2
str_dir=${out_dir}/stringtie
htseq_dir=${out_dir}/htseq-count

mkdir -p ${ht2_dir}/logs ${str_dir}/logs ${htseq_dir}/logs

### hisat2_mapping
echo `date +%F": "%X`,": Hisat2 mapping ${out_label}!"
hisat2 -p $cpu --dta -x ${ht2_index} -1 ${fq_r1} -2 ${fq_r2} -S ${ht2_dir}/${out_label}.sam 2> ${ht2_dir}/logs/${out_label}.log

echo `date +%F": "%X`,": Sam to Bam ${out_label}!"
sam=${ht2_dir}/${out_label}.sam 
cpu=$cpu
flag=${sam%.sam}
bam=${flag}.bam
sorted_bam=${flag}.sorted.bam
samtools view -bS -@ $cpu  $sam > $bam
samtools sort -T $flag -@ $cpu -o $sorted_bam $bam
samtools index $sorted_bam
rm $bam
rm ${ht2_dir}/${out_label}.sam
###

echo `date +%F": "%X`,": StringTie ${out_label}!"
cd ${str_dir}
stringtie -p $cpu -e -G ${gtf} -o ${out_label}.gtf -A ${out_label}.tab $sorted_bam 2>${str_dir}/logs/${out_label}.log

echo `date +%F": "%X`,": htseq-count ${out_label}!"
cd ${htseq_dir}
htseq-count -f bam -s no -r pos ${bam} $gtf > ${htseq_dir}/${out_label}.count 2>${htseq_dir}/logs/${out_label}.log

cd ${out_dir}
echo `date +%F": "%X`,": Finished ${out_label}!"



