use strict;

my $bed = $ARGV[0];
my $sam = $ARGV[1];

my $reads = parse_bed($bed);
open (SAM, $sam) or die "can't open $sam\n";
foreach my $line (<SAM>)
{
    chomp $line;
    if ($line =~/^\@SQ/ || $line =~/^\@PG/)
    {
	print "$line\n";
    }
    else {
	my @tmp = split /\t/, $line;
	my $id = $tmp[0];
	if ($$reads{$id})
	{
	    print "$line\n";
	}
    }
}

sub parse_bed {
    my ($bed)=@_;
    open (BED, $bed)or die "can't open $bed\n";
    my %reads;
    foreach my $line (<BED>)
    {
	chomp $line;
	my @tmp = split /\t/, $line;
	my $id = $tmp[3];

	$reads{$id}++;
	
    }
    close BED;
    return \%reads;
}
