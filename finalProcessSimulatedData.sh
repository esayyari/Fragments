#!/bin/bash

for i in `seq -w 1 50`; do sed -e :a -e '$!N;s/\n@/ /;ta' -e 'P;D' $i/all-genes-fragmentary.phylip   | sed -e 's/ $//' | sed -e 's/\([0-9][0-9]*\)[ \t][ \t][ \t][ \t][ \t]*/\1     /g' > $i/all-genes-fragAdded.phylip;  done
