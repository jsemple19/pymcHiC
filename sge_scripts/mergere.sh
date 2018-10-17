#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=end,fail

## Allocate resources
#SBATCH --time=00:24:00
#SBATCH --mem-per-cpu=6G
## array job
#SBATCH --array=1-1

##$ -l h_rt=00:30:00
##$ -l h_vmem=1G


$DEBUG_MODE

FILELIST=""
for INDEX in `seq 1`;
do
	FILELIST="$FILELIST ${FILE_OUT}_${INDEX}.splitre.fq"
done

cat ${FILELIST} | gzip > ${FILE_OUT}.splitre.fq.gz
