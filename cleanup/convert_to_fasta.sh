#!/bin/bash

phylip=$1
awk -posix '{if ($1 ~ /[:alpha:]/) print ">"$1"\n"$2}' $phylip
