use strict;

#given a list of read ID and the corresponding mapped read file (in sam format) return only the reads that are present in the read ID file (in sam format). 
#example of usage :
# perl get_reads_from_id.pl mapped_read.sam id_list.id > output_file.sam

#single end reads in sam format :
my $sam = $ARGV[0];
#corresponding ID file : list of id (ex : cd2c811b-42b7-4aac-9215-d90cec165c41)
my $idfile = $ARGV[1];

my $generic = $sam;
$generic =~ s/.*\///g;
$generic =~ s/\.sam//;

my $id2count = parse_id($idfile);

open (FILE, $sam) or die;

foreach my $line (<FILE>)
{
    chomp $line;
    if ($line =~/\@HD/ || $line =~/\@SQ/) {print "$line\n";}
    if ($line !~/\@HD/ && $line !~/\@SQ/) #remove the header. 
    {
	my @tmp = split /\t/, $line;
	my $id = $tmp[0];
	if ($$id2count{$id})
	{
	    #print only the mapped read if the id is present in the idfile :
	    print "$line\n";
	}
    }
}


sub parse_id {
    my ($file) =@_;
    my %result;
    open(ID, $file) or die "can't open $file\n";
    foreach my $line (<ID>)
    {
	chomp $line;
	$result{$line}++;
    }
    close ID;
    return\%result;
    
}
