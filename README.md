VCF-file-manipulators
=====================
The purpose of this program is to calculate the average depth of variants across samples. 

Run the program:

    cat file | perl AvgDepth.pl or perl AvgDepth.pl file


The example of an input is the following:

    chr position  dbSNP  Ref Obs  Sample1  Sample2  Sample3   Sample4
    10	100821700	  .	    T	 C	  2,1,C	   7,1,C	  2,1,C    	2,1,C

The first five columns are similar to what is observed in a VCF file:
1: chromosom
2: position
3: dbSNP-has the variant been observed and recorded prior to this
4: Reference- the variant that is seen in teh reference genome
5: Observed - the variant observed with an alterative to the reference


Per sample: 
1st number: # of reads that observed the reference variant
2nd number: # of reads that observed the alternative variant
3rd number: the variant observed

This was created to examine the average depth observed across all 30 samples (made up of 3 groups of 10), to identify the samples with the lowest coverage, and to identify whether a group's mean coverage across the variant differed from other groups. 

An example of the output is as follows:

Chr	Base	dbSNP	Ref	Obs	Group1mean	Group2mean	Group3mean	Avg	Stdev	keep?	Group1min	Group2min	Group3min
10	100821700	.	 T	 C	 4.60	        2.00	       2.62	    3.11 3.40	 true	   AlZ9	    DLB10	     CON7
