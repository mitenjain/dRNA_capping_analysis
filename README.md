# dRNA_capping_analysis
Analysis code for the pre-print "Identification of high confidence human poly(A) RNA isoform scaffolds using nanopore sequencing" (NEB-UCSC collaboration)

# Data Availability
The data used in the preprint are available on ENA under accession number [PRJEB43374](https://www.ebi.ac.uk/ena/browser/view/PRJEB43374)

# Using Porechop
For adapter detection please download [Porechop](https://github.com/rrwick/Porechop)

### Adapter sequence

    CTCTTCCGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT

### Porechop search sequence

    TCCCTACACGACGCTCTTCCGA

The Porechop search sequence needs to be added to the adapters.py file either before installing Porechop, or in the adapters.py file that’s in your python site packages Porechop directory after installing.

The sequence could be inserted to the end of the ADAPTERS list

    Adapter('Barcode 97 (forward)',
        start_sequence=('BC97_45mer', 'TCCCTACACGACGCTCTTCCGA'))

You can also replace all other adapters with this one, but we haven’t had issues with other adapters being
used in place of this one.

### Porechop conditionsfor human data

    --barcode_diff 1 –barcode_threshold 74 -i file.fastq -b outputdirectory

### Note
 - The U’s in the fastq file sequence need to be converted to T’s before running Porechop.
 - Use NanoFilt or Guppy to filter the reads for q7 or better before Porechop (pass reads).

# new 5end isoform pipeline

 - Use the gtf files in [data](data) before executing the code

 - Execution for run_5end_isoform_pipeline_for_github.pl 

    perl run_5end_isoform_pipeline_for_github.pl --genome genome.fa --fai genome.fa.fai --tss annotated_tss.gtf --genes annotated_genes.gtf --bam bamfile.bam


    1. genome the reference genome used for the bam alignment. Expecting genome and not transciptome reference
    2. fai the reference genome index file
    3. tss a gtf file that has been processed such that only the 5, ends are used (a human TSS only genecode v32 is provided in the data folder)
    4. genes the gene annotation gtf file. This can be of all annotations, but we had better results when we filtered for only protein coding genes. (A human HAVANA only protein coding genes gencode v32 file is provided in the data folder)

 - Note, if you're not using dRNA nanopore sequencing data derived from human samples, you will also need to process an annottion gtf file into the TSS only file and either an unprocessed file or a file of only protein coding genes


# Contact
Please contact Logan Mulroney (lmulrone@soe.ucsc.edu) or Miten Jain (miten@soe.ucsc.edu) if you have any questions. 
