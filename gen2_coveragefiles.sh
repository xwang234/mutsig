#! /usr/bin/env bash

#SBATCH -t 1-8
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=xwang234@fhcrc.org

#generate geneset, compute once after gen1,not parallele
wgstumors=( "$@" )

echo ${wgstumors[@]}

echo "find gene set.."
/fh/fast/dai_j/CancerGenomics/Tools/wang/mutsig/form_geneset_formutsig.R ${wgstumors[@]}		

