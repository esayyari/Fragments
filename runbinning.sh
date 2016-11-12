#!/bin/bash


DIR=$(cd "$(dirname $0)" && pwd)

outpath=${1}
taxa=${2}
site=${3}
suffix=${4}
thr=${5}
DT=${6}
H=${7}
ALIGN=${8}

test $# -eq 8 || { echo "USAGE: $0 <outpath> <taxa> <site> <suffix> <thr> <DT> <gene_path> <genetree_name>" && exit 1; }
taxadir=$(cd $(dirname $taxa); pwd)

#run step 4 of binning in this way: 
#	cd $outpath"/binning/binning_mask"$s"site.mask"$t"taxa-"$j"-raxml-binthr"$x"
#	$BINNING_HOME/build.supergene.alignments.sh `pwd`/pairwise_output_dir/  genes `pwd`/supergenes_dir > working_dir/supergene.out 2>&


if [ -s tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-concatenate_genes ]; then
	rm tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-concatenate_genes
fi
if [ -s tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-new ]; then
	rm tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-new
fi
while read x; do
        while read t; do
                while read s; do
                        if [ -s "$suffix" ]; then
                                while read j; do
                                        wrk="$outpath"/binning/binning_mask"$s"site.mask"$t"taxa-"$j"-raxml-binthr"$x"
                                        for dir in `find "$wrk"/supergenes_dir -maxdepth 1 -mindepth 1 -type d -name "bin*"`; do
						g=$(cat $dir/supergene.part | wc -l);
						for i in `seq 1 $g`; do
							printf "cat $z/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned >> filtered-$s-sites-$t-taxa-$j-raxml-binning-$x-partitioned.gene_trees.trees \n" >> tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-concatenate_genes;
						done

					        if [ $g -gt 1 ]; then
							if [ -s $dir/supergene.part.partitioned ]; then	
								rm $dir/supergene.part.partitioned
							fi
						        while read z; do
					        	        l=$(dirname $(echo $z | awk '{print $2}'));
					                	newmodel=$(cat $wrk/$l/bestModel* | sed -e "s/.* //g");
									echo $l
								echo $newmodel
							
						                p=$(echo $z | awk '{print $2}');
						                y=$(basename $p);
						                h=$(echo $z | awk '{print $3,$4}');
						                printf "$newmodel, $y $h\n" >> $dir/supergene.part.partitioned;
						        done < $dir/supergene.part; 
						fi;
						
                                        done
					for z in `find $wrk/supergenes_dir/ -maxdepth 1 -type d -name "bin*" | sort`; do 
						line=$(cat $z/supergene.part | wc -l); 
						if [ "$line" -gt "1" ]; then 
							h=$wrk; 
							b=$(basename $z); 
							p=$(dirname $h);  
							printf "$WS_HOME/insects/runraxml-bestML-binning.sh supergene $DT $b partitioned $wrk/supergenes_dir 4\n";
						 fi 
					done >> tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-new

					for z in `find  $wrk/supergenes_dir/ -maxdepth 2 -name supergene.part | sort`; do 
						g=$(cat $z | wc -l); 
						if [ "$g" -eq "1" ]; then 
							h=$(dirname $z); 
							mkdir -p $h/supergene-raxml/raxmlboot.supergene.partitioned; 
							y=$(cat $z);
							if [ -s $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned ]; then 
								rm $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned; 
							fi
							cp $H/$y/$DT-$y-mask"$s"sites.mask"$t"taxa-"$j"-raxml/raxmlb*/$ALIGN $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned; 
						fi
					done

					for z in `find . -maxdepth 1 -type d -name "bin*" | sort `; do 
						g=$(cat $z/supergene.part | wc -l); 
						for i in `seq 1 $g`; do 
							printf "cat $z/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned >> filtered-$ssites-$ttaxa-$j-raxml-binning-$x-partitioned.gene_trees.trees \n" >> tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-concatenate_genes; 
						done
					done
                                        cd $taxadir
                                done < $suffix
                        else
                                wrk=$outpath/binning/binning_mask"$s"site.mask"$t"taxa-raxml-binthr"$x"
                                for dir in `find $wrk/supergenes_dir -maxdepth 1 -mindepth 1 -type d -name "bin*"`; do
					g=$(cat $dir/supergene.part | wc -l);
					for i in `seq 1 $g`; do
						printf "cat $z/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned >> filtered-$s-sites-$t-taxa-raxml-binning-$x-partitioned.gene_trees.trees \n" >> tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-concatenate_genes;
					done
					if [ $g -gt 1 ]; then
						while read z; do
							l=$(dirname $(echo $z | awk '{print $2}'));
							newmodel=$(cat ../$l/bestModel* | sed -e "s/.* //g");
							p=$(echo $z | awk '{print $2}');
							y=$(basename $p);
							h=$(echo $z | awk '{print $3,$4}');
							printf "$newmodel, $y $h\n" >> $dir/supergene.part.partitioned;
						done < $dir/supergene.part;
					fi;

				done
				for z in `find $wrk/supergenes_dir/ -maxdepth 1 -type d -name "bin*" | sort`; do
					line=$(cat $z/supergene.part | wc -l);
					if [ "$line" -gt "1" ]; then
						h=$wrk;
						b=$(basename $z);
						p=$(dirname $h);
						printf "$WS_HOME/insects/runraxml-bestML-binning.sh supergene $DT $b partitioned $p/supergenes_dir 4\n";
					 fi
				done >> tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-new

				for z in `find  $wrk/supergenes_dir/ -maxdepth 2 -name supergene.part | sort`; do
					g=$(cat $z | wc -l);
					if [ "$g" -eq "1" ]; then
						h=$(dirname $z);
						mkdir -p $h/supergene-raxml/raxmlboot.supergene.partitioned;
						y=$(cat $z);
						rm $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned;
						cp $H/$y/$DT-$y-mask"$s"site.mask"$t"taxa-raxml/raxmlb*/$ALIGN $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned;
					fi
				done

                                cd $taxadir
                                echo "working on $wrk has been finished"
                        fi
                done < $site
        done < $taxa
done < $thr




