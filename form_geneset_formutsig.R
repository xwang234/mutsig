#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

wgstumors=c()
for (i in 1:length(args))
{
  wgstumors[i]=as.character(args[i])
}

genes=NULL
for (i in 1:length(wgstumors))
{
  print(i)
  maffile=paste0(wgstumors[i],".maf.annotated.reduced")
  maftable=read.table(maffile,header=T,sep="\t",stringsAsFactors = F,quote="")
  maftable=maftable[maftable$Hugo_Symbol != "Unknown" & maftable$covered=="COVERED",]
  genes=c(genes,unique(maftable$Hugo_Symbol))
  genes=unique(genes)
}
output="geneset.txt"
fcon=file(output,"w")
for (i in 1:length(genes))
{
  writeLines(genes[i],con=fcon)
}
close(fcon)
