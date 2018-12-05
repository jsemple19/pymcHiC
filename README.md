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
