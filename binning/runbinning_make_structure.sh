#!/bin/bash

#set -x

DIR=$(cd "$(dirname $0)" && pwd)

DT=$1
label=$2
H=${3}
outpath=${4}
taxa="${5}"
site=${6}
suffix=${7}
thr=${8}
g=${9}
test $# -eq  9 || { echo "USAGE: $0 <DT> <label> <gene_path> <outpath> <taxa> <site> <suffix> <thr> <filename>" && exit 1; }

#/oasis/tscc/scratch/esayyari/oasis/projects/nsf/uot138/esayyari/data/Insects/genes/ALICUT_EOG5HMGSH/FAA-ALICUT_EOG5HMGSH-mask10sites.mask50taxa-3-avg-filtered-long-branch-raxml/raxmlboot.FAA-ALICUT_EOG5HMGSH-mask10sites.mask50taxa-3-avg-filtered-long-branch.tre/RAxML_bestTree.best.addPoly.rooted.final.fasttree
echo $taxa
taxadir=$(cd $(dirname $taxa); pwd)
while read x; do
	while read t; do
		while read s; do
			if [ -s "$suffix" ]; then
				while read j; do
					echo $j
					echo $x
					echo $t
					echo $s
					mkdir -p "$outpath"/binning/binning_mask"$s"site.mask"$t"taxa-"$j"-raxml-binthr"$x"/genes/
					wrk="$outpath"/binning/binning_mask"$s"site.mask"$t"taxa-"$j"-raxml-binthr"$x"
					for dir in `find $H -maxdepth 1 -mindepth 1 -type d -name "[0-9a-zA-Z]*"`; do
                				y=$(basename $dir)
						mkdir -p $wrk/genes/$y
						a=$DT-$y-mask"$s"sites.mask"$t"taxa-$j
						cp $H/$y/$a-raxml/raxmlboot."$a"."$label"/$g $wrk/genes/$y
						test #? -ne "0" && echo "something was wrong $dir" && exit 1
						cp $H/$y/$a-raxml/$a.fasta $wrk/genes/$y/$y.fasta
						cp $H/$y/$a-raxml/bestModel.$y-mask"$s"sites.mask"$t"taxa-$j $wrk/genes/$y/bestModel.$y
						test #? -ne "0" && echo "something was wrong $dir" && exit 1
						echo $dir
					done
					mkdir $wrk/working_dir
					cd $wrk/working_dir
					$BINNING_HOME/makecommands.compatibility.sh $wrk/genes $x $wrk/pairwise_output_dir $g
					echo "working on $wrk has been finished"
					cd $taxadir
				done < $suffix
			else
				mkdir -p $outpath/binning/binning_mask"$s"site.mask"$t"taxa-raxml-binthr"$x"/genes/
	                                wrk=$outpath/binning/binning_mask"$s"site.mask"$t"taxa-raxml-binthr"$x"
                                for dir in `find $H -maxdepth 1 -mindepth 1 -type d -name "[0-9a-zA-Z]*"`; do
                                        y=$(basename $dir)
                                        mkdir $wrk/genes/$y
                                        a=$DT-$y-mask"$s"sites.mask"$t"taxa
                                        cp $H/$y/$a-raxml/raxmlboot."$a"."$label"/$g $wrk/genes/$y
                                        cp $H/$y/$a-raxml/$a.fasta $wrk/genes/$y/$y.fasta
					 cp $H/$y/$a-raxml/bestModel.$y-mask"$s"sites.mask"$t"taxa $wrk/genes/$y/bestModel.$y
                                done
                                mkdir $wrk/working_dir
                                cd $wrk/working_dir
                                $BINNING_HOME/makecommands.compatibility.sh $wrk/genes $x $wrk/pairwise_output_dir $g
				cd $taxadir
				echo "working on $wrk has been finished"
                        fi
                done < $site
        done < $taxa
done < $thr
