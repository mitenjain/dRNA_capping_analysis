# dRNA_capping_analysis
Analysis code for 5' capping-based nanopore direct RNA data (NEB-UCSC collaboration)

# Data Availability
The data used in the preprint are available here: http://public.gi.ucsc.edu/~miten/logan/dRNA_capping_data/

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

# Contact
Please contact Logan Mulroney (lmulrone@soe.ucsc.edu) or Miten Jain (miten@soe.ucsc.edu) if you have any questions. 
