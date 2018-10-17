#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=end,fail

## Allocate resources
#SBATCH --time=00:24:00
#SBATCH --mem-per-cpu=6G
## array job
##SBATCH --array=1-1

##$ -l h_rt=00:30:00
##$ -l h_vmem=1G
$DEBUG_MODE
### To fix the error of given by the hpc_rtcc.sh (~28/12/17)
export SGE_TASK_ID=1

if [ ! -n "FILE_SOURCE" ]; then
    FILE_SOURCE=splitpr
fi

python $MC4CTOOL \
	splitreads \
	$FILE_INI \
	${FILE_OUT}_${SGE_TASK_ID}.${FILE_SOURCE}.fq \
	${FILE_OUT}_${SGE_TASK_ID}.splitre.fq
