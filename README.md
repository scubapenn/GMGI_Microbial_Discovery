# GMGI_Microbial_Discovery
The place to store all the scripts used to assemble and annotate metagenomes
The general idea with the pipeline is that we
1) trim the fastq files with trimomatic,
2) assemble with megahit
3) Call Open Reading Frames with Prodigal
4) Dereplicate the ORF with CD-hit at different % identities
5) We use the original ORFS in an hmmsearch against the PFAM database
