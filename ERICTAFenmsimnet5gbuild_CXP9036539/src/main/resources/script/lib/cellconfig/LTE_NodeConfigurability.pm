#!/usr/bin/perl
#################################################################################
#   START LIB MODULE HEADER                                                     #
#################################################################################
# Version1    : LTE 15.17
# Revision    : CXP 903 0491-184-1
# Jira        : NSS-739
# Name	      :	LTE_NodeConfigurability (v1.0)
# Purpose     : Enable simulation to be created with nodes of more than one MIM version
# Public
# Subroutines :	verifyMimVersionSumToTotalNumberOfNodes
#               splitMimVersionsAndNodeCountsIntoTwoArrays
# Private
# Subroutines :	isolateMimVersionsAndNodeCountsFromSimName
#               getIndexOfSymbolOccuranceInSimNameWhereNodeMimVersionAndCountEnds
# Date        : 11 Nov 2015
# Who         : edalrey
#################################################################################
# Version2    : LTE 16.01
# Revision    : CXP 903 0491-186-1
# Jira        : NSS-1096
# Purpose     : Integrate upload simulation on nexus to ENM-LTE scripts
# Description : There is an additional '-' in simulation name between {network area},
#               e.g. RV / 5K, and DG2/PICO. => Need to separate name on the fourth
#               last instance of '-' symbol, instead of third last instnace.
# Date        : 03 Dec 2015
# Who         : edalrey
#################################################################################
# Version3    : LTE 16.01
# Revision    : CXP 903 0491-188-1
# Jira        : NSS-979
# Purpose     : add getNodeDistributionRatio subroutine
# Description : converts a valid parameter to a ratio
# Date        : 08 Dec 2015
# Who         : edalrey
#################################################################################
#   Environment                                                                 #
#################################################################################
package LTE_NodeConfigurability;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(verifyMimVersionSumToTotalNumberOfNodes splitMimVersionsAndNodeCountsIntoTwoArrays getNodeDistributionRatio);
use Cwd;
#################################################################################
#   Variables                                                                    #
#################################################################################
my $mimVersionAndNodeCountTerminator="-";
my $removeAfterTerminatorOccurance=3;
my $symbol="-";
my $nthLastSymbolInstance=4;
#################################################################################
#   Subroutines                                                                 #
#################################################################################
#--------------------------------------------------------------------------------
#   Public                                                                      -
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
#   Name:       verifyMimVersionSumToTotalNumberOfNodes
#   Description:checks to see if the sum of (nodes per MIM version) is the
#               same the total number of nodes in the simulation.
#	Params:		$simName,$totalNumberOfNodes
#	Example:	$nodesCountMatches = &verifyMimVersionSumToTotalNumberOfNodes($simName,$totalNumberOfNodes)
#	Return:		if the counts match return 1 (true), else return 0 (false)
#--------------------------------------------------------------------------------
sub verifyMimVersionSumToTotalNumberOfNodes {
	my ($simName,$totalNumberOfNodes) = @_;
	if ("" eq $totalNumberOfNodes) {
		die "Error: Total number of nodes not specified\n";
	}
   	my ($mimsRef,$countsRef) = &splitMimVersionsAndNodeCountsIntoTwoArrays($simName);

    	my @counts = @$countsRef;
	my $total = 0;
	foreach $count (@counts) {
		$total += $count;
	}
	my $boolean = ($total eq $totalNumberOfNodes);
	return $boolean ? 1 : 0;
}
#--------------------------------------------------------------------------------
#	Name:		splitMimVersionsAndNodeCountsIntoTwoArrays
#	Description:separates the MIM version and node count data in the
#               simulation name into two arrays, where the data are
#               related by the arrays' shared index
#	Params:		$simName
#	Example:	($mimsRef, $countsRef) = &splitMimVersionsAndNodeCountsIntoTwoArrays($simName)
#	Return:		two array refs; one referencing the array of MIM versions and the other
#			referencing the array of node counts.
#--------------------------------------------------------------------------------
sub splitMimVersionsAndNodeCountsIntoTwoArrays {
	my ($simName) = @_;
	my $mimVersionsAndNodeCounts = &isolateMimVersionsAndNodeCountsFromSimName($simName,$symbol,$nthLastSymbolInstance);

	my @mimVersionsAndNodeCounts = split('_',$mimVersionsAndNodeCounts);
	my @mims;
	my @counts;
	foreach $combo (@mimVersionsAndNodeCounts) {
		@components = split('x',$combo);
		push @mims, @components[0];
		push @counts, @components[1];
	}
	return (\@mims, \@counts);
}
#--------------------------------------------------------------------------------
#	Name:		getNodeDistributionRatio
#	Description:converts a valid parameter to a ratio
#	Params:		valid range 5 - 95
#	Example: 	@ratio = $getNodeDistributionRatio($percentage)
#	Return:		an array with 2 values representing a ratio passed parameter
#               i.e. $percentage = 75 equiavlent to 3:1
#--------------------------------------------------------------------------------
sub getNodeDistributionRatio {
    my ($percentageDistributedNodes) = @_;
    my @nodeDistributionRatio = ();

    my $remainder = (100-$percentageDistributedNodes);
    my $commonFactor = &gcf($percentageDistributedNodes,$remainder);
    @nodeDistributionRatio = (($percentageDistributedNodes / $commonFactor), ($remainder / $commonFactor));
    return @nodeDistributionRatio;
}
#--------------------------------------------------------------------------------
#   Private                                                                     -
#--------------------------------------------------------------------------------
sub isolateMimVersionsAndNodeCountsFromSimName {
	my ($simName) = @_;
	my $nodeCountEndsIndex = &getIndexOfSymbolOccuranceInSimNameWhereNodeMimVersionAndCountEnds($simName,$symbol,$nthLastSymbolInstance);

	my $mimVersionsAndNodeCounts = $simName;
	# Replaces the {$nodeCountEndsIndex}th occurance of '-' with ':'
	$mimVersionsAndNodeCounts =~ s{ (?: - [^-]*){$nodeCountEndsIndex} \K - }{:}xms;
	$mimVersionsAndNodeCounts =~ s/LTE//;
	$mimVersionsAndNodeCounts =~s/:.*//;
	return $mimVersionsAndNodeCounts;
}

sub getIndexOfSymbolOccuranceInSimNameWhereNodeMimVersionAndCountEnds {
	my ($simName) = @_;

	my $instancesOfSymbol = () = $simName =~ /\b$symbol\b/g;
	my $indexOfNthLastSymbol = $instancesOfSymbol-$nthLastSymbolInstance;
	return $indexOfNthLastSymbol;
}

sub gcf {
    my ($x,$y) = @_;
    ($x,$y) = ($y, $x % $y) while $y;
    return $x;
}
