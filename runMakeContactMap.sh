#! /bin/bash

##SBATCH --mail-user=moushumi.das@izb.unibe.ch
##SBATCH --mail-type=none

## Allocate resources
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G

## job name
#SBATCH --job-name="plot"


module load vital-it
module load R/3.5.1

R CMD BATCH makeContactMap.R
