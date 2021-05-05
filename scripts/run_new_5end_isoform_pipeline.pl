use strict;
use Cwd;


my $DIR = getcwd;

#human genome :
my $genome = "./GRCh38.p3.genome.fa";
#index of the human genome (obtained using samtools faidx :
my $faidx = "./GRCh38.p3.genome.fa.fai";
#each transcripts TSS (+strand = start, - strand = end)
my $annotation_tss = "./gencode.v32.annotation_TSS_sorted.gtf";
#currated subset of genes used to identify genes with new TSS :
my $annotation_gene = "./gencode.v32.annotation_havana_genes.gtf";
#fastq files (adaptor trimmed away) 
my @fastq = <GM12878_06_18_19_NEB_negativeControl.fastq>;


my $size = @fastq;

for(my $i=0; $i<$size; $i++) 
{
    my $fq = $fastq[$i];
    my $generic = $fq;
    $generic =~ s/\.fastq//;
    $generic =~ s/.*\///g;
    $generic = "Run_".$generic;
    my $sam = $generic.".sam";
    #mapping =============================
    my $command_bis = "minimap2 --secondary=no -ax splice -k14 -uf $genome $fq > $sam ";
    my $bam = $generic.".bam";    
    my $sam_untrimmed = "".$sam;
    my $command1 = "samtools view -F 2048 -bS $sam | samtools sort -  -o $bam"; #remove remaining secondary alignments (despite -N 0)
    my $command3 = "samtools index $bam";
    #======================================

    # file names : ============================
    my $filtered_generic = $generic."filtered";
    my $filtered_sam = $filtered_generic.".sam";
    my $filtered_bam = $filtered_generic.".bam";
    
    my $tss = $filtered_generic."_all_TSS.gtf";
    my $tssbam = $filtered_generic."_all_TSS.bam";
    my $tssbed = $filtered_generic."_all_TSS.bed";
    my $new_tss_reads = $filtered_generic."_new_TSS.bed";
    my $new_tss_readid = $filtered_generic."_new_TSS.id";
    my $new_tss_untrimmed_reads_sam = $filtered_generic."_TMP.sam";
    my $new_tss_filter_sam = $filtered_generic."_new_TSS_filtered.sam";
    my $new_tss_filter_id = $filtered_generic."_new_TSS_filtered.id";
    my $new_tss_filter_bed = $filtered_generic."_new_TSS_filtered.bed";
    
    #===========================================

    #commands ============================================================
    # remove reads for which the softclip (or hard clip) is more than 15 bp in length (after removal of adaptor)
    my $command4 = "perl get_softclipping_seq.pl $sam 15 remove > $filtered_sam";
    my $command5 = "samtools view -bS $filtered_sam | samtools sort -  -o $filtered_bam";
    #get the TSS :
    my $command6 = "perl ~/exe/TSS-master/bam2firstbasebam.pl --bam $filtered_bam --out $tssbam --genome $faidx";
    my $command7 = "samtools index $tssbam";
    my $command8 = "bedtools bamtobed -i $tssbam > $tssbed";
    #keep only read ID for which the nearest annotated TSS is > 300 bp away.
    my $command9 = "bedtools closest -t first -s -d -a $tssbed -b $annotation_tss | awk 'BEGIN {FS=\"\\t\"};\$16>=300{print}' - > $new_tss_reads";
    #keep only reads that start within 50 bp ways from another read (2 read evidence or more) 
    my $command10 = "awk 'BEGIN {FS=\"\\t\"};\$8>=1{print \$4}' $new_tss_reads > $new_tss_readid";
    #check 
    my $command11 = "perl get_reads_from_id.pl $sam_untrimmed $new_tss_readid > $new_tss_untrimmed_reads_sam";
    my $command12 = "perl get_softclipping_seq.pl $new_tss_untrimmed_reads_sam 15 keep > $new_tss_filter_sam";
    my $command13 = "awk 'BEGIN {FS=\"\\t\"};\$1 !~ \"\@SQ\" {print \$1}' $new_tss_filter_sam > $new_tss_filter_id";
    my $command14 = "perl get_equivalent_bed_using_readID.pl $new_tss_reads $new_tss_filter_id > $new_tss_filter_bed";

#get the HAVANA gene name and coordinate containing new TSS. 
    #my $command18 = "bedtools intersect -s  -c -a $annotation_gene -b $new_tss_filtered_bam | grep \"protein_coding\" | awk 'BEGIN {FS=\"\\t\"};$10>1{print}' - > $final_result";
    my $sh = $generic.".sh";
    
    open (OUT, ">$sh") or die;
    print OUT '#!/bin/bash';print OUT "\n";
    print OUT '#$ -cwd';print OUT "\n";
    print OUT '#$ -j y';print OUT "\n";
    print OUT '#$ -S /bin/bash';print OUT "\n";
    print OUT "cd $DIR\n";
    print OUT "$command_bis\n";
    print OUT "$command1\n$command3\n";
    print OUT "$command4\n";
    print OUT "$command5\n";
    print OUT "$command6\n";
    print OUT "$command7\n";
    print OUT "$command8\n";
    print OUT "$command9\n";
    print OUT "$command10\n";
    print OUT "$command11\n";
    print OUT "$command12\n";
    print OUT "$command13\n";
    print OUT "$command14\n";
#print OUT "rm $sh*\n";
    
    
    my $command = "qsub $sh";
    system($command);
    
}




