#! /bin/bash

#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=end,fail

## Allocate resources
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=6G

## job name
#SBATCH --job-name="mergeFastQ"


./combineFastq.sh 13102018_hic2 ../20181012_1411_hic_4/fastq/pass/*.fastq  \
	../20181012_1347_hic_3/fastq/pass/*.fastq \
	../20181012_1349_hic_3/fastq/pass/*.fastq \
	../20181012_1409_hic_4/fastq/pass/*.fastq \
	../20181012_1411_hic_4/fastq/pass/*.fastq \
	../20181013_1221_hic_5/fastq/pass/*.fastq \
	../20181013_1223_hic_5/fastq/pass/*.fastq

rm 13102018_hic2*.fa
mv 13102018_hic2*.gz ../out/
gunzip ../out/13102018_hic2*.fastq.gz
