# A quick search for WIV domain proteins in metagenomes

Adam Rivers - USDA-ARS  - 6/7/2023

Work with David Karlin

## Data source 

Serratus RdRp containing contigs were downloaded

```
wget https://serratus-public.s3.amazonaws.com/rdrp_contigs/rdrp_contigs.tar.gz
tar -xvf rdrp_contigs.tar.gz
```

## Protein Translation
Contigs were translated into genes using Prodigal V2.6.3 and Nextflow version 23.04.0.5857
 
```
nextflow run genecaller.nf --with-tower
```

##  A HMM database was created 

This used David's alignment with hhmbuild version 3.2.1

```
hmmbuild wiv.hmm wiv_aln.fasta
```

## HMM search

this ws  run with hmmsearch version 3.2.1 

```
hmmsearch -A wivdomhits.sto --tblout wivdomtbl.txt -E 1e-3 --cpu 24 wiv.hmm rdrp_genes.faa
```

## Extracting the alignments

Reformat the Stockholm alignment to an unaligned fasta using Hmmer easel tools version 3.3.2

```
esl-reformat wivdomhits.sto > wivdomhits.fa
```

## Attching metadata

The Hmmer hit data was merged with metadata from Serratus in R

```{r}
# R version 4.2.0 
library(tidyverse)
hdat <- read.csv('wiv_rdrp_hits.csv', header=FALSE)
serdata <- read.csv('rdrp_contigs.tsv',sep="\t")
wiv <- left_join(hdat, serdata, join_by(V2 == Contig))
write.csv(wiv, "wiv_contig_metadata.csv")
write.csv(hdat$V2, "~/Documents/wiv_ids.csv", quote=F, row.names=F, col.names=F)
```

## Finally full length contigs were selected from the hit table

```
esl-sfetch --index rdrp_contigs.fa
esl-sfetch -f rdrp_contigs.fa wiv_ids.csv > wiv.contigs.fasta
gzip -9 wiv.contigs.fasta
```

## Excluded files

Several files in this analysis are large and were excluded  from the repo. they were:


*	.nextflow.log
*	.nextflow.log.1
*	.nextflow.log.2
*	.nextflow.log.3
*	.nextflow.log.4
*	.nextflow.log.5
*	.nextflow.log.6
*	.nextflow.log.7
*	.nextflow.log.8
*	.nextflow.log.9
*	.nextflow/
*	rdrp_contigs.fa
*	rdrp_contigs.fa.ssi
*	rdrp_contigs.tar.gz
*	rdrp_contigs.tsv
*	rdrp_genes.faa
*	wiv_contig_metadata.csv
*	work/
