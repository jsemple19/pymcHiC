#! /bin/bash
## script to arrange all fastq files into batches for analysis. Folders will be created for
## each barcode of interest for both passed and failed reads (e.g. pass_barcode01 or fail_barcode01).  
## Folders will also be created for all misclassified (barcode not in barcodesOfInterest) and 
## unclassified reads split between pass_unclass and fail_unclass. 

# add here a list of the barcodes you used for your samples
barcodesOfInterest=( barcode12 )
barcodesOfInterest=( barcode12 barcode08 )

###########
# Collecting reads from barcodes that were used
###########

# scroll through all barcodes you have used and take properly classified reads and move them
# to new folders
for b in ${barcodesOfInterest[@]};
do
	if [ -d ../workspace/pass/${b} ];
	then
		mkdir -p ../pass_${b} 
		cp ../workspace/pass/${b}/*.fastq ../pass_${b}/
		gzip ../pass_${b}/*.fastq; 
	fi

        if [ -d ../workspace/fail/${b} ];
	then
		mkdir -p ../fail_${b}
        	cp ../workspace/fail/${b}/*.fastq ../fail_${b}/
		gzip ../fail_${b}/*.fastq; 
	fi
done


###########
# Collecting mis- and unclassified reads from pass folder
###########

# get list of folders for all mis- and un-classified reads (i.e excluding the barcodes of interest)
passUnclass=( `find ../workspace/pass/barcode* -type d | grep -v $barcodesOfInterest` )

# get list of all unique filenames in mis- and un-classified read folders in pass folder
uniquePassFiles=( `find ${passUnclass[@]} -name  *.fastq | cut -d"/" -f5 | sort -u` )
mkdir -p ../pass_unclass

# concatenate them together
for f in ${uniquePassFiles[@]};
do 
	files=( `find ${passUnclass[@]} -name ${f}` )
	if [ ${#files[@]} -gt 0 ];
	then
		cat ${files[@]} > ../pass_unclass/${f}
		gzip ../pass_unclass/${f};
	fi
done



###########
# Collecting mis- and unclassified reads from fail folder
###########

# get list of folders for all mis- and un-classified reads (i.e excluding the barcodes of interest)
failUnclass=( `find ../workspace/fail/barcode* -type d | grep -v $barcodesOfInterest` )

# get list of all unique filenames in mis- and un-classified read folders in fail folder
uniqueFailFiles=( `find ${failUnclass[@]} -name  *.fastq | cut -d"/" -f5 | sort -u` )
mkdir -p ../fail_unclass

# concatenate them together
for f in ${uniqueFailFiles[@]};
do
        files=( `find ${failUnclass[@]} -name ${f}` )
        if [ ${#files[@]} -gt 0 ];
        then
                cat ${files[@]} > ../fail_unclass/${f}
                gzip ../fail_unclass/${f};
        fi
done

