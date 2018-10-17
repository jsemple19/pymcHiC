#! /bin/bash

#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=end,fail

## Allocate resources
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=6G

## job name
#SBATCH --job-name="npz2xlsx&csv"

## array job
##SBATCH --array=1-10%5


npzFile=../out/13102018_hic3.np.npz

outFile=../out/13102018_hic3.xlsx

python to_excel.py $npzFile $outFile

outFile=../out/13102018_hic3.csv

python to_csv.py $npzFile $outFile

