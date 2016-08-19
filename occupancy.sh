#!/bin/bash

for x in $*; do 
  $WS_HOME/global/src/shell/simplifyfasta.sh $x|sed -e "/^>/! s/[?N-]//g"|awk '/>/ {x=$0} /^[^>]/ {print "'$x'",x,length($0)}';
done
