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
##### Please note that all codes are available on [this github repository](https://github.com/esayyari/Fragments/). They use python2 or bash, and dependencies are [dendropy4](https://dendropy.org/), and [pasta](https://github.com/smirarab/pasta).

In this section we will describe the commands we used for generating and performing the simulations as well as the biological analyses. 

We used the following commands to infer the gene trees:

```
bash runraxml-bestML.sh [ALIGNMENT NAME WITHOUT PHYLIP OR FASTA] [DT] [GENE IDs] [labels] [GENE DIR] [NUM CPU]
```

This command assumes a specific structure. It assumes that the fasta file is under this directory:

[GENE DIR]/[GENE IDs]/\[DT]-[ALIGNMENT NAME WITHOUT PHYLIP OR FASTA]/[GENE IDs]-[ALIGNMENT NAME WITHOUT PHYLIP OR FASTA].fasta

It first converts the fasta file to phylip (using __convert_to_phylip.sh__), and then finds the list of identical alignments in the phylip file (using __listRemovedTaxa.py__).
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

* Misof B, Liu S, Meusemann K, Peters RS, Donath A, Mayer C, Frandsen PB, Ware J, Flouri T, Beutel RG, Niehuis O, Petersen M. 2014. Phylogenomics resolves the timing and pattern of insect evolution. Science 346(6210): 763–767.
