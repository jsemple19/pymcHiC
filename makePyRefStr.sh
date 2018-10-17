#! /bin/bash


#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=end,fail

## Allocate resources
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=6G

## job name
#SBATCH --job-name="align HiC"

## array job
##SBATCH --array=1-10%5





# Run specific
export DIR_WORKSPACE=/home/ubelix/izb/md17s996/13102018_hic ### Path for OUTPUT 
export FILE_INI=${DIR_WORKSPACE}/pymc4c-master-AG/Mc4C-Ini.tsv ### Path to INITIATION FIL

# Where the tool/scripts are located
export DIR_MC4C="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MC4CTOOL=$DIR_MC4C/mc4c.py

python mc4c.py refrestr \
	${FILE_INI} \
	/home/ubelix/izb/md17s996/genomeVer/ws265/c_elegans.PRJNA13758.WS265.genomic.fa \
	/home/ubelix/izb/md17s996/genomeVer/ws265/refstr.npz
