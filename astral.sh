#!/bin/bash

pushd .
cd $WS_HOME/ASTRAL
V=$(git ls-tree -r DiscoVista | grep "Astral.*zip" | awk '{print $NF}'| sed -e 's/Astral/astral/' | sed -e 's/.zip/.jar/')
popd

astral=$(find $WS_HOME/ASTRAL/$V)


gene=$1
out=$2
log=$3


java -jar $astral -i $gene -o $out > $log 2>&1
