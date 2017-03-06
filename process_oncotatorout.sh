#! /usr/bin/env bash

#only keep the necessary info of oncotator output to reduce the file size. not used.
maffile=${1?"the name of maffile"}
opt=${2?"1:mutect_extendedoutput"} #extened mutect output have different columns
#oncotator output

echo "process oncotator on $maffile"

if [[ ! -f $maffile && -f $maffile.gz ]];then gunzip $maffile.gz ; fi

output=$maffile.reduced

if [[ $opt -eq 0 ]]
then
	awk 'BEGIN { FS="\t"; OFS="\t" }; {if (NR>3 && $1 !="Unknown") {print $1,$5,$6,$7,$9,$10,$11,$12,$13,$16,$66,$159,$174,$269,$271,$279,$285}}' $maffile >$output
else
	awk 'BEGIN { FS="\t"; OFS="\t" }; {if (NR>3 && $1 !="Unknown") {print $1,$5,$6,$7,$9,$10,$11,$12,$13,$16,$66,$159,$176,$273,$277,$304,$314}}' $maffile >$output
fi


