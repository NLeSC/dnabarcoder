#!/bin/bash
cd /data/ProgLang/Python/dnabarcoder/data/CBSITS2
#Select sequences for each taxonomic level
../../aidscripts/selectsequences.py -i CBSITS2.fasta -c ITS_20211006.classification -rank species -o CBSITS2.species.fasta
../../aidscripts/selectsequences.py -i CBSITS2.fasta -c ITS_20211006.classification -rank genus -o CBSITS2.genus.fasta
../../aidscripts/selectsequences.py -i CBSITS2.fasta -c ITS_20211006.classification -rank family -o CBSITS2.family.fasta
../../aidscripts/selectsequences.py -i CBSITS2.fasta -c ITS_20211006.classification -rank order -o CBSITS2.order.fasta
../../aidscripts/selectsequences.py -i CBSITS2.fasta -c ITS_20211006.classification -rank class -o CBSITS2.class.fasta
#compute the similarity matrix, should be done for a small dataset that the current computer can handle. The current dataset is ~16K sequences
../../dnabarcoder.py sim -i CBSITS2.fasta -ml 50
# compute the similarity variation for different clades of the dataset at different taxonomic levels:
../../dnabarcoder.py variation -i CBSITS2.fasta -c ITS_20211006.classification -rank class,order,family,genus,species 
#If the similarity matrix is given then use the following command: 
../../dnabarcoder.py variation -i CBSITS2.fasta -c ITS_20211006.classification -rank class,order,family,genus,species -sim dnabarcoder/CBSITS2.sim
#Remove species complexes:
../../dnabarcoder.py remove -i CBSITS2.species.fasta -c ITS_20211006.classification -rank species -sim dnabarcoder/CBSITS2.sim
#Predict a global similarity cutoff at the species level. The prediction will be saved in the dnabarcoder/CBSITS2.predicted. The cut-offs will be saved in file dnabarcoder/CBSITS2.cutoffs.json and dnabarcoder/CBSITS2.cutoffs.json.txt 
../../dnabarcoder.py predict -i dnabarcoder/CBSITS2.species.diff.fasta -c ITS_20211006.classification -st 0.9 -et 1 -s 0.001 -rank species -prefix CBSITS2 -sim dnabarcoder/CBSITS2.sim
#Predict local similarity cutoffs at the species level for the genera, families, orders, classes, and phyla of the dataset. If there exists a similarity matrix then provided, otherwise not.
../../dnabarcoder.py predict -i dnabarcoder/CBSITS2.species.diff.fasta -c ITS_20211006.classification -st 0.7 -et 1 -s 0.001 -rank species -prefix CBSITS2 -higherrank genus,family,order,class,phylum -sim dnabarcoder/CBSITS2.sim -minSeqNo 30
#If the dataset is very large, then predict the local similarity cut-offs only at the immediate higher taxonomic level:
../../dnabarcoder.py predict -i dnabarcoder/CBSITS2.species.diff.fasta -c ITS_20211006.classification -st 0.7 -et 1 -s 0.001 -rank species -prefix CBSITS2 -higherrank genus -minSeqNo 30
#We can also use the original dataset and remove species complexes during the prediction:
../../dnabarcoder.py predict -i dnabarcoder/CBSITS2.species.diff.fasta -c ITS_20211006.classification -st 0.7 -et 1 -s 0.001 -rank species -prefix CBSITS2 -higherrank genus -minSeqNo 30
#Predict a global similarity cut-off at the genus level
../../dnabarcoder.py predict -i CBSITS2.genus.fasta -c ITS_20211006.classification -st 0.7 -et 1 -s 0.001 -rank genus -prefix CBSITS2
../../dnabarcoder.py predict -i CBSITS2.genus.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank genus -higherrank family,order,class,phylum -prefix CBSITS2 -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.family.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank family -prefix CBSITS2
../../dnabarcoder.py predict -i CBSITS2.family.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank family -higherrank order,class,phylum -prefix CBSITS2 -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.order.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank order -prefix CBSITS2
../../dnabarcoder.py predict -i CBSITS2.order.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank order -higherrank class,phylum -prefix CBSITS2 -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.class.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank class -prefix CBSITS2
../../dnabarcoder.py predict -i CBSITS2.class.fasta -c ITS_20211006.classification -st 0.5 -et 1 -s 0.001 -rank class  -higherrank phylum -prefix CBSITS2 -minseqno 30
#visualization 
../../dnabarcoder.py predict -i CBSITS2.fasta -c ITS_20211006.classification -rank species,genus,family,order,class 
../../dnabarcoder.py predict -i CBSITS2.fasta -c ITS_20211006.classification -rank species -higherrank genus -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.fasta -c ITS_20211006.classification -rank genus -higherrank family -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.fasta -c ITS_20211006.classification -rank family -higherrank order -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.fasta -c ITS_20211006.classification -rank order -higherrank class -minseqno 30
../../dnabarcoder.py predict -i CBSITS2.fasta -c ITS_20211006.classification -rank class -higherrank phylum  -minseqno 30
../../dnabarcoder.py visualize -i CBSITS2.fasta  -c ITS_20211006.classification -p 3 -n 10 -size 0.3
../../dnabarcoder.py best -i dnabarcoder/CBSITS2.cutoffs.json -c ITS_20211006.classification

