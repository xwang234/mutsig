#!/usr/bin/env bash

outputpreface=test_henan
mutectfolder=/fh/scratch/delete30/dai_j/escc/mutect
mutsigoutputfolder=/fh/scratch/delete30/dai_j/henan/mutsig
wgstumors=(3A 11A 13A 15A 17A 25A 29A 33A 37A 41A)
mutectfolder=/fh/scratch/delete30/dai_j/henan/mutect
mutectextendedopt=(0 0 1 1 1 1 1 1 1 1)


sbatch /fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/mutsig_usefull192coverage.sh $outputpreface $mutectfolder $mutsigoutputfolder ${wgstumors[@]} ${mutectextendedopt[@]}

