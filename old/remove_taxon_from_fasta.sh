#!/bin/bash
set -x
if [ $# -lt 2 ]; then
	echo "USAGE: $0 <sequence name> <input file> [-rev]"
	exit 1
fi
a=$(echo $2 | tr ',' '|')
if [ "$3" == "-rev" ]; then
  c='/>/ {p=0} /'$a'/ {p=1} {if (p) {print $0};}'
else
  c='/>/ {p=1} /'$a'/ {p=0} {if (p) {print $0};}'
fi

awk "$c" $1
