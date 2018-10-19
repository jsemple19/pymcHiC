##SBATCH --mail-user=moushumi.das@izb.unibe.ch
##SBATCH --mail-type=none

## Allocate resources
##SBATCH --time=01:00:00
##SBATCH --mem-per-cpu=4G

$DEBUG_MODE

echo "Source: [$FILE_FASTQ]"
echo "Output: [$FILE_OUT]"
echo "Split size: [$LINESPERFILE] lines"


awk \
	-v OUTFASTQ="$FILE_OUT" \
	-v LINESPERFILE="$LINESPERFILE" \
	'
	BEGIN {
		C=1;
		READNUM = 1;
		CUROUT = OUTFASTQ"_"C".block.fa";
		ALTOUT = OUTFASTQ"_"C".block.fq" }
	(FNR == 1) {
		++FILENUM }
	((FNR) % 4 == 1 ) {
		OLDID = $0 } 
	((FNR) % 4 == 2) {
		READID = "Fl.Id:"FILENUM";Rd.Id:"READNUM";Rd.Ln:"length($0)";oldID:"OLDID;
		print ">"READID > CUROUT;
		print ">"READID > ALTOUT;
	        ++READNUM;
		print $0 > CUROUT }
	((FNR) % 4 != 1) {
		print $0 > ALTOUT }
	((FNR % LINESPERFILE) == 0) {
		++C;
		CUROUT = OUTFASTQ"_"C".block.fa"
		ALTOUT = OUTFASTQ"_"C".block.fq" }
	' $FILE_FASTQ

# TODO: Add remove read if less than 500 bp:
