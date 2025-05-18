#!/bin/bash

#SBATCH --job-name=QC

#SBATCH --account=project_2005451

#SBATCH --time=00:15:00

#SBATCH --mem=6G

#SBATCH --partition=test

#SBATCH --nodes=1

#SBATCH --ntasks=1

#SBATCH --cpus-per-task=2

#SBATCH -o /scratch/project_2005451/Nebir_Sad/metagenome/qc/output_script1_QC_%j.txt

#SBATCH -e /scratch/project_2005451/Nebir_Sad/metagenome/qc/errors_script1_QC_%j.txt



# Load required bioinformatics tools

module load biokit multiqc



# Define input and output directories

INPUTDIR=/scratch/project_2005451/Nebir_Sad/extra/data

OUTPUTDIR=/scratch/project_2005451/Nebir_Sad/extra/qc/qc_raw_output



# Create output directories if they don't exist

mkdir -p "$OUTPUTDIR"

mkdir -p "$OUTPUTDIR/multiqc.rep"



# Log file check

echo "Checking for input files in $INPUTDIR"

ls "$INPUTDIR"/*.fastq.gz || {

    echo "❌ No FASTQ files found in $INPUTDIR. Exiting."

    exit 1

}



# Run FastQC on all FASTQ files

echo "✅ Running FastQC..."

fastqc -t "$SLURM_CPUS_PER_TASK" -o "$OUTPUTDIR" "$INPUTDIR"/*.fastq.gz



# Check if FastQC actually created outputs

if ls "$OUTPUTDIR"/*_fastqc.zip >/dev/null 2>&1; then

    echo "✅ FastQC completed successfully."

else

    echo "⚠️ FastQC did not produce any results. Please check the input files."

    exit 1

fi



# Run MultiQC to summarize FastQC reports

echo "✅ Running MultiQC..."

multiqc -o "$OUTPUTDIR/multiqc.rep" "$OUTPUTDIR"



echo "🎉 QC pipeline complete. Check reports in $OUTPUTDIR and $OUTPUTDIR/multiqc.rep"


