## Differential prevalence and risk factors for infection of coronaviruses in bats collected during 2020 in Yunnan Province, China

This repository contains a reproducible workflow related to Figure 4C in the above named manuscript.

The whole workflow can be run automatically using [snakemake](https://snakemake.readthedocs.io/en/stable/). It utilizes the conda environment specified in [environment.yaml](environment.yaml).

The workflow begins from a set of input reads and conducts successive processing as shown in [Snakefile](Snakefile) to produce the final set of contigs considered in the mapping displayed.
To perform the analysis, [Snakefile](Snakefile) should be placed in a directory containing:

- A directory containing the reads to be processed.
- A directory containing the [SILVA](https://www.arb-silva.de/) database to be used. (for our pipeline they are contained in `/silva_db`).
- The `.fasta` file containing the sequences to be used by `makeblastdb` in making the reference database. (It is worth noting that the resultant blast db will also be contained in this directory).
- Although all parameters may be specified/modified within the [Snakefile](Snakefile), the user may opt to specify these in a `config.yaml` file. This file should be in this directory.


The R code used for the retrieval of Taxids for the accession associated with the final resultant contigs is contained in [accessions_to_taxids.R](accessions_to_taxids.R).

Template file paths may be substituted appropriately.
