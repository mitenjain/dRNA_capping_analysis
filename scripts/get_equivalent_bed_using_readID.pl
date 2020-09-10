use strict;


my $bed1 = $ARGV[0]; #file that contains the reads to print
my $sam1 = $ARGV[1]; #file that countains the reads id 

my $id2count = get_id($sam1);

open (BED, $bed1) or die "can't open $bed1\n";
foreach my $line (<BED>)
{
    chomp $line;
    my @tmp = split /\t/, $line;
    my $id = $tmp[3];
    if ($$id2count{$id})#reads with that id ! 
    {
	print "$line\n";
    }
}
close SAM2;


sub get_id{
    my ($file) = @_;
    my %result;
    
   open (FILE, $file) or die "can't open $file\n";
    foreach my $line (<FILE>)
    {
	chomp $line;
	my @tmp = split /\t/, $line;
	my $id = $tmp[0];
	 if ($id !~/\@SQ/)#header
	 {
	     $result{$id}++;
	 }
    }
    close FILE;
    return \%result;
}
