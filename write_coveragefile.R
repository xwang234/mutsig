#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
samplename=as.character(args[1])
countfile=paste0(samplename,".maf.annotated.reduced.cate")
output=paste0(countfile,".coverage")
if (file.exists(output)) file.remove(output)
data=read.table(file=countfile,sep="\t")
#genes=read.table(file="/fh/fast/dai_j/CancerGenomics/Tools/MutSigCV_1.4/uniqgenes_full192.txt",stringsAsFactors = F)
#genes were created by form_geneset_formutsig.R
genes=read.table(file="./geneset.txt",stringsAsFactors = F)

write2file=function(genetable,outputcon)
{
  #if gene is not included
  if (nrow(genetable)==0)
  {
    all0=c(rep("0\n",575),"0")
    all0=paste0(all0,collapse="")
    writeLines(all0,con=outputcon)
  }else
  {
    idx=order(genetable[,4])
    genetable=genetable[idx,]
    uniq_loc=unique(genetable[,4]) #in the range of [0-575]
    start=-1
    for (i in 1:length(uniq_loc))
    {
      num=sum(genetable[,4]==uniq_loc[i])
      #only the number to be added
      if (uniq_loc[i]==start+1)
      {
        writeLines(as.character(num),con=outputcon)
      }else # need to add 0 before
      {
        if (uniq_loc[i]==start+2) #just add 1 0
        {
          writeLines("0",outputcon)
        }else
        {
          line0=c(rep("0\n",uniq_loc[i]-start-2),"0") #add 0s
          line0=paste0(line0,collapse="")
          writeLines(line0,con=outputcon)
        }
        writeLines(as.character(num),con=outputcon)
      }
      start=uniq_loc[i]
    }
    #if the last line was not fit in,to add the rest lines
    if (start<575)
    {
      if (start==574)
      {
        writeLines("0",outputcon)
      }else
      {
        line0=c(rep("0\n",575-start-1),"0")
        line0=paste0(line0,collapse="")
        writeLines(line0,con=outputcon)
      }
    }
  }
}

outputcon=file(output,"w")

for (i in 1:nrow(genes))
{
  gene=genes[i,1]
  genetable=data[data[,1]==gene & data[,2] != -1,]
  write2file(genetable,outputcon)
  if (i %% 1000 ==0) cat(i,"..")
}
close(outputcon)
