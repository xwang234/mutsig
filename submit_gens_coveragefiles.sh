#! /usr/bin/env bash

wgstumors=(3A 11A 13A 15A 17A 25A 29A 33A 37A 41A)
mutectresdir=/fh/scratch/delete30/dai_j/henan/mutect
mutectextendedoutput=(0 0 1 1 1 1 1 1 1 1)

step=3
echo $step
if [[ $step -eq 1 ]]
then
  for ((i=0;i<${#wgstumors[@]};i++))
  do
    echo "sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/gen1_coveragefiles.sh ${wgstumors[$i]} $mutectresdir ${mutectextendedoutput[$i]}"
    sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/gen1_coveragefiles.sh ${wgstumors[$i]} $mutectresdir ${mutectextendedoutput[$i]}
    sleep 1
  done
fi

if [[ $step -eq 2 ]]
then
  sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/gen2_coveragefiles.sh ${wgstumors[@]}
fi

if [[ $step -eq 3 ]]
then
  for ((i=0;i<${#wgstumors[@]};i++))
  do
    echo "sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/gen3_coveragefiles.sh ${wgstumors[$i]}"
    sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/gen3_coveragefiles.sh ${wgstumors[$i]}
    sleep 1
  done
fi


