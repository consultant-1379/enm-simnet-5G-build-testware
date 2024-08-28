#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_Relations (v0.0)
#
#     Description : Contains all functions related to updates for LTE OSS13A
#                   
#
#     CDM :
#
#     Functions : 
#                      
#############################################################################
#############################################################################
#    END LIB MODULE HEADER
#############################################################################
#############################################################################
# Version2    : LTE 16.4
# Revision    : CXP 903 0491-198-1
# Jira        : NSS-214
# Purpose     : Increase ExternalEUtrancell proxies design
# Description : Adding all the cells which are utilised in other cells of the 
#		node to Disallowed cells array such that it will try to create 
#		relations with new proxies inturn increase the number of 
#		ExternalEUtranCellProxies 
# Date        : Feb 2016
# Who         : xsrilek
#############################################################################
##########################################
#  Environment
##########################################
package LTE_Relations;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(buildAllRelations getInterEUtranCellRelations buildCelltoNode getCelltoNode buildNodeFrequencies getCellFrequency getNodeExternalEUtranCells getCellsFrequencies getNodesForCells isCellFDD isCellFDD_Upgrade store_Cells_to_Freq store_Cells_to_Node getCelltoNode_Upgrade);
use strict;
use Cwd;
use POSIX;
use LTE_General;

##########################################
# Vars
##########################################
my $gen=".."x1;
#my $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
my $ENV="CONFIG.env";
my @CellRelations=();
my @Cell_to_Node=();
# This is the variable that will hold the reference to 
# the output of &buildCelltoNode 
my $ref_to_Cell_to_Node;
my $FDD_FREQUENCIES=&getENVfilevalue($ENV,"FDD_FREQUENCIES");
my @FDD_FREQUENCIES=split(/\,/,$FDD_FREQUENCIES);
my $TDD_FREQUENCIES=&getENVfilevalue($ENV,"TDD_FREQUENCIES");
my @TDD_FREQUENCIES=split(/\,/,$TDD_FREQUENCIES);
my $TDDSIMS=&getENVfilevalue($ENV,"TDDSIMS");
my @TDDSIMS=split(/\,/,$TDDSIMS);
my $NUMOFRBS=&getENVfilevalue($ENV,"NUMOFRBS");
my $NETWORK_BREAKDOWN=&getENVfilevalue($ENV,"NETWORK_BREAKDOWN");
my @NETWORK_BREAKDOWN=split(/\,/,$NETWORK_BREAKDOWN);
my $EXTERNALENODEBFUNCTIONSPERNODE_BREAKDOWN=&getENVfilevalue($ENV,"EXTERNALENODEBFUNCTIONSPERNODE_BREAKDOWN");
my @EXTERNALENODEBFUNCTIONSPERNODE_BREAKDOWN=split(/\,/,$EXTERNALENODEBFUNCTIONSPERNODE_BREAKDOWN);
my $INTEREUTRANCELLRELATIONSPERCELL_BREAKDOWN=&getENVfilevalue($ENV,"INTEREUTRANCELLRELATIONSPERCELL_BREAKDOWN");
my @INTEREUTRANCELLRELATIONSPERCELL_BREAKDOWN=split(/\,/,$INTEREUTRANCELLRELATIONSPERCELL_BREAKDOWN);
my @Stored_Cell_to_Freq;
my @Stored_Cell_to_Node;
##########################################
# funcs
##########################################
#-----------------------------------------------------
#  Name : buildAllRelations
#  Description : This function creates blocks of nodes to feed to buildBlockRelations. It lets buildBlockRelations
#  decide which relations to create but it decides which nodes will relate to eachother. Therefore, this function 
#  has control over implementing the number of ExternaENodeBFunctions a node has.
#  This function returns a reference to @CellRelations so that the calling script is not exposed to the data 
#  structure. The calling script can pass the reference back here when it needs to call and function that does 
#  need to interact with the data structure e.g. &getInterEUtranCellRelations
#  The function should only be called once by any calling script, not repeatedly.
#
#  Params : @PRIMARY_NODECELLS 
#  Example : &buildAllRelations(@PRIMARY_NODECELLS);
#  Return : \@CellRelations
# Relations shall be stored in an array of arrays, @CellRelations
# The indices of the array shall be the CellIds
# In the same way as the array local (@PRIMARY_NODECELLS)=&buildNodeCells(@CELLPATTERN,$NETWORKCELLSIZE); shall be used to tie cells to nodes
# So shall the array @CellRelations be used to tie relations to cells
# $number_of_cells_in_node_1=@{$PRIMARY_NODECELLS[1]}
# $cell_id_of_cell_3_in_node_15=$PRIMARY_NODECELLS[15][2]
# @list_of_cellids_in_node_15=@{$PRIMARY_NODECELLS[15]}
# $number_of_cells_related_to_cell_3_in_node_15=@{$CellRelations[$PRIMARY_NODECELLS[15][2]]} #Could this be undef in an empty array?
# @list_of_cells_related_to_cell_3_in_node_15=@{$CellRelations[$PRIMARY_NODECELLS[15][2]]}
#
#
#
#------------------------------------------------------
sub buildAllRelations{
	my @PRIMARY_NODECELLS = @_;
	$ref_to_Cell_to_Node = &buildCelltoNode(\@PRIMARY_NODECELLS);
	my $start_node = 1;
	my $total_number_of_nodes = @PRIMARY_NODECELLS;
	my $idx=0;
	foreach my $network_percentage (@NETWORK_BREAKDOWN) {
		my $EXTERNALENODEBFUNCTIONSPERNODE = $EXTERNALENODEBFUNCTIONSPERNODE_BREAKDOWN[$idx];
		my $INTEREUTRANCELLRELATIONSPERCELL = $INTEREUTRANCELLRELATIONSPERCELL_BREAKDOWN[$idx];
		#print "External ENodeB Functions per node for $network_percentage of the network is $EXTERNALENODEBFUNCTIONSPERNODE and Intereutracncellrelations per cell is $INTEREUTRANCELLRELATIONSPERCELL\n";
		my $nodes_in_percentage = int(($total_number_of_nodes/100)*$network_percentage);
		my $last_node_in_percentage = $start_node - 1 + $nodes_in_percentage;
		if ($last_node_in_percentage > $total_number_of_nodes) {
			$last_node_in_percentage = $total_number_of_nodes;
		}
		my $blocksize = $EXTERNALENODEBFUNCTIONSPERNODE + 1;
		my $stop_node = $start_node - 1 + $blocksize;
		if ($stop_node > $total_number_of_nodes) {
			$stop_node = $total_number_of_nodes;
		}
		while ($start_node < $last_node_in_percentage) {
			my @nodeBlock = ($start_node..$stop_node);
			#print "Calling buildBlockRelations(\@nodeBlock,$INTEREUTRANCELLRELATIONSPERCELL,\@PRIMARY_NODECELLS)\n";
			&buildBlockRelations(\@nodeBlock,$INTEREUTRANCELLRELATIONSPERCELL,\@PRIMARY_NODECELLS);
			$start_node = $start_node + $blocksize;
			$stop_node = $stop_node + $blocksize;
			#print "Start node is $start_node and number_of_nodes is $number_of_nodes\n";
		}
		$idx++;
	}
	#print "Returning CellRelations\n";
	return(\@CellRelations);
}


#-----------------------------------------------------
#  Name : buildBlockRelations
#  Description : given an array of nodeids will create relations between the cells in the block.
#
#  Params : \@nodeBlock, $INTEREUTRANCELLRELATIONSPERCELL, \@PRIMARY_NODECELLS
#  Example : &buildBlockRelaltions(\@nodeBlock,$INTEREUTRANCELLRELATIONSPERCELL,\@PRIMARY_NODECELLS);
#  Return : Doesn't return anything but populates @CellRelations for the cells in the block.
# Relations shall be stored in an array of arrays, @CellRelations
# The indices of the array shall be the CellIds
# In the same way as the array local (@PRIMARY_NODECELLS)=&buildNodeCells(@CELLPATTERN,$NETWORKCELLSIZE); shall be used to tie cells to nodes
# So shall the array @CellRelations be used to tie relations to cells
# $number_of_cells_in_node_1=@{$PRIMARY_NODECELLS[1]}
# $cell_id_of_cell_3_in_node_15=$PRIMARY_NODECELLS[15][2]
# @list_of_cellids_in_node_15=@{$PRIMARY_NODECELLS[15]}
# $number_of_cells_related_to_cell_3_in_node_15=@{$CellRelations[$PRIMARY_NODECELLS[15][2]]} #Could this be undef in an empty array?
# @list_of_cells_related_to_cell_3_in_node_15=@{$CellRelations[$PRIMARY_NODECELLS[15][2]]}
#
#
#
#------------------------------------------------------
sub buildBlockRelations{
	my @nodeBlock = @{$_[0]};
	my $INTEREUTRANCELLRELATIONSPERCELL = $_[1];
	my @PRIMARY_NODECELLS = @{$_[2]};
	
	# First let's make a relation between the first cell of each node to all the other first cells in the block.
	# This will satisfy our requirement to relate to all the nodes in the block at least once.
	foreach my $node (@nodeBlock) {
		# empty what we have for related cells when starting on a new cell
		my @relatedCells = ();
		my $Cell = $PRIMARY_NODECELLS[$node][0];
		foreach my $dest_node (@nodeBlock) {
			if ($dest_node > $node) {
				my $dest_cell = $PRIMARY_NODECELLS[$dest_node][0];
				push (@relatedCells, $dest_cell);
			}
		}
		# Relate the cells to the cell
		#print "Relating Cell $Cell to @relatedCells\n";
		push (@{$CellRelations[$Cell]},  @relatedCells);
		# Make the relations bidirectional
		foreach (@relatedCells) {
			push(@{$CellRelations[$_]}, $Cell)
		}
	}
	
	# Now we need to make relations between the other cells in the block until all cells have $INTEREUTRANCELLRELATIONSPERCELL relations
	# I'm thinking we should relate to cells which already have the most relations in order to increase common neighbour's neighbours
	# That thinking may be incorrect. Could we run out of available cells for the last cell to relate to (uneven number)?
	
	# Build an array of all cells in the block.
	my @cells_in_block = ();
	foreach my $node (@nodeBlock) {
		my @cells_in_node = @{$PRIMARY_NODECELLS[$node]};
		push (@cells_in_block, @cells_in_node);
	}
	
	# Let's say that available cells are cells in the block that do not yet have $INTEREUTRANCELLRELATIONSPERCELL relations
	# When a cell get's enough relations we will remove it from @available_cells
	
	my @available_cells = @cells_in_block;
	#print "Available cells are @available_cells\n";
	
	# Need to build an array of candidate cells i.e. cells we are allowed to relate to
	
	foreach my $Cell (@cells_in_block) {
		my @disallowed_cells = ();
		my @candidate_cells = @available_cells;
		my $number_of_relations_cell_has = 0;
		if ($CellRelations[$Cell]) {
			$number_of_relations_cell_has = @{$CellRelations[$Cell]};
		}
		#print "number of relations cell has = $number_of_relations_cell_has \n";
		# Let's make a list of cells that $Cell cannot relate to.
		# Can't relate to cells in same node
		my $node = &getCelltoNode($Cell,$ref_to_Cell_to_Node);
		
		#print "node is $node\n";
		my @cells_in_node = @{$PRIMARY_NODECELLS[$node]};
		push (@disallowed_cells, @cells_in_node);
		# Can't relate to cells we already related to
		my @cells_already_related_to = (); 
		if ($CellRelations[$Cell]) {
			@cells_already_related_to = @{$CellRelations[$Cell]};
		}
		push (@disallowed_cells, @cells_already_related_to);

		#start CXP 903 0491-198-1
		#adding all the cells which are utilised in other cells of the node to Disallowed cells array 
		#such that it will try to create relations with new proxies inturn increase the number of ExternalEUtranCellProxies 
		#my $no_of_cells_node= scalar @cells_in_node;
		#my $counter=0;

		#while ($counter<$no_of_cells_node){
		#	my $cell_in_node=$PRIMARY_NODECELLS[$node][$counter];
		#	my @cells_already_related_to_cell_in_node=();
		#	if ($CellRelations[$cell_in_node]){
		#		@cells_already_related_to_cell_in_node =@{$CellRelations[$cell_in_node]};
		#		push (@disallowed_cells, @cells_already_related_to_cell_in_node);
		#	}
		#	$counter++;
		#}
		#end CXP 903 0491-198-1

		#print "Disallowed cells are @disallowed_cells\n";
		# Remove disallowed cells from candidate cells
		foreach my $disallowed_cell (@disallowed_cells) {
			my $idx = 0;
			foreach (@candidate_cells) {
				if ($disallowed_cell == $_) {
					splice (@candidate_cells, $idx, 1);
				}
				$idx++;
			}
		}
		#print "Candidate cells are @candidate_cells\n";
		my @sorted_candidate_cells = sort sortCells @candidate_cells;
		#print "Sorted Candidate cells are @sorted_candidate_cells\n";
		foreach my $destination_cell (@sorted_candidate_cells) {
			my $number_of_relations_destination_cell_has = 0;
			if ($CellRelations[$destination_cell]) {
				$number_of_relations_destination_cell_has = @{$CellRelations[$destination_cell]};
			}
			if ($number_of_relations_cell_has < $INTEREUTRANCELLRELATIONSPERCELL) {
				if ($number_of_relations_destination_cell_has < $INTEREUTRANCELLRELATIONSPERCELL) {
					# Relate the cell to the cell
					#print "Relating Cell $Cell to Cell $destination_cell\n";
					push (@{$CellRelations[$Cell]}, $destination_cell);
					# Make the relation bidirectional
					push (@{$CellRelations[$destination_cell]}, $Cell);
					$number_of_relations_cell_has++;
				}
			}
		}
	}	
}




# This is a subroutine to sort cells.
# Cells are sorted based on number of relations the cell already has (descending)
# Takes a list of cells.

sub sortCells {
	my $aa=0;
	my $bb=0;
	if ($CellRelations[$a]) {
		$aa=@{$CellRelations[$a]};
	}
	if ($CellRelations[$b]) {
		$bb=@{$CellRelations[$b]}; 
	}
    $bb <=> $aa;
    # Was playing with sorting descending versus ascending
    # Sorting descending ($bb <=> $aa) means we will relate to cells that already have the most relations
    # This helps ensure the maximum mutual neighbours and minimum ExternalEUtranCells per node
    # The downside is that we cannot achieve the exact InterEUtranCellRelations defined in the CONFIG file
    # Leaving the commented ascending sort here in code to reflect the decision made here.
    #$aa <=> $bb;
}


#-----------------------------------------------------
#  Name : buildCelltoNode
#  Description : Using PRIMARY_NODECELLS this function will return an array where the index represents the cell number and the 
# 		 
#
#  Params : \@PRIMARY_NODECELLS
#  Example : &buildCelltoNode(\@PRIMARY_NODECELLS);
#  Return : Populates @Cell_to_Node.
#
#------------------------------------------------------
sub buildCelltoNode{
	my @PRIMARY_NODECELLS = @{$_[0]};
	my $length = @PRIMARY_NODECELLS;
	for (my $node=1; $node < $length; $node++) {
		foreach my $Cell (@{$PRIMARY_NODECELLS[$node]}) {
			$Cell_to_Node[$Cell] = $node; 
		}
	}
	return(\@Cell_to_Node);
}


#-----------------------------------------------------
#  Name : getCelltoNode
#  Description : For a given cell get the node it is in 
# 		 
#
#  Params : $Cell, $ref_to_Cell_to_Node
#  Example : &getCelltoNode($Cell, $ref_to_Cell_to_Node);
#  Return : $node 
#
#------------------------------------------------------
sub getCelltoNode {
	my $Cell = $_[0];
    	my $ref_to_Cell_to_Node = $_[1];
    	my @Cell_to_Node = @{$ref_to_Cell_to_Node};
	my $node = $Cell_to_Node[$Cell];
	return($node);
}
#-----------------------------------------------------
#  Name : getCelltoNode_Upgrade
#  Description : 
#  Params : $Cell
#  Example : 
#  Return : 
#------------------------------------------------------
sub getCelltoNode_Upgrade {
	my $Cell = $_[0];
        my $arrSize = @Stored_Cell_to_Node;
	my $node = @Stored_Cell_to_Node[$Cell];
	return($node);
}

#-----------------------------------------------------
#  Name : getInterEUtranCellRelations
#  Description : Function to return the inter related Cells for a cell
#
#
#  Params : $Cell, $ref_to_CellRelations 
#  Example : &getInterEUtranCellRelations($Cell, $ref_to_CellRelations);
#  Return : @InterEUtranCellRelations 
#
#------------------------------------------------------
sub getInterEUtranCellRelations{
    my $Cell = $_[0];
    my $ref_to_CellRelations = $_[1];
	my @CellRelations = @{$ref_to_CellRelations};
    my @InterEUtranCellRelations = @{$CellRelations[$Cell]};
    return(@InterEUtranCellRelations);
}


#-----------------------------------------------------
#  Name : getNodeExternalEUtranCells
#  Description : get the external eutran cells for a node
#
#
#  Params : $Node, $ref_to_CellRelations, \@PRIMARY_NODECELLS 
#  Example : &getNodeExternalEUtranCells($Node, $ref_to_CellRelations, \@PRIMARY_NODECELLS);
#  Return : @ExternalEUtranCellRelations 
#
#------------------------------------------------------
sub getNodeExternalEUtranCells{
    my ($Node, $ref_to_CellRelations, $ref_to_PRIMARY_NODECELLS) = @_; 
	my @CellRelations = @{$ref_to_CellRelations};
    my @PRIMARY_NODECELLS = @{$ref_to_PRIMARY_NODECELLS};
    my @primarycells = @{$PRIMARY_NODECELLS[$Node]};
    # Cells related to the cells in our node
    my @ExternalEUtranCellRelations=();
    foreach my $cell (@primarycells) {
        my $ref_to_ExternalEUtranCellRelations=\@ExternalEUtranCellRelations;
        my @related_Cells = &getInterEUtranCellRelations($cell, $ref_to_CellRelations);
        @ExternalEUtranCellRelations=&union($ref_to_ExternalEUtranCellRelations, \@related_Cells);
    }
    return (@ExternalEUtranCellRelations);
}


#-----------------------------------------------------
#  Name : getNodesForCells
#  Description : given a list of cells return the nodes where they reside
#  this  function when given the ExternalEUtranCells for a Node will return
#  the ExternalENodeBFunctions for the Node
#
#
#  Params : $ref_to_Cell_to_Node, @Cells
#  Example : &getNodesForCells($ref_to_Cell_to_Node, @Cells);
#  Return : @Nodes 
#
#------------------------------------------------------
sub getNodesForCells{
    my ($ref_to_Cell_to_Node, @Cells) = @_;
    # Nodes where those cells reside
    my %nodes = ();
    foreach my $cell (@Cells) {
        my $node = &getCelltoNode($cell,$ref_to_Cell_to_Node);
        $nodes{$node}++;
    }
    my @Nodes = keys %nodes;
    return (@Nodes);
}


#-----------------------------------------------------
#  Name : buildNodeFrequencies
#  Description : This function actually builds an array 
#  with index representing Cell number and the elements
#  are the frequency of the cells. It is called buildNodeFrequencies
#  because there is an assumption that all cells on a node are 
#  on the same frequency.
#
#  Params : @PRIMARY_NODECELLS 
#  Example : &buildNodeFrequencies(\@PRIMARY_NODECELLS) 
#  Return : \@Cell_to_Freq 
#
#------------------------------------------------------
sub buildNodeFrequencies{
    my @Cell_to_Freq = ();
    my @PRIMARY_NODECELLS = @{$_[0]};
    my $length = @PRIMARY_NODECELLS;
    my $node=1;
    my $simnum = 1;
    my @Frequencies;
    while ($node < $length) {
	if (grep {$_ == $simnum} @TDDSIMS) {
	    @Frequencies = @TDD_FREQUENCIES;
	}else{
	    @Frequencies = @FDD_FREQUENCIES;
	}
	while (($node <= ($simnum*$NUMOFRBS))&&($node < $length)) {
            foreach my $Frequency (@Frequencies) {
                foreach my $Cell (@{$PRIMARY_NODECELLS[$node]}) {
                    $Cell_to_Freq[$Cell] = $Frequency;
                }
                $node++;
            }
	}
	$simnum++;
    }
    return(\@Cell_to_Freq);
}


#-----------------------------------------------------
#  Name : getCellFrequency
#  Description : This function returns the frequency of 
#  a given cell. The calling script must have called buildNodeFrequencies
#  at the start of the script (only once please).
#
#  Params : $Cell, \@Cell_to_Freq 
#  Example : &getCellFrequency($Cell, $ref_to_Cell_to_Freq) 
#  Return : $Frequency 
#
#------------------------------------------------------
sub getCellFrequency{
    my ($Cell, $ref_to_Cell_to_Freq) = @_;
    my @Cell_to_Freq = @{$ref_to_Cell_to_Freq};
    my $Frequency = $Cell_to_Freq[$Cell];
    return ($Frequency);
}

#-----------------------------------------------------
#  Name : getCellsFrequencies
#  Description : This function returns the union of frequencies of 
#  a list of cells. The calling script must have called buildNodeFrequencies
#  at the start of the script (only once please).
#
#  Params : $ref_to_Cell_to_Freq, @Cells 
#  Example : &getCellsFrequencies($ref_to_Cell_to_Freq, @Cells) 
#  Return : @Frequencies
#
#------------------------------------------------------
sub getCellsFrequencies{
    my ($ref_to_Cell_to_Freq, @Cells) = @_;
    my @Cell_to_Freq = @{$ref_to_Cell_to_Freq};
    my %Frequencies = ();
    foreach my $Cell (@Cells) {
        my $Frequency = $Cell_to_Freq[$Cell];
        $Frequencies{$Frequency}++;
    }
    my @Frequencies = keys %Frequencies;
    return (@Frequencies);
}

#-----------------------------------------------------
#  Name : isCellFDD
#  Description : Tests whether a cell is FDD by checking whether the frequency 
#  assigned to the cell is in @FDD_FREQUENCIES. Returns 0 for true. 1 for false
#
#  Params : $ref_to_Cell_to_Freq, $Cell 
#  Example : &isCellFDD($ref_to_Cell_to_Freq, $Cell) 
#  Return : 0 or 1
#
#------------------------------------------------------
sub isCellFDD{
    my ($ref_to_Cell_to_Freq, $Cell) = @_;
    my $Frequency = &getCellFrequency($Cell, $ref_to_Cell_to_Freq);
    foreach (@FDD_FREQUENCIES) {
        if ($_ == $Frequency) {
            return 1;
        }
    }
    return 0;
}

#-----------------------------------------------------
#  Name : isCellFDD_Upgrade
#  Description : Tests whether a cell is FDD by checking whether the frequency 
#  assigned to the cell is in @FDD_FREQUENCIES. Returns 0 for true. 1 for false
#
#  Params : @Cell_to_Freq, $Cell 
#  Example : &isCellFDD(@Cell_to_Freq, $Cell) 
#  Return : 0 or 1
#
#------------------------------------------------------
sub isCellFDD_Upgrade{
    my $Cell = $_[0];
    my $Frequency = @Stored_Cell_to_Freq[$Cell];
    foreach (@FDD_FREQUENCIES) {
        if ($_ == $Frequency) {
            return 1;
        }
    }
    return 0;
}
#-----------------------------------------------------
#  Name : store_Cells_to_Freq
#  Description : Store this large array in this library as moving it is 
#  slowing down the process. 
#  Params : $Cell_to_Freq
#-----------------------------------------------------
sub store_Cells_to_Freq{
    @Stored_Cell_to_Freq = @_;
}
#-----------------------------------------------------
#  Name : store_Cells_to_Node
#  Description : Store this large array in this library as moving it is 
#  slowing down the process. 
#  Params : $Cell_to_Node
#-----------------------------------------------------
sub store_Cells_to_Node{
    @Stored_Cell_to_Node = @_;
}
#--------------------------------------------------------
# get the union of two arrays. pass two array refs to this
sub union {
    my %union=();
    my @a=@{$_[0]};
    my @b=@{$_[1]};
    foreach (@a) { $union{$_} = 1 }
    foreach (@b) { $union{$_} = 1 }
    my @union = keys %union;
    return(@union)
}

1;
