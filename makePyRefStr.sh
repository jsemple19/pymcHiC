#! /bin/bash


#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=none

## Allocate resources
#SBATCH --time=04:00:00
#SBATCH --mem-per-cpu=4G

## job name
#SBATCH --job-name="NPZ"



# Run specific
export DIR_WORKSPACE=/home/ubelix/izb/md17s996/13102018_hic ### Path for OUTPUT 
export DIR_WORKSPACE=/home/ubelix/izb/semple/labData/13102018_hic2/ ### Path for OUTPUT
export DIR_GENOME=/home/ubelix/semple/genomeVer/ws260 
export FILE_INI=${DIR_WORKSPACE}/pymcHiC/Mc4C-Ini.tsv ### Path to INITIATION FIL

# Where the tool/scripts are located
export DIR_MC4C="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MC4CTOOL=$DIR_MC4C/mc4c.py

python mc4c.py refrestr \
	${FILE_INI} \
	${DIR_GENOME}/c_elegans.PRJNA13758.WS260.genomic.fa \
	${DIR_GENOME}/refstr.npz
