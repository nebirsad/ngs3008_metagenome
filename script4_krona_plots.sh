#!/bin/bash
#SBATCH --job-name=Krona_gpu
#SBATCH --account=project_2005451
#SBATCH --time=00:15:00
#SBATCH --mem=12G
#SBATCH --partition=gputest
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH -o ../%u/output_Krona_%j.txt
#SBATCH -e ../%u/errors_Krona_%j.txt
#SBATCH --gres=gpu:v100:1,nvme:10

echo "Job starts" 
echo $(date +%d%b%Y_%H%m)

cd $LOCAL_SCRATCH

# Load necessary modules: biokit (for bioinformatics tools) and krona (for interactive visualizations)
module load biokit krona 

# Set input and output directories
# INPUTDIR points to the Kraken and Bracken results from previous analysis
# OUTPUTDIRKR is the directory where the Kraken Krona charts will be stored
# OUTPUTDIRBR is the directory for the Bracken Krona charts
# TAXONOMY is the path to the Kraken taxonomy database

# To create taxonomy file from updated/custom kraken database to use with krona 
# run within the directory where kraken database is located
# python /projappl/project_2005451/python_code/make_ktaxonomy.py \
# --nodes nodes.dmp --names names.dmp --seqid2taxid seqid2taxid.map -o krakentaxonomy.tab
# make_ktaxonomy.py is from KrakenTools by Jen Lu
# https://github.com/jenniferlu717/KrakenTools/blob/master/make_ktaxonomy.py

INPUTDIR=/scratch/project_2005451/Nebir_Sad/extra/kraken/kraken_results
TMPKR=./kraken
TMPBR=./braken
OUTPUTDIRKR=/scratch/project_2005451/Nebir_Sad/extra/krona/krona_charts/kraken
OUTPUTDIRBR=/scratch/project_2005451/Nebir_Sad/extra/krona/krona_charts/braken
TAXONOMY=/scratch/project_2005451/krknnt.db

mkdir -p $TMPKR
mkdir -p $TMPBR
mkdir -p $OUTPUTDIRKR
mkdir -p $OUTPUTDIRBR

# Use the ktImportTaxonomy tool from the Krona package to generate interactive Krona charts
# Kraken output is in the form of a report (.PE.rep.txt), and Bracken output is in a specific species report (.rep_bracken_species.txt)

# Kraken Krona chart generation
# ktImportTaxonomy takes the Kraken report files as input and creates a visualization
# Options:
# -o : Specifies the output file for the Krona chart in HTML format
# -t 5 : Specifies the column in the Kraken report that contains the taxonomy ID (TaxID) of the assigned taxon (column 5)
# -s 3 : Specifies the column that contains the score (number of reads assigned to a taxon) (column 3)
# -m 2 : Specifies the column that contains the magnitude, which is the total number of reads assigned to a taxon (column 2)
# -tax : Provides the path to the Kraken taxonomy database


ktImportTaxonomy -o $TMPKR/honey.multi-krona.kraken.html \
-t 5 -s 3 -m 2 $INPUTDIR/*.PE.rep.txt \
-tax $TAXONOMY \

# Compress the resulting output directories into zip files to save space and ease sharing
# This step zips the Kraken and Bracken directories into compressed archives

zip -r $OUTPUTDIRKR/krona.kraken.zip $TMPKR

# Bracken Krona chart generation
# Bracken output is in a different format (.rep_bracken_species.txt), but the same tool can be used for visualization
# The same parameters apply to the Bracken files

ktImportTaxonomy -o $TMPBR/honey.multi-krona.braken.html \
-t 5 -s 3 -m 2 $INPUTDIR/*.rep_bracken_species.txt \
-tax $TAXONOMY

# Compress the resulting output directories into zip files to save space and ease sharing
# This step zips the Kraken and Bracken directories into compressed archives

zip -r $OUTPUTDIRBR/krona.braken.zip $TMPBR

echo "Job efficiency"
seff $SLURM_JOBID
echo "Time and memory usage:"
sacct -o reqmem,maxrss,averss,elapsed,alloccpus -j $SLURM_JOBID
echo $(date +%d%b%Y_%H%m)
echo "Job finished"

