#!/bin/bash
show_help(){
cat << EOF
USAGE: ${0##*/} [-h] [-i  nucleic acid sequence file (fasta format)]
This script removes third codon from the DNA sequence. The input file format is fasta, the output is fasta.
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

o="$i"-"rm"-3rdCodon
echo $o
tmp=`mktemp`
cat $i | sed -e 's/>\(.*\)/#>\1@/g' | tr -d "\n" | tr "\#" "\n" > $tmp
for x in `cat $tmp`; do a=$(echo -n $x|sed -e 's/^.*@//' | sed -e 's/\(..\)\(.\)/\1/g'); b=$(echo -n $x | sed -e 's/@.*//'); echo -n "#"$b"@"$a; done | tr "#" "\n" | tr "@" "\n" > $o
