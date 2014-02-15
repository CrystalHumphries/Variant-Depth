#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw( min max );

#----------------------------------------------------------------------#
#  TITLE:    AvgDepthVCF.pl                                            #
#                                                                      #
#  PURPOSE:  To create a table of the first five columns of a VCF      #
#            (chr, base location, documented SNP, reference SNP,       #
#            observed SNP) followed by the average depth of each group # 
#            of 10 samples, pre-suposing you have a total of 30, the   #
#            mean and stdev of each variant, whether the variant should#
#            be kept given a threshold, and the samples from each group#
#            with the lowest coverage.                                 #
#----------------------------------------------------------------------#


print_header();

while(<>){
    chomp;
    my @counts;
    my ( @samples )     = split( /\s+/ );
    my @alz_counts      = get_values ( splice( @samples, 5,10 ) );
    push ( @counts, average ( \@alz_counts ) );
    my @dlb_counts      = get_values( splice( @samples, 5, 10 ) );
    push ( @counts, average ( \@dlb_counts ) );
    my @con_counts      = get_values( splice( @samples, 5) );
    push ( @counts, average ( \@con_counts ) );
    my @min             = minimum( \@alz_counts, \@dlb_counts, \@con_counts );
    my @combined_arrays = ( @alz_counts, @dlb_counts, @con_counts );
    my $avg             = average( \@combined_arrays );
    my $stdev           = stdev  ( \@combined_arrays );
    my $keep            = determine($avg, $stdev, \@counts );
    print join("\t",@samples, @counts, $avg, $stdev, $keep, @min );
    print "\n";
}

#----------------------------------------------------------------------#
#  FUNCTION:  Minimum                                                  #
#                                                                      #
#  PURPOSE:   to find the sample with the lowest coverage of a variant #
#             from each of the three arrays that contain variant       #
#             depths per sample.                                       #
#----------------------------------------------------------------------#

sub minimum{
    my ( $ad, $dlb, $con )  = @_;
    my $group_no = 0;
    my @temp;
    for my $group ( $ad, $dlb, $con ){  
	my ($n, $sample_no);
	$sample_no = $n = 0;
	my $min = min( @$group );
	foreach ( @$group ){             # to find which sample in the group has the least coverage
	    $n++;
	    ( $_ == $min ) ? $sample_no = $n : next;
	}
	$group_no++;
	push ( @temp, "Group1_".$sample_no ) if ( $group_no == 1 );
	push ( @temp, "Group2_".$sample_no ) if ( $group_no == 2 );
        push ( @temp, "Group3_".$sample_no ) if ( $group_no == 3 );
    }
    return ( @temp );
}

sub print_header{
    print join("\t", "Chr", "Base", "dbSNP", "Ref", "Obs","Group1_mean", "Group2_mean", "Group3_mean", "Avg", "Stdev", "keep?", "Group1_min", "Group2_min", "Grou\
p3_min")."\n";
}

#---------------------------------------------------------------------#                                                                                          
#  FUNCTION:  determine                                               #                                                                                          
#                                                                     #                                                                                          
#  PURPOSE:   determine if the variant should be kept if a group's    #
#             mean lies outside of the standard deviation of the      #
#             sample                                                  #                                                                                      
#---------------------------------------------------------------------#  

sub determine{
    my ( $avg, $stdev, @counts ) = @_;
    my $top     = $avg + $stdev;
    my $bottom  = $avg - $stdev;
    my ( $keep, $n );
    foreach my $count (@counts){
        ( ( $count >= $bottom ) && ( $count <= $top ) ) ? $n += 0 : $n += 1;
    }
    ( $n>0 )? $keep = "false" : $keep = "true";
    return ( $keep );
}

#---------------------------------------------------------------------#                                                                                          
#  FUNCTION:  get_values                                              #                                                                                          
#                                                                     #                                                                                          
#  PURPOSE:   given an array of the following value                   #
#             coverage of refernce, cov of observed, variant          #
#             if will extract and add the total coverage and return   #                                                                                         
#             an array of coverage for the all items in the array     #
#---------------------------------------------------------------------#

sub get_values{
    my @samples_values = @_;
    my @temp;
    foreach my $n (@samples_values){
	my ($value) = split(/,/,$n);
	push(@temp, $value);
    }
    return (@temp);
}
    
#------------------------------------------------------------------------------------------------------------------# 
#  FUNCTION:  average                                                                                              # 
#                                                                                                                  #
#  PURPOSE:   determines avg of values in array                                                                    #                                             
#  Obtained from:http://edwards.sdsu.edu/labsite/index.php/kate/302-calculating-the-average-and-standard-deviation # 
#------------------------------------------------------------------------------------------------------------------# 

sub average{
        my ( $data ) = @_;
        if ( not @$data ) {
                die( "Empty array\n" );
        }
        my $total = 0;
        foreach ( @$data ) {
                $total += $_;
        }
        my $average = $total / @$data;
	my $rounded_average = sprintf("%.2f", $average);
        return $rounded_average;
}

#------------------------------------------------------------------------------------------------------------------#
#  FUNCTION:  stdev                                                                                                # 
#                                                                                                                  #   
#  PURPOSE:   determines stdev of values in array                                                                  #
#  Obtained from:http://edwards.sdsu.edu/labsite/index.php/kate/302-calculating-the-average-and-standard-deviation #
#------------------------------------------------------------------------------------------------------------------# 
sub stdev{
        my( $data ) = @_;
        return 0 if ( @$data == 1 );
        my $average = &average( $data );
        my $sqtotal = 0;
        
	foreach( @$data ) {
                $sqtotal += ( $average - $_ ) ** 2;
        }
	
        my $stdev = ( $sqtotal / ( @$data-1 ) ) ** 0.5;
	my $rounded_stdev = sprintf("%.2f", $stdev);
        return $rounded_stdev;
}
