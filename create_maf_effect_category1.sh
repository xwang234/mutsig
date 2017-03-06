#! /usr/bin/env bash
#create category and effect(noncoding/silent/nonsilent/null) for annoted files, used for generating coverage files


dictfile=/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.4/mutation_type_dictionary_file.txt

sample=${1?"samplename"}
echo $sample

maffile=$sample.maf.annotated.reduced
echo $maffile
output=$sample.maf.annotated.reduced.cate
#gene=($(awk 'BEGIN {FS="\t" };{ if (NR>4) {print $1}}' $maffile))
#variant=($(awk 'BEGIN {FS="\t" };{if (NR>4) {print $9}}' $maffile))
#ref=($(awk 'BEGIN {FS="\t"};{if (NR>4) {print $11}}' $maffile))
#alt=($(awk 'BEGIN {FS="\t"};{if (NR>4) {print $13}}' $maffile))
#context=($(awk 'BEGIN {FS="\t"};{if (NR>4) {print $66}}' $maffile))
covered=($(awk 'BEGIN {FS="\t"};{if (NR>1) {print $13}}' $maffile))
#only count mutations with enough coverage
gene=($(awk 'BEGIN {FS="\t" };{ if (NR>1 && $13 =="COVERED" ) {print $1}}' $maffile))
echo ${#gene[@]}
variant=($(awk 'BEGIN {FS="\t" };{if (NR>1 && $13 =="COVERED" ) {print $5}}' $maffile))
ref=($(awk 'BEGIN {FS="\t"};{if (NR>1 && $13 =="COVERED" ) {print $7}}' $maffile))
alt=($(awk 'BEGIN {FS="\t"};{if (NR>1 && $13 =="COVERED" ) {print $9}}' $maffile))
context=($(awk 'BEGIN {FS="\t"};{if (NR>1 && $13 =="COVERED" ) {print $11}}' $maffile))
echo "read maf done"

#declare -a category
#declare -a effect #noncoding:0,nonsilent:1,silent:2
declare -A dicteffect
declare -A dictcate
#declare -a index

var_name=($(awk 'BEGIN {FS="\t"};{ if (NR>1) {print $1}}' $dictfile))
var_effect=($(awk 'BEGIN {FS="\t"};{ if (NR>1) {print $2}}' $dictfile))


for (( i=0; i<${#var_name[@]}; i++ ))
do 
  dicteffect["${var_name[$i]}"]="${var_effect[$i]}"
done

echo "dict effect done"

bases=( "A" "C" "G" "T" )

j=0

#set -x
for left in {0..3}
do
  #if [ $j -le 24 ]; then set -x; fi
  #if [ $j -gt 24 ]; then set +x; fi 
  for from in {0..3}
  do
        for to in {0..3}
    do
      for right in {0..3}
      do    
              if [ $from -eq $to ]
        then
          continue
        fi
        tmp1=${bases[$left]}
        tmp2=${bases[$from]}
        tmp3=${bases[$to]}
        tmp4=${bases[$right]}
        tmp=${bases[$left]}${bases[$from]}${bases[$to]}${bases[$right]}
        dictcate[$tmp]=$j #ordered in [1..192]
        (( j=j+1 ))
        #names{i,1} = [bases(left) '(' bases(from) '->' bases(to) ')' bases(right)];
      done
    done
  done
done

echo "dict category done"
echo "read and generate effect and category..."
#if [[ -f $output ]];then rm $output; fi
rm $output

#set -x
#for i in "${!dictcate[@]}"
#do
#  echo "$i - ${dictcate["$i"]}"
#done
#set +x
echo ${#gene[@]}

for (( i=0; i<${#gene[@]}; i++ ))
do
#  if [ $i -le 0 ]; then set -x; fi
#  if [ $i -gt 0 ]; then set +x; fi 
  type=0
  tt="${variant[$i]}"
  tmp=${dicteffect["${variant[$i]}"]}
  if [ "$tmp" == "noncoding" ]
  then
    type=0
  elif [ "$tmp" == "nonsilent" ]
  then
    type=1
  elif [ "$tmp" == "silent" ]
  then
    type=2
  else
    type=-1 #check this
  fi
  effect=$type

  tmp1=${context[$i]}
  from=${ref[$i]}
  to=${alt[$i]}
  left=${tmp1:9:1}
  right=${tmp1:11:1}
  tmp2=$left$from$to$right
  tmp3=${tmp2^^} #upper cases
  category=${dictcate[$tmp3]}
  ((index=$effect*192+$category))
  echo -e "${gene[$i]}\t$effect\t$category\t$index" >>$output
done


#template=/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.4/exome_full192.coverage.txt
#allgenes=($(awk 'BEGIN {FS="\t"}; {if (NR>1) print $1}' $template))
#j=0
#i=0
#while [[ $j -lt ${#allgenes[@]} ]]
#do
#  uniqgenes[$i]=${allgenes[$j]}
#  ((i=i+1))
#  ((j=j+192*3))
#done

