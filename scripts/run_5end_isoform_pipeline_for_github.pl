use strict;
use Cwd;
use Getopt::Long qw(GetOptions);
my $DIR = getcwd;

my $error_sentence = "USAGE : perl $0 --genome genome.fa --fai genome.fa.fai --tss annotated_tss.gtf --genes annotated_genes.gtf --bam bamfile.bam";

#declaration
my $genome; my $faidx; my $annotation_tss; my $annotation_gene;my $bam;


#================================
#getting the options :
GetOptions ("genome=s" => \$genome,    # genome file in fasta format.
	    "fai=s" => \$faidx, #fai from genome file.
	    "tss=s" => \$annotation_tss, # annotated TSS in gtf format.
	    "genes=s" => \$annotation_gene, # annotated genes in gtf format. 
	    "bam=s" => \$bam # bam file. 
    ) or die "$error_sentence";
#================================
#checking if all the option are declared :
if (!$genome || !$faidx || !$annotation_tss || !$annotation_gene || !$bam) {die "$error_sentence\n";}
#=================================                                                                                      

my $generic = $bam;
$generic =~ s/\.bam//;
$generic =~ s/.*\///g;
$generic = "Run_".$generic;

my $sam = $generic.".sam";
my $tssbam = $generic."_all_TSS.bam";
my $tssbed = $generic."_all_TSS.bed";
my $new_tss_reads = $generic."_new_TSS.bed";
my $new_tss_readid = $generic."_new_TSS.id";
my $new_tss_sam = $generic."_new_TSS.sam";
my $new_tss_bam = $generic."_new_TSS.bam";
my $final = $generic."_new_TSS_protein_coding.bam";

# remove reads for which the softclip (or hard clip) is more than 15 bp in length (after removal of adaptor)
#get the TSS :
my $command0 = "samtools view -h $bam -o $sam";
my $command1 = "perl bam2firstbasebam.pl --bam $bam --out $tssbam --genome $faidx";
my $command2 = "samtools index $tssbam";
my $command3 = "bedtools bamtobed -i $tssbam > $tssbed";
#keep only read ID for which the nearest annotated TSS is > 300 bp away.
my $command4 = "bedtools closest -t first -s -d -a $tssbed -b $annotation_tss | awk 'BEGIN {FS=\"\\t\"};\$16>=300{print}' - > $new_tss_reads";
my $command5 = "awk 'BEGIN {FS=\"\\t\"};\$8>=1{print \$4}' $new_tss_reads > $new_tss_readid";
#check 
my $command6 = "perl get_reads_from_id.pl $sam $new_tss_readid > $new_tss_sam";
my $command7 = "samtools view -bS $new_tss_sam | samtools sort -  -o $new_tss_bam";
my $command8 = "samtools index $new_tss_bam";

#get the HAVANA gene name and coordinate containing new TSS. 
my $command9 = "bedtools intersect -s  -c -a $annotation_gene -b $new_tss_bam | grep \"protein_coding\" > $final";
system($command0);
system($command1);
system($command2);
system($command3);
system($command4);
system($command5);
system($command6);
system($command7);
system($command8);

    





