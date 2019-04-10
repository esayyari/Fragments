# Fragmentary gene sequences negatively impact gene tree and species tree reconstruction

## Abstract
Species tree reconstruction from genome-wide data is increasingly being attempted, in most cases using a two-step
approach of first estimating individual gene trees and then summarizing them to obtain a species tree. The accuracy of
this approach, which promises to account for gene tree discordance, depends on the quality of the inferred gene trees. At
the same time, phylogenomic and phylotranscriptomic analyses typically use involved bioinformatics pipelines for data
preparation. Errors and shortcomings resulting from these preprocessing steps may impact the species tree analyses at
the other end of the pipeline. In this article, we first show that the presence of fragmentary data for some species in a
gene alignment, as often seen on real data, can result in substantial deterioration of gene trees, and as a result, the species
tree. We then investigate a simple filtering strategy where individual fragmentary sequences are removed from individual
genes but the rest of the gene is retained. Both in simulations and by reanalyzing a large insect phylotranscriptomic data
set, we show the effectiveness of this simple filtering strategy.
## Experiments and Codes
##### Please note that all codes are available on [this github repository](https://github.com/esayyari/Fragments/). They use python2 or bash, and dependencies are [dendropy4](https://dendropy.org/), [nwcik utility](http://cegg.unige.ch/newick_utils) and [PASTA](https://github.com/smirarab/pasta).

In this section we will describe the commands we used for generating and performing the simulations as well as the biological analyses.

### Filtering alignments
We used  __mask-for-gt.sh__ (internally uses [PASTA](https://github.com/smirarab/pasta)) to remove alignments with lots of gap characters. 
### Generate simulated dataset
We used __draw\_parameters.py__ (please check the comments inside the code for more information) and the following files to generate the fragmentary stats for each species in each gene.
 
* __average\_branch\_lengths.csv__: averge tip-to-root distances for biological Insects gene trees
* __fragmentary\_augmented.csv__: frequency of gap characters for the biological Insects dataset
* __simulated\_average\_branch\_lengths.csv__: averge tip-to-root distances for biological Insects gene trees per each replicate.

To generate the sequence files we used __generateFragmentary.py__ passing the output of __draw\_parameters.py__. 

 
### Inferring gene trees
We used the following commands to infer the gene trees:

```
bash runraxml-bestML.sh [ALIGNMENT NAME WITHOUT PHYLIP OR FASTA] [DT] [GENE IDs] [labels] [GENE DIR] [NUM CPU]
```

This command assumes a specific structure. It assumes that the fasta file is under this directory:

[GENE DIR]/[GENE IDs]/\[DT]-[ALIGNMENT NAME WITHOUT PHYLIP OR FASTA]/[GENE IDs]-[ALIGNMENT NAME WITHOUT PHYLIP OR FASTA].fasta

* It first converts the fasta file to phylip (using __convert\_to\_phylip.sh__), and then finds the list of identical alignments in the phylip file (using __listRemovedTaxa.py__). Then [RAxML](https://cme.h-its.org/exelixis/web/software/raxml/index.html) (__raxmlHPC__) will run to remove identical alignments. For amino acid alignements (DT should be FAA), we find the best model of evolution using __ProteinModelSelection.pl__. Then __raxmlHPC-PTHREADS__ or __raxmlHPC__ (based on the number of cpus) will be used to infer the gene trees (__please change -N 20 or -N 2 at lines 89 or 91 for your usage. This number defines the number of repeats for RAxML__). Finally, it uses __addIdenticalTaxa.py__ to add back the identical species to the gene trees.

* For inferring the gene trees (as well as bootstrapping) with [FastTree](http://www.microbesonline.org/fasttree/), we used this command __runraxml-fasttreeboot.sh__. It internally uses fasttree (double-precision version) and same scripts listed above.

* For doing bootstrapping we used this command __runraxml-fasttree-start-boostrapping.sh__, which uses [FastTree](http://www.microbesonline.org/fasttree/) (double-precision version) internally, and the same scripts listed above.  

### Miscellaneous
* To remove third codon postions from alignments we used __remove\_3rd\_codon\_nt\_fas.sh__.
* To convert fasta file to phylip we used __convert\_to\_phylip.sh__.
* To generate fragmentary statistics we used __generate\_fragmentary\_stat.sh__.
* To generate GC content statistics we used __gc-stats.py__.
* To calculate bootstrap supports we used __draw\_support\_on\_best\_ML.sh__. 
* We used ASTRAL version 4.11.1 to infer species trees
* To root biological dataset we used __root-nw\_friendly.py__.

## Data
We used simulated as well as biological data to study the effects of fragmentary data on the quality of gene trees and species trees. 
### Simulations

In simulations, we study impacts of fragmentary data and the filtering strategy on the accuracy of gene trees and eventually the accuracy of the species trees. 
Simulated dataset is available [here](https://drive.google.com/open?id=1NuF0eG5cO3jxEHVoCgdIjiQ35qBQCuYv). The simulated dataset has 50 replicates (in 50 separate folders), with 101 species (one outgroup). For each replicate, we provide original gene sequences (all-genes.phylip), and the fragments inserted version (all-genes-fragAdded.phylip). We also provide the FastTree (using double precision), e.g. in FNA-genes.fragAdded-mask1sites.mask1taxa, and RAxML, e.g. in FNA-genes.fragAdded-mask1sites.mask1taxa-raxml, gene trees (using 50, 200, and 1000 genes) and the corresponding estimated species trees. Folders with __raxml__ at the end of their name contain RAxML gene trees. To indicate the filtering strategy we use this format: __mask[x%]sites.mask[y%]taxa__, which indicates that we removed all sites with less than _x%_ non-gap characters, and we removed all species that has less than _y%_ non-gap characters. 

### Biological

We studied an empirical transcriptomic data set of insects consisting of 1,478 protein-coding genes of 144 taxa, where
27% of the alignment is gaps (Misof et al. 2014). We now share the biological sequences, gene trees and species trees:

* gene trees and species trees are avaialble [here](https://drive.google.com/open?id=1QpB9FdwMAU1bkHBS7lHfAfw-P5EdL2WZ)
* sequences are available [here](https://drive.google.com/open?id=19Z8y5FX16Oh-GYPnAvpuw7Hmv0d0DlIZ)

## References
* A. Stamatakis: "RAxML Version 8: A tool for Phylogenetic Analysis and Post-Analysis of Large Phylogenies". In Bioinformatics, 2014
* Junier, T. and Zdobnov, E.M., 2010. The Newick utilities: high-throughput phylogenetic tree processing in the UNIX shell. Bioinformatics, 26(13), pp.1669-1670.
* Mirarab, S., Nguyen, N., Guo, S., Wang, L.S., Kim, J. and Warnow, T., 2015. PASTA: ultra-large multiple sequence alignment for nucleotide and amino-acid sequences. Journal of Computational Biology, 22(5), pp.377-386.
* Misof B, Liu S, Meusemann K, Peters RS, Donath A, Mayer C, Frandsen PB, Ware J, Flouri T, Beutel RG, Niehuis O, Petersen M. 2014. Phylogenomics resolves the timing and pattern of insect evolution. Science 346(6210): 763–767.
* Price, M.N., Dehal, P.S. and Arkin, A.P., 2010. FastTree 2–approximately maximum-likelihood trees for large alignments. PloS one, 5(3), p.e9490.
