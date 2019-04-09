#!/bin/bash

for x in $*; do 
  $WS_HOME/global/src/shell/simplifyfasta.sh $x|sed -e "/^>/! s/[?X-]//g"|awk '/>/ {x=$0} /^[^>]/ {print "'$x'",x,length($0)}';
done
