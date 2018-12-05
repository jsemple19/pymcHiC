#! /bin/bash
#### script to convert sam file to bam file

# load necessary modules
module load vital-it
module add UHTS/Analysis/samtools/1.8;
module load R/3.5.1

# read in samfile name from command line
inFile=$1

# get file name extension
extension="${inFile##*.}"

# if it is a sam file, convert it to bam
if [[ ${extension} == "sam" ]]
then
	echo "sam file being converted"
	# extract filename without extension
	bname=${inFile%.sam}
	# convert sam file to bam file
	samtools view -b ${inFile} -o ${bname}.bam
	rm ${inFile}  # delete sam file as it just takes up space
	inFile=${bname}.bam
fi	

# get file name extension
extension="${inFile##*.}"

# if it is a bam file, but not sorted, sort it
if [[ ${extension} == "bam" ]] && [[ ${inFile} != *".sort.bam" ]]
then
	echo "bam file being sorted"
	# extract filename without extension
	bname=${inFile%.bam}
	# sort bam file
	samtools sort ${bname}.bam -o ${bname}.sort.bam
	rm ${inFile}  # keep only sorted bam
	inFile=${bname}.sort.bam
fi



if [[ ${inFile} == *".sort.bam" ]]
then
	echo "calculating read depth statistics on sorted bam file"
	# extract filename without extension
	bname=${inFile%.sort.bam}
else
	echo "should be a .sam or .bam file"
fi


# construct name for read depth stats
depthFile=${bname}_depthStats.txt
	
# extract read depth for every base in the genome
samtools depth -a ${bname}.sort.bam | cut -f3 > tempFile.txt

# calculate overall stats for the genome	
awk 'BEGIN { print "min\tmax\tmedian\tmean" }'> ${depthFile}
Rscript -e 'd<-scan("stdin", quiet=TRUE)' \
          -e 'cat(min(d), max(d), median(d), mean(d), sep="\t")' < tempFile.txt >> ${depthFile}
awk 'BEGIN { print "" }'>> ${depthFile}

rm tempFile.txt
