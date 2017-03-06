#!/usr/bin/env bash
#SBATCH -t 1-0
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

arguments=( "$@" )

outputpreface=${arguments[0]}
mutectfolder=${arguments[1]}
mutsigoutputfolder=${arguments[2]}
((numarg=$#))
let numsamples=($numarg-3)/2
declare -a wgstumors
declare -a mutectextendedopt
for ((i=3;i<=$numsamples+2;i++))
do
	wgstumors[(($i-3))]=${arguments[$i]}
done
for ((i=$numsamples+3;i<$#;i++))
do
	mutectextendedopt[(($i-$numsamples-3))]=${arguments[$i]}
done

echo $outputpreface
echo $mutectfolder
echo ${wgstumors[@]}
echo ${mutectextendedopt[@]}

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

#generate coverage file,not used here
#tmpfile=tmp.txt
#if [ -f $tmpfile ];then rm $tmpfile;fi

#cut -f1-3 $reference >$tmpfile

#for file in SRR*[0-9].coverage
#do
#	paste $tmpfile $file >$coveragefile
#	cp $coveragefile $tmpfile
#done



if [ -f $maffile ];then rm $maffile;fi

#generate maf file
echo "generate maf"
for ((i=0;i<${#wgstumors[@]};i++))
do
	if [ ! -f $mutectfolder/${wgstumors[$i]}.Mutect_out_keep.txt ]
	then
		grep -v REJECT $mutectfolder/${wgstumors[$i]}.Mutect_out.txt > $mutectfolder/${wgstumors[$i]}.Mutect_out_keep.txt
	fi
	if [ ! -f ${wgstumors[$i]}.maf_keep.annotated ]
	then
		$oncotator -v --db-dir $oncotator_db $mutectfolder/${wgstumors[$i]}.Mutect_out_keep.txt ${wgstumors[$i]}.maf_keep.annotated hg19
	fi	
	/fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/process_oncotatorout.sh $mutsigoutputfolder/${wgstumors[$i]}.maf_keep.annotated ${mutectextendedopt[$i]}
	cat $mutsigoutputfolder/${wgstumors[$i]}.maf_keep.annotated.reduced >> $maffile
done

echo "run mutsig..."

cd $mutsigcmdfolder
module load matlab/R2013b
#matlab -nodesktop -nodisplay -nojvm -r "MutSigCV('$maffile','$coveragefile','$covariatesfile','$outputfile1');exit;"
matlab -nodesktop -nodisplay -nojvm -r "MutSigCV('$maffile','$coveragefile','$covariatesfile','$outputfile','$dictfile','$hg19file');exit;"
cd $mutsigoutputfolder

#MutSigCV('./nobarrett.maf','./exome_full192.coverage.txt','exampledata/gene.covariates.txt','./nobarrett_mutsigout.txt')
#MutSigCV('/mnt/rhodium/scratch/delete30/dai_j/test/mutsig/allinfo.reduced.maf','/mnt/rhodium/scratch/delete30/dai_j/test/mutsig/full192.coverage.txt','exampledata/gene.covariates.txt','./allinfo_mutsigout.txt')
