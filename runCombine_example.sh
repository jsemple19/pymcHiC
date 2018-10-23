#! /bin/bash

#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=none

## Allocate resources
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G

## job name
#SBATCH --job-name="mergeFastQ"

mkdir ../out
expName='13102018_hic2'

# first item after combineFasta.sh is the prefix of the target merged file
# all other arguments are fastq files to be merged
./combineFastq.sh ${expName} \
        ../20181012_1347_hic_3/fastq/pass/*.fastq \
        ../20181012_1349_hic_3/fastq/pass/*.fastq \
        ../20181012_1409_hic_4/fastq/pass/*.fastq \
        ../20181012_1411_hic_4/fastq/pass/*.fastq \
        ../20181013_1221_hic_5/fastq/pass/*.fastq \
        ../20181013_1223_hic_5/fastq/pass/*.fastq

mv ${expName}*.gz ../out/
gunzip ../out/${expName}*.fastq.gz
