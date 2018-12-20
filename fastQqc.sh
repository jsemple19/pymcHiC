#! /bin/bash

## run QC programmes for fastq files (Pauvre and NanoQC)

source activate albacore_env

# create qc output directory
mkdir -p ../workspace/qc

# get list of all fastq files
fastqFiles=(../workspace/*/*/*.fastq)

#fq=${fastqFiles[0]}

for fq in ${fastqFiles[@]};
do
    ##  extract name elements for output naming

    # extract runID & fq file number from file name
    myBase=`basename $fq`
    myBase=`echo $myBase | tr -d ".fastq"`

    # extract barcode number from folder name
    bcode=`dirname $fq | cut -d"/" -f4`
    readType=`dirname $fq | cut -d"/" -f3`

    # create output directory based on readType barcode runID and file number 
    outDir=../workspace/qc/${readType}_${bcode}${myBase}/
    mkdir -p $outDir

    # assemble names for some of the output files
    outStats=${outDir}pauvreStats.txt
    outPlot=pauvreMarginPlot.png

    # run QC programmes
    pauvre stats -f $fq > ${outStats}
    pauvre marginplot -f $fq -o $outPlot
    mv pauvreMarginPlot.png $outDir  # move the png from current dir to qc output dir
    nanoQC $fq -o $outDir
done


# run Minion_qc
# source: https://github.com/roblanf/minion_qc
module load vital-it
module load R/3.5.1

MINIONQC=/home/pmeister/software/MinIONQC.R

Rscript ${MINIONQC} -i ../sequencing_summary.txt -o ../workspace/qc/ 


#library(IONiseR)
#library(ggplot2)
#library(gridExtra)

