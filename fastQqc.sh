#! /bin/bash

## run QC programmes for fastq files (Pauvre and NanoQC)

source activate albacore_env

mkdir -p ../workspace/qc

fastqFiles=(../workspace/pass/*/*.fastq)

#fq=${fastqFiles[0]}

for fq in ${fastqFiles[@]};
do
    # extract name elements for output naming
    myBase=`echo $fq | tr -d ".fastq"`
    bcode=`dirname $fq | cut -d"/" -f4`
    outDir=../workspace/qc/${bcode}${myBase}/
    mkdir -p $outDir
    outStats=${outDir}pauvreStats.txt
    outPlot=pauvreMarginPlot.png
    # run QC programmes
    pauvre stats -f $fq > ${outStats}
    pauvre marginplot -f $fq -o $outPlot
    mv pauvreMarginPlot.png $outDir  # move the png from current dir to qc output dir
    nanoQC $fq -o $outDir
done

