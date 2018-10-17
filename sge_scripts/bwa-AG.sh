#SBATCH --mail-user=moushumi.das@izb.unibe.ch
#SBATCH --mail-type=end,fail

## Allocate resources
#SBATCH --time=08:00:00
#SBATCH --mem-per-cpu=6G
## array job
##SBATCH --array=1-1%5


##$ -l h_rt=08:00:00
##$ -l h_vmem=32G
##$ -pe threaded 12
$DEBUG_MODE

bwa bwasw \
	-b 5 \
	-q 2 \
	-r 1 \
	-z 10 \
	-T 15 \
	-t 12 \
 	-f ${FILE_OUT}.bwa.sam \
	$FILE_REF \
	${FILE_OUT}.splitre.fq.gz
