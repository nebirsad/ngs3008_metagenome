#!/bin/bash
#SBATCH --job-name=trim
#SBATCH --account=project_2005451
#SBATCH --time=00:15:00
#SBATCH --mem=6G
#SBATCH --partition=test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH -o /scratch/project_2005451/Nebir_Sad/metagenome/trim/output_script2_trim_%j.txt
#SBATCH -e /scratch/project_2005451/Nebir_Sad/metagenome/trim/errors_script2_trim_%j.txt

# Load modules
module load biokit multiqc

# Input/output directories
INPUTDIR=/scratch/project_2005451/Nebir_Sad/extra/data
OUTPUTDIR=/scratch/project_2005451/Nebir_Sad/extra/trimming/trim_output

# Create output directories
mkdir -p "$OUTPUTDIR"
mkdir -p "$OUTPUTDIR/qc_json"
mkdir -p "$OUTPUTDIR/qc_html"

# Full file names
R1="$INPUTDIR/AP16_R1.fastq.gz"
R2="$INPUTDIR/AP16_R2.fastq.gz"

# Check if both files exist
if [[ -f "$R1" && -f "$R2" ]]; then
    echo "✅ Found both input files:"
    echo " - $R1"
    echo " - $R2"
else
    echo "❌ One or both input files are missing. Exiting."
    exit 1
fi

# Run fastp
echo "🔧 Trimming with fastp..."
srun fastp \
    -i "$R1" \
    -I "$R2" \
    -o "$OUTPUTDIR/AP16_filtered_1P.fastq.gz" \
    -O "$OUTPUTDIR/AP16_filtered_2P.fastq.gz" \
    --unpaired1 "$OUTPUTDIR/AP16_filtered_1U.fastq.gz" \
    --unpaired2 "$OUTPUTDIR/AP16_filtered_2U.fastq.gz" \
    -g -w "$SLURM_CPUS_PER_TASK" -r -W 5 -M 25 \
    --detect_adapter_for_pe \
    --trim_front1 15 --trim_front2 15 --trim_tail1 2 --trim_tail2 2 -l 100 \
    -j "$OUTPUTDIR/qc_json/AP16.json" \
    -h "$OUTPUTDIR/qc_html/AP16.html"

echo "✅ Trimming complete."

# Run MultiQC if report exists
if [[ -f "$OUTPUTDIR/qc_json/AP16-60_S1_L002.json" ]]; then
    echo "📊 Running MultiQC..."
    multiqc -o "$OUTPUTDIR/qc_json/multiqc.rep" "$OUTPUTDIR/qc_json"
    echo "🎉 All done!"
else
    echo "⚠️ No fastp JSON found. Skipping MultiQC."
fi
