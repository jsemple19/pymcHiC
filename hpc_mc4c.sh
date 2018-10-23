#!/bin/bash
# hpc_rtcc analysis modified by AG in supervision of RS . Folder with Initial files is already present (fastq, indexed genome.fa, Initiation.tsv)

#SBATCH --mail-user=user@izb.unibe.ch
#SBATCH --mail-type=none

## Allocate resources
#SBATCH --time=06:00:00
#SBATCH --mem-per-cpu=4G

## job name
#SBATCH --job-name="alignHiC"


module load vital-it
module add UHTS/Aligner/bwa/0.7.17
module add UHTS/Aligner/bowtie2/2.3.1 

set -e

## Debug mode?
export DEBUG_MODE="set -o xtrace"
$DEBUG_MODE

# Run specific
export DIR_WORKSPACE=/home/ubelix/izb/md17s996/13102018_hic2 ### Path for OUTPUT 
export FILE_INI=${DIR_WORKSPACE}/pymcHiC/Mc4C-Ini.tsv ### Path to INITIATION FILE
export FILE_NPZ=/home/ubelix/izb/md17s996/genomeVer/ws265/refstr.npz


### Jenny specific settings
#export DIR_WORKSPACE=/home/ubelix/izb/semple/labData/Moushumi/13102018_hic2 ### Path for OUTPUT 
#export FILE_INI=${DIR_WORKSPACE}/pymcHiC/Mc4C-Ini.tsv ### Path to INITIATION FILE
#export FILE_NPZ=/home/ubelix/izb/semple/genomeVer/ws260/sequence/refstr.npz
### end of Jenny specific settings

#External tools used in the pipeline
#module add UHTS/Aligner/bwa/0.7.15
#module add UHTS/Aligner/bowtie2/2.3.1 ## In Roy's is 2.2.6, but it is not in Vital-IT

# Where the tool/scripts are located
export DIR_MC4C="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MC4CTOOL=$DIR_MC4C/mc4c.py

# Directories for input/output
SOURCE_FASTQ=`awk '/^src_fastq/{$1="";print $0}' $FILE_INI`
export FILE_FASTQ=`ls $SOURCE_FASTQ`
export EXP_ID=`awk '/^exp_id/{print $2}' $FILE_INI`
export FILE_REF=`awk '/^ref_path/{print $2}' $FILE_INI`
export DIR_OUT=$DIR_WORKSPACE/out
export FILE_OUT=$DIR_OUT/$EXP_ID
export DIR_LOG=$DIR_OUT/log/

# Setup for submission variables
QSUBVARS="-V -e $DIR_LOG -o $DIR_LOG"
HOLD_ID=-1

# Initialization
mkdir -p $DIR_WORKSPACE $DIR_LOG

# Local: Determine amount of reads in the original fastq file 
FASTQ_NL=`wc -l $FILE_FASTQ | tail -n 1 | awk '{print $1}'`
READSPERFILE=999999999
export LINESPERFILE=$(($READSPERFILE*4))
export NUM_TASKS=$((($FASTQ_NL+$LINESPERFILE-1)/$LINESPERFILE))

HOLD_ID_LIST=""

#echo $((${FASTQWCL}/4)) Reads found in $FILE_FASTQ
#echo Becomes $SPLITFILESNUM files
export FILE_SOURCE=block
		
bash $DIR_MC4C/sge_scripts/splitfq.sh
bash $DIR_MC4C/sge_scripts/splitre-AG.sh
bash $DIR_MC4C/sge_scripts/mergere.sh
bash $DIR_MC4C/sge_scripts/bwa-AG.sh

python $DIR_MC4C/mc4c.py export \
       ${FILE_INI} \
       ${FILE_OUT}.bwa.sam \
       ${FILE_NPZ} \
       ${FILE_OUT}.np

