# pymcHiC
Scripts for mapping Nanopore HiC data

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

If you have not already done so, create a genome index npz file with makePyRefStr.sh (you need to change some settings in that file before running it).
