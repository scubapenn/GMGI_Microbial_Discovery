# GMGI Microbial Discovery

This repository contains all the scripts used for the assembly and annotation of metagenomes.

## Pipeline Overview

The general workflow involves the following steps:

1. **Trim the raw FASTQ files** using Trimmomatic to remove low-quality reads and adapter sequences.
2. **Assemble the trimmed reads** into contigs using MEGAHIT.
3. **Identify Open Reading Frames (ORFs)** in the assembled contigs with Prodigal.
4. **Dereplicate the ORFs** at different identity thresholds using CD-HIT.
5. **Perform functional annotation** by searching the original ORFs against the PFAM database with HMMER’s `hmmsearch`.

Each script in this repository corresponds to one or more of these steps.
