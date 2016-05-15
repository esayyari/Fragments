#!/bin/bash
show_help(){
cat << EOF
USAGE: ${0##*/} [-h] [-i  nucleic acid sequence file (fasta format)] 
This script removes species that has less than 50% of length of sequence. The input should be fasta format, the output is fasta as well.
EOF
}

while getopts "hi:" opt; do
        case $opt in
        h)
                show_help
                exit 0
                ;;
         i)
                i=$OPTARG
                ;;
        '?')
                printf "Unknown input option"
                show_help
                ;;
        esac
done

o="$i"-filtered50
echo $o
tmp=`mktemp`
cat $i | sed -e 's/>\(.*\)/#>\1@/g' | tr -d "\n" | tr "\#" "\n" > $tmp
for x in `cat $tmp`; do y=$(echo -n $x|sed -e 's/^.*@//' | sed -e 's/N//g'| wc -m); ncount=$(echo -n $x | sed -e 's/^.*@//'  | sed -e 's/[^N]//g'|wc -m); a=$x; z=$(awk "BEGIN {if($ncount/($y+$ncount) < 0.5){print 1}}");   if [ "$z" == "1" ]; then echo  -n "#"$x;  fi; done | tr "\#" "\n" | tr "@" "\n" > $o
