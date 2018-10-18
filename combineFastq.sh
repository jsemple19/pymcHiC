INFASTQS=${@:2}
OUTFASTA=$1
IDMATCH=$1.idmatch

awk \
        -v IDMATCH="$IDMATCH" \
        -v OUTFASTA="$OUTFASTA" \
        '
        BEGIN{
                C=0;
        	CUROUT = OUTFASTA"_"C".fa"}
        (FNR == 1) {
                ++FILENUM;
                READNUM = 1 }
        ((NR) % 4 == 1) {
                READID = "FN:"FILENUM";RN:"READNUM";uRN:"(NR-1)/4+1;
                print ">"READID"\t"FILENAME"\t"$0 | "gzip >" IDMATCH".gz";
                print "@"READID | "gzip >" OUTFASTA".fastq.gz"
                ++READNUM}
        !((NR) % 4 == 1) {
                print $0 | "gzip >" OUTFASTA".fastq.gz"}
        END { print C }' \
                        $INFASTQS 


