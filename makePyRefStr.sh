#! /bin/bash


##SBATCH --mail-user=moushumi.das@izb.unibe.ch
##SBATCH --mail-type=none

## Allocate resources
#SBATCH --time=04:00:00
#SBATCH --mem-per-cpu=4G

## job name
#SBATCH --job-name="NPZ"



# Run specific
export DIR_WORKSPACE=/home/ubelix/izb/md17s996/13102018_hic ### Path for OUTPUT 
export DIR_GENOME=/home/ubelix/izb/md17s996/genomeVer/ws265 ### Path for OUTPUT
export FILE_GENOME=${DIR_GENOME}/c_elegans.PRJNA13758.WS265.genomic.fa

### Jenny specific settings - comment out
export DIR_WORKSPACE=/home/ubelix/izb/semple/labData/13102018_hic2/ ### Path for OUTPUT
export DIR_GENOME=/home/ubelix/izb/semple/genomeVer/ws260/sequence
export FILE_GENOME=${DIR_GENOME}/c_elegans.PRJNA13758.WS260.genomic.fa 
### end of Jenny specific settings

export FILE_INI=${DIR_WORKSPACE}/pymcHiC/Mc4C-Ini.tsv ### Path to INITIATION FIL

# index genome
module load vital-it
module add UHTS/Aligner/bwa/0.7.17; 

bwa index ${FILE_GENOME}


# Where the tool/scripts are located
export DIR_MC4C="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MC4CTOOL=$DIR_MC4C/mc4c.py

python mc4c.py refrestr \
	${FILE_INI} \
	${FILE_GENOME} \
	${DIR_GENOME}/refstr.npz
