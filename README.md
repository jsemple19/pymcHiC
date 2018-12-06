# pymcHiC
Scripts for mapping Nanopore HiC data.
Move into the general directory for that sequencing experiment (not within the subfolders created by Nanopore for the test run and for various restarts of the run). Then type:
```
git clone https://github.com/jsemple19/pymcHiC.git
```

## Combining FastQ files
Copy the runCombine_example.sh file, removing the _example extension

```
cp runCombine_example.sh runCombine.sh
```

Using a text editor, modify runCombine.sh to list all the fastq files you wish to merge. Also change "expName" to the name of the current experiment (this will be used as a prefix for the filename of all your files).

This script uses combineFastq.sh to combine all the fastq files into a single file for downstream processes. It outputs the file in the ../out directory. The expName.fastq file contains all the sequences. The expName.idmerge.gz contains the old file name, the old sequence header and the new header info. The new header is in the format: ">FN:X;RN:Y;uRN:Z" where X is the file number, Y is the read number within that file and Z is the unique cumulative read number for all reads being processed.

## Inputing analysis parameters in Mc4C-Ini.tsv
Copy the Mc4C-Ini_example.sh file, removing the _example extension

```
cp Mc4C-Ini_example.tsv Mc4C-Ini.tsv
```
Using a text editor, modify Mc4C-Ini.tsv:

Also change "expName" to the name of the current experiment (this will be used as a prefix for the filename of all your files).
Change the exp_id (same as expName before).
Change the location of the merged fastq file.
Check the location of the genome sequence (this must be indexed with bwa before running this scripts).
Check all the other settings...

Open hpc_mc4c.sh and change the following settings:
DIR_WORKSPACE
FILE_INI
FILE_NPZ

### Indexing genome and restriction sites
Before running the scripts some preliminary processing must be done on the genome to index it with the aligner (bwa) and to index the location of the restriction enzyme sites(?) (in the refstr.npz file). This needs to be done only once for any genome version you use. Open the makePyRefStr.sh file and change the parameters for DIR_WORKSPACE, DIR_GENOME, FILE_GENOME and FILE_INI.
Then submit the makePyRefStr.sh to the cluster.
```
sbatch makePyRefStr.sh
```
Now you can submit the hpc_mc4c.sh to the cluster
```
sbatch hpc_mc4c.sh
```

## Converting the .npz file to .xslx and .csv
Open the runToExcelToCsv.sh script and change the expName.
Submit runToExcelToCsv.sh to the cluster:
```
sbatch runToExcelToCsv.sh
```

## Plotting results with R
Open the plotPymcHiC.R script and change the working directory, and the expName. Change the path variable to point to the results directory ("../out/" in this case).
Make sure the libraries mentioned at the top of the script are installed in R (BiocManager::install("nameOfPackage")).
Submit the runPlotPymcHiC.sh script to the cluster.
```
sbatch runPlotPymcHiC.sh
```
# output of script:
1. The script reads in the file path/expName.csv adds the read ID and saves it as **path/expName_withReadID.csv**
2. Adriana's plots (may be redundent with other plots below, but nicely plotted so kept them):
- **path/expName_FragAperChr.pdf** Barplot of number of fragments per chromosome
- **path/expName_FSizeperChr.pdf** Boxplot of size distribution of Fragments per Chr, wihtout and with outliers.
- **CircleSize.txt path/expName_CircleSize.pdf** number of reads containing number of fragments.
- **path/expName_ReadLeng_CircSize_2.pdf** distribution of read lengths for reads with a given number of fragments
3. Jenny's old plots. These take into account the barcode of the sample and makes separate plots for each barcode, or creates a pseudo barcode "0".  **path/expName_fragmentsPerRead.pdf**:
- first plot is histogram of the number of fragments per read
- second plot is the same as the first plot but expressed as frequency
- third plot is the same as the second, but zoomed in on reads with 1-10 fragment
4. Filter for reads with at least 2 fragments (multi-fragment reads) and plot the number of chromosomes present in a read (irrespective of how many fragments the come from. **expName_chrsPerRead.pdf**:
- first plot is the count of reads with 1,2,3 etc chromosomes represented in them
- second plot is the same as the first but represented as a frequency
These plots are split by barcode as well.
5. Plotting hops (=contacts). These plots do not yet take account of barcode. The table of hops contains the following data:
 contact table has several additional fields as follows:
- AlnChr2 - chromosome to which the second fragment aligns to
- hopType - within same chromosome (Intra) or between chromosomes (Inter)
- hopSize - minimal absolute distance between fragment ends
- sameStrand - are both fragments on the both strand?
- hopOri - orientation of hop:
       
       tandem:     -frag1-->  -frag2-->  or  <--frag2- <--frag1-
       
       inverted:   -frag2--> -frag1-->   or  <--frag1- <--frag2-
       
       convergent: -frag1--> <--frag2-   or  -frag2--> <--frag1-
       
       divergent:  <--frag2- -frag1-->   or  <--frag1- -frag2-->
       
- hopOverlap - do the aligned fragments overlap?
- firstChr - chr,strand,start and end of alignment of first fragment in pair
- secondChr - chr, strand, start and end of alignment of second fragment in pair

## Making HiC contact matrix plots
Open the makeContactMap.R script and change the working directory, and the expName. Change the path variable to point to the results directory ("../out/" in this case).
Make sure the libraries mentioned at the top of the script are installed in R (BiocManager::install("nameOfPackage")).

Submit the runMakeContactMap.sh to the cluster:
```
sbatch runMakeContactMap.sh
```
The script produces matrices of contacts of different binSizes: saved in files called **contactMatrix_resbinSizebp.RDS**. It also produced genome wide contact plots called **genomeWideContacts_resbinSizebp.pdf**, and plots chromosome by chromosome called **contactsByChr_resbinSizebp.pdf**

## getSeqDepthStats.sh
Script to get statistics of minimum, maximum, median and mean coverage over the genome. Note that median is probably the best measure of central tendency as the coverage is not expected to be normally distributed.
You need to run the script on a sam or bam file. If it is run on a sam file, it will convert it to bam, and sort it. The original sam file will be deleted as it takes up much more space than the bam binary version.
to run:
```
./getSeqDepthStats.sh ../out/nameOfSamFile.sam
```
The output will be **nameOfSamFile_depthStats.txt**
