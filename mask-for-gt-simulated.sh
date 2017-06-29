#!/bin/bash



s=$1
ID=$2
DT=$3
algfn=$4
percent=$5
taxapercent=$6
f=$s/$ID/$DT-$algfn
mkdir -p $s/$ID/$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa
diroutput=$s/$ID/$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa
out=$diroutput/$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa.fasta

test $# == 6 || { echo  USAGE: outpath geneID seqtype alignname site_percent taxa_percent exit 1;  }
tmp=`mktemp`
while read x; do
	y=$(echo $x | grep ">")
	if [ "$DT" == "FNA" ]; then
		if [ "$y" == "" ]; then 
			echo $x | sed -e 's/N/-/g' >> $tmp
		else
			echo $x >> $tmp
		fi
	else
		if [ "$y" == "" ]; then 
			echo $x | sed -e 's/X/-/g' >> $tmp
		else
			echo $x >> $tmp
		fi
	fi
done < $f.fasta
mv $tmp $f-frag-rem
m=`echo $( grep ">" $f"-frag-rem"|wc -l ) \* $percent / 100 |bc`
$WS_HOME/pasta/run_seqtools.py -infile $f-frag-rem -masksites $m -outfile $f-frag-rem.mask${percent}sites.fasta >> $diroutput/log-$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa.error 2>&1

a=$($WS_HOME/insects/simplifyfasta.sh $f-frag-rem|wc -L)
b=$(cat $f-frag-rem.mask${percent}sites.fasta | wc -L)
echo From $a sites in $f-frag-rem to $b sites >> $diroutput/log-$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa.error 2>&1

m2=`echo $( cat $f-frag-rem.mask${percent}sites.fasta|wc -L ) \* $taxapercent / 100 |bc`
$WS_HOME/pasta/run_seqtools.py -infile $f-frag-rem.mask${percent}sites.fasta -filterfragments $m2 -outfile $out >> $diroutput/log-$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa.error 2>&1

rm $f-frag-rem.mask${percent}sites.fasta
echo went from `grep ">" $f-frag-rem|wc -l` to `grep ">" $out|wc -l` sequences >> $diroutput/log-$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa.error 2>&1

