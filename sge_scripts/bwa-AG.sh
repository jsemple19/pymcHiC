## Allocate resources
##SBATCH --time=04:00:00
##SBATCH --mem-per-cpu=4G

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
