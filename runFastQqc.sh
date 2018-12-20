#! /bin/bash

## Allocate resources
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=8G

## job name
#SBATCH --job-name="fastQqc"

./fastQqc.sh
