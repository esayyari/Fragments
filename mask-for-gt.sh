#!/bin/bash



s=$1
ID=$2
algfn=$3
DT=$4
percent=$5
taxapercent=$6
f=$s/$ID/$DT-$algfn
mkdir $s/$ID/$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa
diroutput=$s/$ID/$DT-$algfn-mask${percent}sites.mask${taxapercent}taxa
out=$diroutput/$f.mask${percent}sites.mask${taxapercent}taxa.fasta

test $# == 5 || { echo  USAGE: gene site_percent taxa_percent file_name; exit 1;  }
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
m=`echo $( grep ">" $f-frag-rem|wc -l ) \* $percent / 100 |bc`
$WS_HOME/pasta/pasta/run_seqtools.py -infile $f-frag-rem -masksites $m -outfile $f-frag-rem.mask${percent}sites.fasta
echo From `$WS_HOME/insects/simplifyfasta.sh $f-frag-rem|wc -L` sites in $f-frag-rem to `wc -L $f-frag-rem.mask${percent}sites.fasta` sites

m2=`echo $( cat $f-frag-rem.mask${percent}sites.fasta|wc -L ) \* $taxapercent / 100 |bc`
$WS_HOME/pasta/pasta/run_seqtools.py -infile $f-frag-rem.mask${percent}sites.fasta -filterfragments $m2 -outfile $out

echo went from `grep ">" $f-frag-rem|wc -l` to `grep ">" $out|wc -l` sequences
