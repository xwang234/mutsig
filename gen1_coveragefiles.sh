#! /usr/bin/env bash

#SBATCH -t 1-8
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

#parallele computing to generate effect category data
#wgstumors=(3A 11A 13A 15A 17A 25A 29A 33A 37A 41A)

sample=${1?"samplename"}
mutectresdir=${2?"mutectdir"} #/fh/scratch/delete30/dai_j/henan/mutect
opt=${3?"1:mutectexendedoutupt"}
#oncotator=/fh/fast/dai_j/CancerGenomics/Tools/oncotator/oncotator/bin/oncotator
oncotator=/fh/fast/dai_j/CancerGenomics/Tools/oncotator1/oncotator-1.8.0.0/oncotator/bin/oncotator
oncotator_db=/fh/fast/dai_j/CancerGenomics/Tools/oncotator/oncotator_v1_ds_June112014

echo "annotation..."
$oncotator -v --db-dir $oncotator_db $mutectresdir/$sample.Mutect_out.txt $sample.maf.annotated hg19

echo "process annotation..."
/fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/process_oncotatorout.sh $sample.maf.annotated $opt #generate maf.annotated.reduced,the reduced maf files

gzip $sample.maf.annotated

