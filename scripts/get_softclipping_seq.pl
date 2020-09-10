use strict;

#example of usage :
# perl get_softclipping_seq.pl $sam_file.sam 15 > output_file.sam


#single end reads in sam format :
my $sam = $ARGV[0];
my $generic = $sam;
$generic =~ s/.*\///g;
$generic =~ s/\.sam//;
my $CUTOFF_SCLENGTH = $ARGV[1];
my $direction = $ARGV[2]; #keep or remove
my $result = get_stuttering($sam); 


sub get_stuttering {
    my ($sam_file) =@_;
    my @result;
    open (FILE, $sam_file) or die;

    foreach my $line (<FILE>)
    {
	chomp $line;
	if ($line =~/\@HD/ || $line =~/\@SQ/) {print "$line\n";}
	if ($line !~/\@HD/ && $line !~/\@SQ/) #remove the header. 
	{
	    my @tmp = split /\t/, $line;
	    my $flag = $tmp[1];
	    my $match = $tmp[5];
	    my $seq_length = length($tmp[9]);
	    #remove internal insertion deletion and substritution to only keep the substitution on the side	
	    while ($match =~ /(.*[[:alpha:]])([0-9,\-]+)+M([0-9,\-]+)+I(.*)/g)
            {

                my $total = $2 - $3;
	     	$match = $1.$total."M".$4;
        
            }
	     while ($match =~ /^([0-9,\-]+)+M([0-9,\-]+)+I(.*)/g)
            {

                my $total = $1 - $2;
                $match = $total."M".$3;

            }

	    while ($match =~ /(.*[[:alpha:]])([0-9,\-]+)M([0-9,\-]+)D(.*)/g)
	    {

		my $total = $2 + $3;
		$match = $1.$total."M".$4;
	
	    }

	    while ($match =~ /^([0-9,\-]+)M([0-9,\-]+)D(.*)/g)
            {

                my $total = $1 + $2;
                $match = $total."M".$3;

            }
	    while ($match =~ /(.*[[:alpha:]])([0-9,\-]+)M([0-9,\-]+)M(.*)/g)
            {

                my $total = $2 + $3;
                $match = $1.$total."M".$4;
        
            }
	    while ($match =~ /^([0-9,\-]+)M([0-9,\-]+)M(.*)/g)
            {

                my $total = $1 + $2;
                $match = $total."M".$3;

            }


	    my $E5= 0; my $E3 = 0;
	    if ($match =~ /^[0-9]+[SH].*/) #S = softclip H = hard clipped. 
	    {
		$E5 = $match;
		$E5 =~ s/^([0-9]+)[SH].*/$1/;
	    }
	    if ($match =~ /.*[[:alpha:]][0-9]+[SH]$/)
	    {
		$E3 = $match;
		$E3 =~ s/.*[[:alpha:]]([0-9]+)[SH]$/$1/;
	    }
	    my $SCL= $E5;
	    if ($flag & 16) #reverse strand;
	    {
		$SCL=$E3;
	    }


	    if ($SCL<$CUTOFF_SCLENGTH && $direction eq "remove")
	    {
		print "$line\n";
	    }
	    if ($SCL>=$CUTOFF_SCLENGTH && $direction eq "keep")
            {
		print "$line\n";
            }
	    
	}
	
    }
    return (\@result)
}

    


