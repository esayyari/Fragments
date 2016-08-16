#!/bin/sh

#set -x

tmp=`mktemp`

# simplifyfasta.sh
sed -e "s/>\(.*\)/@>\1@/g" $1|tr -d "\n"|tr "@" "\n"|tail -n+2> $tmp

#find length and count
lent=`head -n 2 $tmp|grep -v ">"| sed -e 's/ //g' | wc -c`
len=$((lent - 1))
count=`grep ">" $tmp|wc -l`
echo $count $len >$2
cat $tmp|tr "\n" ";"|sed -e "s/;>/\n/g" -e "s/;/ /g" -e "s/>//g" >>$2

rm $tmp
