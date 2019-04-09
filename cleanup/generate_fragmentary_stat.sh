#!/bin/bash
set -x
test $# -ne "4" &&  echo  USAGE: $0 outpath geneID seqtype align && exit 1
s=$1
ID=$2
DT=$3
algfn=$4
z=$s/$ID/$DT-$algfn.fasta
g=$(dirname $z);
base=$(basename $z | sed -e "s/.fasta//"); 
if [ "$DT" == "FNA" ]; then
	echo "taxa,seqlength,A,C,G,T,a,c,g,t,N,-" > $g/$base.fragmentary.stat
	cat $z | awk -vFS="" '/>/ {line=$0}; !/>/ {sum=0; for(i=1;i<=NF;i++){w[$i]=0}; for(i=1;i<=NF;i++){w[$i]++ sum++}}; !/>/ {printf "%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f \n",line,sum,w["A"]/sum,w["C"]/sum,w["G"]/sum,w["T"]/sum,w["a"]/sum,w["c"]/sum,w["g"]/sum,w["t"]/sum,w["N"]/sum,w["-"]/sum}' >> $g/$base.fragmentary.stat;
	echo "working on $g/$base.fragmentary.stat has been finished";
else
	echo "taxa,seqlength,X,-" > $g/$base.fragmentary.stat 
	cat $z  | awk -vFS="" '/>/ {line=$0}; !/>/ {sum=0; for(i=1;i<=NF;i++){w[$i]=0}; for(i=1;i<=NF;i++){w[$i]++ sum++}}; !/>/{printf "%s,%f,%f,%f \n",line,sum,w["X"]/sum,w["-"]/sum}' >> $g/$base.fragmentary.stat;

fi
