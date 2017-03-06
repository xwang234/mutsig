#!/usr/bin/env bash
#SBATCH -t 1-0
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

arguments=( "$@" )

outputpreface=${arguments[0]}
varscanfolder=${arguments[1]}
mutsigoutputfolder=${arguments[2]}
echo ${arguments[@]}
((numarg=$#))

echo $numarg
let numsample=($numarg-3)/2
echo $numsample
declare -a wgstumors
for ((i=3;i<=$numsample+2;i++))
do
  wgstumors[(($i-3))]=${arguments[$i]}
done

declare -a mutationfiles
for ((i=$numsample+3;i<=$numarg;i++))
do
  mutationfiles[$i-$numsample-3]=${arguments[$i]}
done


echo $outputpreface
echo $varscanfolder

echo ${wgstumors[@]}
echo ${mutationfiles[@]}

echo ${wgstumors[0]}
echo ${mutationfiles[0]}
sleep 30

oncotator=/fh/fast/dai_j/CancerGenomics/Tools/oncotator1/oncotator-1.8.0.0/oncotator/bin/oncotator
oncotator_db=/fh/fast/dai_j/CancerGenomics/Tools/oncotator/oncotator_v1_ds_June112014
#mutsig configure data folder:
mutsigfolder=/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.4
#mutsigcmdfolder=/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.4
#the newest version
mutsigcmdfolder=/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.41
#coveragefile=./full192.coverage.txt
coveragefile=$mutsigfolder/exome_full192.coverage.txt
covariatesfile=$mutsigfolder/gene.covariates.txt
dictfile=$mutsigfolder/mutation_type_dictionary_file.txt
hg19file=$mutsigfolder/chr_files
#outputfile1=$mutsigoutputfolder/${outputpreface}_a.mutsiga.txt
#outputfile2=$mutsigoutputfolder/${outputpreface}_b.mutsiga.txt
outputfile=$mutsigoutputfolder/${outputpreface}.mutsiga.txt
#reference=/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.4/exome_full192.coverage.txt
maffile=$mutsigoutputfolder/${outputpreface}.maf


if [ -f $maffile ];then rm $maffile;fi

#generate maf file
echo "oncotator..."
for ((i=0;i<${#wgstumors[@]};i++))
do
  echo ${wgstumors[$i]}
  #if [ ! -f ${wgstumors[$i]}.somatic.snp.Somatic.annotated ]
  #then
    #need to change the file column tiles to include chr ref_allele and alt_allele
    echo -e "chr\tposition\tref_allele\talt_allele\tnormal_reads1\tnormal_reads2\tnormal_var_freq\tnormal_gt\ttumor_reads1\ttumor_reads2\ttumor_var_freq\ttumor_gt\tsomatic_status\tvariant_p_value\tsomatic_p_value\ttumor_reads1_plus\ttumor_reads1_minus\ttumor_reads2_plus\ttumor_reads2_minus\tnormal_reads1_plus\tnormal_reads1_minus\tnormal_reads2_plus\tnormal_reads2_minus" >tmp_${wgstumors[$i]}.txt
    awk '{if (NR>1) print }' ${mutationfiles[$i]} >> tmp_${wgstumors[$i]}.txt
    $oncotator -v --db-dir $oncotator_db tmp_${wgstumors[$i]}.txt ${mutationfiles[$i]}.annotated hg19
    rm tmp_${wgstumors[$i]}.txt
  #fi
done

if [ -f $maffile ];then rm $maffile;fi
for ((i=0;i<${#wgstumors[@]};i++))
do
  /fh/fast/dai_j/CancerGenomics/Tools/wang/mutation/process_varscan_oncotatorout.sh ${mutationfiles[$i]}.annotated ${wgstumors[$i]}
  cat ${mutationfiles[$i]}.annotated.reduced >> $maffile
done

echo "run mutsig..."

cd $mutsigcmdfolder
module load matlab/R2013b
#matlab -nodesktop -nodisplay -nojvm -r "MutSigCV('$maffile','$coveragefile','$covariatesfile','$outputfile1');exit;"
matlab -nodesktop -nodisplay -nojvm -r "MutSigCV('$maffile','$coveragefile','$covariatesfile','$outputfile','$dictfile','$hg19file');exit;"
cd $mutsigoutputfolder

#MutSigCV('./nobarrett.maf','./exome_full192.coverage.txt','exampledata/gene.covariates.txt','./nobarrett_mutsigout.txt')
#MutSigCV('/mnt/rhodium/scratch/delete30/dai_j/test/mutsig/allinfo.reduced.maf','/mnt/rhodium/scratch/delete30/dai_j/test/mutsig/full192.coverage.txt','exampledata/gene.covariates.txt','./allinfo_mutsigout.txt')
