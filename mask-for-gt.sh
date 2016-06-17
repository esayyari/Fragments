#!/bin/bash

algfn=$4
f=unfiltered/$1/$algfn
percent=$2
taxapercent=$3
out=$f.mask${percent}sites.mask${taxapercent}taxa.fasta

test $# == 4 || { echo  USAGE: gene site_percent taxa_percent file_name; exit 1;  }
sed -e 's/\(N\|X\)/-/g' $f > $f-frag-rem
m=`echo $( grep ">" $f-frag-rem|wc -l ) \* $percent / 100 |bc`
$WS_HOME/pasta/pasta/run_seqtools.py -infile $f-frag-rem -masksites $m -outfile $f-frag-rem.mask${percent}sites.fasta
echo From `$WS_HOME/insects/simplifyfasta.sh $f-frag-rem|wc -L` sites in $f-frag-rem to `wc -L $f-frag-rem.mask${percent}sites.fasta` sites

m2=`echo $( cat $f-frag-rem.mask${percent}sites.fasta|wc -L ) \* $taxapercent / 100 |bc`
$WS_HOME/pasta/pasta/run_seqtools.py -infile $f-frag-rem.mask${percent}sites.fasta -filterfragments $m2 -outfile $out

echo went from `grep ">" $f-frag-rem|wc -l` to `grep ">" $out|wc -l` sequences
