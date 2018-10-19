##SBATCH --mail-user=moushumi.das@izb.unibe.ch
##SBATCH --mail-type=none

## Allocate resources
##SBATCH --time=01:00:00
##SBATCH --mem-per-cpu=4G


$DEBUG_MODE

FILELIST=""
for INDEX in `seq 1`;
do
	FILELIST="$FILELIST ${FILE_OUT}_${INDEX}.splitre.fq"
done

cat ${FILELIST} | gzip > ${FILE_OUT}.splitre.fq.gz
