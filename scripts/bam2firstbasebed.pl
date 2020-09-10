#!/usr/bin/perl
use strict;
use Getopt::Long qw(GetOptions);
use File::Temp qw(tempfile);

my $error_sentence = "USAGE : perl $0 --bam bamfile \n";

=comment
Paired reads:

RF: first read (/1) of fragment pair is sequenced as anti-sense (reverse(R)), and second read (/2) is in the sense strand (forward(F)); typical of the dUTP/UDG sequencing method.

FR: first read (/1) of fragment pair is sequenced as sense (forward), and second read (/2) is in the antisense strand (reverse)

Unpaired (single) reads:

F: the single read is in the sense (forward) orientation

R: will not work!
 INPUT :
bam file X.bam (preferably generated through local alignment such as Bowtie --local)
out output file name
#OUTPUT :
#gtf file
=cut 

#OPTIONS :
my $bamfile;
my $OUT; #output file name (gtf file)

#================================= 
#get options :
GetOptions ("bam=s" => \$bamfile    # the bam file containing the mapped reads

    ) or die "USAGE : perl $0 $error_sentence";

#=================================
#if something went wrong, notify :
if (!$bamfile ) {die "$error_sentence"};
#================================= 
#start the main program :
my $generic =  clean_name($bamfile);
my $resulting_bam;
$resulting_bam = $bamfile;

#get the total number of reads that map to the genome.
my $count_mapped_read = `samtools view -c -F4 $resulting_bam`;
chomp $count_mapped_read;
print STDERR "number of reads mapping to genome = $count_mapped_read\n";

#create a tmp file containing the tmp bed. 
my $file_tmp = new File::Temp( UNLINK => 1 );
my $command = "bedtools bamtobed -cigar  -i $resulting_bam > $file_tmp"; 
system($command);

open(BED, $file_tmp) or die "can't open $file_tmp\n";

foreach my $line (<BED>)
{
    chomp $line;
    my ($start, $orientation)=undef;
    my @tmp = split /\t/, $line;
    my $chr = $tmp[0];
    $orientation = $tmp[5];
    if ($orientation eq "+")
    {
	$start = $tmp[1];
    }
    elsif ($orientation eq "-"){
	$start = $tmp[2];
    }
    $tmp[1]=$start;
    $tmp[2]=$start +1;
    my $new_line = join("\t",@tmp);
    print "$new_line\n";
}


close BED;

unlink($file_tmp);

sub clean_name {
    my ($file)=@_;
    my $generic = $file;
    $generic =~ s/\.tss//;
    $generic =~ s/.*\///g;
    return $generic;
}  
