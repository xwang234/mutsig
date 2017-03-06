#! /usr/bin/env bash
#SBATCH -t 2-8
#SBATCH --mem 32G
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

#wgstumors=(3A 11A 13A 15A 17A 25A 29A 33A 37A 41A)
sample=${1?"samplename"}


#oncotator=/fh/fast/dai_j/CancerGenomics/Tools/oncotator/oncotator/bin/oncotator
oncotator=/fh/fast/dai_j/CancerGenomics/Tools/oncotator1/oncotator-1.8.0.0/oncotator/bin/oncotator
oncotator_db=/fh/fast/dai_j/CancerGenomics/Tools/oncotator/oncotator_v1_ds_June112014


echo "create effect_category file..."
/fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/create_maf_effect_category1.sh $sample #generate the category file for maf, maf.annotated.reduced.cate
echo "write the file..."
/fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/write_coveragefile.R $sample
#./create_coverage_effectcategory.sh $sample #generate the coverage file for sample, coverage.cate
