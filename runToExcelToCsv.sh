#! /bin/bash

##SBATCH --mail-user=moushumi.das@izb.unibe.ch
##SBATCH --mail-type=none

## Allocate resources
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G

## job name
#SBATCH --job-name="npz2xlsx&csv"

## array job
##SBATCH --array=1-10%5

expName=13102018_hic2

npzFile=../out/${expName}.np.npz

outFile=../out/${expName}.xlsx

python to_excel.py $npzFile $outFile

outFile=../out/${expName}.csv

python to_csv.py $npzFile $outFile

