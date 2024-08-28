#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_CellConfiguration (v1.1)
#
#     Description :  Contains all LTE common functions that are required
#     to create a LTE cell network grid by (row,col). The network grid is
#     populated from west to east (row) and west to south (column) so
#     LTEcellnetworkgrid[1][2] is east of LTEcellnetworkgrid[1][1]
#     LTEcellnetworkgrid[2][1] is south of LTEcellnetworkgrid[1][1]
#     Each cell within the grid represents a netsim LTE node cell and adjacent
#     cells for the size of the defined network. Alls cells have unique cellids
#     each with a corresponding latitude longitude value with a 4km range
#     between cells.Cell adjacent cells are # cells are found in position
#     clockwise ie. N,N1,N2,N3,E,E1,E2,E3,S,S1,S2,S3,W,W1,W2,W3
#
#     Functions : generateCellPattern
#                 buildNodeCells
#                 getAllNodeCells
#                 getNodeCells
#                 getNodeAdjacentCells
#                 createNetworkCellSize
#                 getCellRowCol
#                 getNetworkGridSize
#                 getNodeFirstCell
#                 assignNodeCellsLatLong
#                 getNodeNumfromCellId
#                 getNodeNumfromFlexibleCellId
#                 generateBinaryEquivalent
#                 convertBinary_to_Decimal 
#############################################################################
#############################################################################
#    END LIB MODULE HEADER
#############################################################################
#############################################################################
# version2    :
# Revision    : CXP 903 0491-95-1
# Jira        : OSS-45751
# Purpose     : Non-Planned PCI
# Description : Instead of using 504 PCI values we will now be using 494 with
#               the remaining 0-9 values being used for non-planned PCI.
#                  ($physicalLayerCellIdGroup==168) changed to
#                  ($physicalLayerCellIdGroup==164)
# Date        : 16 Sept 2014
# who         : ecasjim
#############################################################################
#############################################################################
# Version3    : LTE 16A
# Revision    : CXP 903 0491-161-1
# Jira        : NETSUP-3085
# Purpose     : New Algorithm to derive the cell pattern based on the ratios
# Description : Implementation of the new Algorithm to derive the cell pattern
# Date        : June 2015
# Who         : lmieody
#############################################################################
#############################################################################
# Version4    : LTE 15.14
# Revision    : CXP 903 0491-171-1
# Jira        : CIP-9795
# Purpose     : Implement cell pattern based on the ratios
# Description : Modify generateCellPattern subroutine
# Date        : Sept 2015
# Who         : ejamfur
####################################################################
####################################################################
# Version5    : LTE 17A
# Revision    : CXP 903 0491-268-1
# Jira        : NSS-5225
# Purpose     : Reduce the time taken for Eutra Scripts for last sims.
# Description : To make build time uniform for all sims, logic of
#               generating data has been changed such that it will be
#               same for all nodes.
# Date        : Oct 2016
# Who         : xmitsin
#############################################################################
#############################################################################
# Version6    : 16.17
# Revision    : CXP 903 0491-272-1
# Jira        : NSS-7884
# Purpose     : Eutra Network data laoding optimization
# Description : Fix of optimization of Eutra Network data loading
# Date        : Nov 2016
# Who         : xkatmri
#############################################################################
##########################################
#  Environment
##########################################
package LTE_CellConfiguration;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(generateCellPattern buildNodeCells getAllNodeCells getNodeCells getNodeAdjacentCells createNetworkCellSize getCellRowCol getNetworkGridSize getNodeFirstCell assignNodeCellsLatLong getNodeNumfromCellId getNodeNumfromFlexibleCellId getLocationOfNodeFrom60KCellsArrayUsingPrimaryCellID generateBinaryEquivalent convertBinary_to_Decimal);
use File::Find;
use Cwd;
use POSIX;
use Geo::Forward;
use LTE_General;
##########################################
# Vars
##########################################
my $date=localtime,$delimeter=".."x1;
#########################################
# funcs
##########################################

#-----------------------------------------
#  Name : generateCellPattern
#  Description : Creates the cellpattern array
#  Params  : $ENV, CELLRATIOS
#  Example : &generateCellPattern($ENV,"CELLRATIOS")
#  Returns : @CELLPATTERN
#-----------------------------------------
sub generateCellPattern{
    #my $ENV="CONFIG.env";
    local ($ENV,$RATIOS)=@_;
    my $CELLRATIOS = &getENVfilevalue($ENV,$RATIOS);
    my %cellsPerNodeRatios = split /[,:]/, $CELLRATIOS;

    my $sumOfValues = 0;
    for my $numCells ( keys %cellsPerNodeRatios ) {
        $sumOfValues = $sumOfValues + $cellsPerNodeRatios{$numCells};
    }

    my @CELLPATTERN = ();

    for my $numCells ( sort {$cellsPerNodeRatios{$a} <=> $cellsPerNodeRatios{$b}} keys %cellsPerNodeRatios ) {
        my $count = $cellsPerNodeRatios{$numCells};
        my $step = $sumOfValues/$cellsPerNodeRatios{$numCells};
        for (my $i = 0; $i < $count; $i++) {
            my $index = 0;
            my $startIndex = int $step*$i;
            for ($index = $startIndex; $index < $sumOfValues; $index++) {
                if (!defined $CELLPATTERN[$index]) {
                    $CELLPATTERN[$index] = $numCells;
                    last;
                }
            }
            if ($index == $sumOfValues) {
                for ($index = $startIndex; $index >= 0; $index--) {
                    if (!defined $CELLPATTERN[$index]) {
                        $CELLPATTERN[$index] = $numCells;
                        last;
                    }
                }
            }
        }
    }
    return(@CELLPATTERN)
}
#-----------------------------------------
#  Name : buildNodeCells
#  Description : create an array of arrays allocating cells to nodes
#  The indices of the array shall correspond to the node number (0th element undef)
#  each element of the array shall reference an array 
#  containing the cells (grid integers) of the corresponding node
#  Params : $CELLPATTERN $NETWORKCELLSIZE
#  Returns : @LTE_nodetocells
#  $LTE_nodetocells[ENODEBID] contains an array of cells
#-----------------------------------------
sub buildNodeCells{
	local $NETWORKCELLSIZE = pop @_;
	local @CELLPATTERN = @_;
	local $networkgridsize=&getNetworkGridSize($NETWORKCELLSIZE);
	local @LTE_nodetocells;
	# define variables and specify initial values
	
	# enbid is an unique integer identifying the ENodeB in the network starting at 1
	local $enbid = 1;
	
	# cellid is an unique integer identifying the cell in the network starting at 1
	local $cellid = 1;
	
	# cell_no is an integer identifying which cell within the node we are refering to, starting at 1
	local $cell_no = 1;
	
	# width of grid is the Square root of wanted cells rounded up to nearest integer
	
	while ($cellid <= $NETWORKCELLSIZE) {
		foreach my $cells_in_enodeb (@CELLPATTERN) {
			$cell_no = 1;
			# while ($cell_no <= $cells_in_enodeb && $cellid <= $NETWORKCELLSIZE){
        while ($cell_no <= $cells_in_enodeb){# ensures full network cells output - epatdal
					# lowercase x and y are the coordinates of the current cell
					local $x = ($cellid-1) % $networkgridsize; 
					local $y = int(($cellid-1) / $networkgridsize); 
					$LTE_nodetocells[$enbid][$cell_no-1] = $cellid;
					$cell_no++;
					if ($y % 2 == 1) {
						if ($x % $networkgridsize == $networkgridsize -1) {
							$cellid++;
						} else {
							$cellid = $cellid - ($networkgridsize -1);
						}
					} else {
						$cellid = $cellid + $networkgridsize;
					}
			}
			$enbid++;
		}
	}
return(@LTE_nodetocells)		
}# end buildNodeCells
#-----------------------------------------
#  Name : getAllNodeCells
#  Description : returns all the cells
#  associated with a node by cellid
#  which is located in cellnetworkgrid
#  Params : $TYPE $COUNT node number, networkcellsize
#-----------------------------------------
sub getAllNodeCells{
     our ($TYPE,$COUNT,$NETWORKCELLSIZE)=@_; # node num
     our $NODECELLNUMSIZE=4;
     local @LTE_cellnetworkgrid,@LTE_nodecells,@LTE_fullnetworkgrid;
     # build the network grid assigning cellid
     @LTE_cellnetworkgrid=&createNetworkCellSize($NETWORKCELLSIZE);
     if($TYPE==2){
     # assign longitide latitude to network grid
     @LTE_fullnetworkgrid=&assignNodeCellsLatLong($NETWORKCELLSIZE,@LTE_cellnetworkgrid);
     }# end TYPE=2
     if($TYPE==1){
     # get the node cells and adjacent cells
     @LTE_nodecells=&getNodeCells($COUNT,@LTE_cellnetworkgrid);
     }# end TYPE=1
     if ($TYPE==1){return(@LTE_nodecells);}
     if ($TYPE==2){return(@LTE_fullnetworkgrid);}
}# end getAllNodeCells
##########################################
#-----------------------------------------
#  Name : assignNodeCellsLatLong
#  Description : assigns long lat altitude
#  physicalLayerSubCellId and physicalLayerCellIdGroup
#  values to a network grid of range 1.5 KM east per
#  row and south per column
#  -90 degrees S <------Latitude------->+90 degrees N
#  -180 degrees W<------Longitude------>+180 degrees E
#  Params : $networksize networkgrid
#  Returns :
#  cellid..latitutde..longitude..altitude..physicalLayerSubCellId..physicalLayerCellIdGroup
#  example : 129..320320900..-47623300..158..0..129
#-----------------------------------------
sub assignNodeCellsLatLong{
    local ($ynetworksize,@ycellnetworkgrid)=@_;
    local $yrow=1,$ycol=1,$ynetworkgridsize;
    local @fullnetworkgrid=(),$tempcelldata,$tempcelldata2;
    local $south=180,$east=90;
    # cell range 4km
    #local $southrange=4002.900;# alogorithm 4 km south
    #local $eastrange= 4013.900;# algorithm 4 km east
    # cell range 1.5km
    local $southrange=1501.0875;# alogorithm 1.5 km south
    local $eastrange=1505.2125;# algorithm 1.5 km east
    local $prevsouthlat,$prevsouthlon;
    local ($lat2,$lon2,$dir2);
    local $obj = Geo::Forward->new(); # default "WGS84"
    # latitude longitude direction distance
    $range=$eastrange;
    local ($lat1,$lon1,$dir,$dist)=(53.4227778, -7.9372222,$east,$range);# Athlone
    local $gosouth=0;
    local $antennaalituderange=1000,$altitude=30; # antenna altitude range in meters
    local $physicalLayerSubCellId=0,$physicalLayerCellIdGroup=1;
    # note first cell latitude longitude
    $prevsouthlat=$lat1;$prevsouthlon=$lon1;
    $ynetworkgridsize=&getNetworkGridSize($ynetworksize);
    # assign latitude longitude to each cell
    while ($yrow<=$ynetworkgridsize){
          # cycle thru network grid
          $tempcelldata=$ycellnetworkgrid[$yrow][$ycol];
          # assign cell latitude longitude
          $fullnetworkgrid[$yrow][$ycol]="$tempcelldata$delimeter".&changedecimalWGS84toint("latitude",$lat1)."$delimeter".&changedecimalWGS84toint("longitude",$lon1);
          # DEBUG START
          # outputs WGS84 decimal format and checked with distance.pl
          # $fullnetworkgrid[$yrow][$ycol]="$tempcelldata$delimeter$delimeter$lat1$delimeter$lon1";
          # DEBUG END
          # assign cell antenna altitude and physicalLayerSubCellId and physicalLayerCellIdGroup
          $tempcelldata2=$fullnetworkgrid[$yrow][$ycol];
          if($altitude==$antennaalituderange){$altitude=30;} # determine altitude

	
	  ############################################################
	  # Revision 1 START : Non-Planned PCI
	  ############################################################
          
	  if($physicalLayerCellIdGroup==164){ # determine PCI values
             $physicalLayerSubCellId++;$physicalLayerCellIdGroup=1;
             if($physicalLayerSubCellId==3){$physicalLayerSubCellId=0;}
          }# end determine PCI values

	  ############################################################
	  # Revision 1 END
	  ############################################################

         
          $fullnetworkgrid[$yrow][$ycol]="$tempcelldata2$delimeter$altitude$delimeter$physicalLayerSubCellId$delimeter$physicalLayerCellIdGroup";
          $altitude++;$physicalLayerCellIdGroup++;
          ########################
          # go south
          ########################
          if($ycol>=&getNetworkGridSize($ynetworksize)){
             $lat1=$prevsouthlat;$lon1=$prevsouthlon;
             $ycol=1;$yrow=$yrow+1;$dir=$south;$range=$southrange;
             $gosouth++;
          }# end if
          ########################
          # go east
          ########################
          if($gosouth==0){
             $ycol++;$dir=$east;$range=$eastrange;
           }# end if
          ################################
          # move forward thru network grid
          ################################
          ($lat2,$lon2,$dir2)=$obj->forward($lat1,$lon1,$dir,$range);
           if($gosouth>0){$prevsouthlat=$lat2;$prevsouthlon=$lon2;}
           $gosouth=0;
           $lat1=$lat2;$lon1=$lon2;
    }# end while
    return(@fullnetworkgrid);
}# end assignNodeCellsLatLong
#-----------------------------------------
#  Name : getNodeCells
#  Description : returns the node cells
#  where cell1 is the first cell
#        cell2 is east of cell1
#        cell3 is south of cell1
#        cell4 is south of cell2
#  and adjacent cells in a clockwise position
#  ie. N,N1,N2,N3,E,E1,E2,E3,S,S1,S2,S3,W,W1,W2,W3
#  Params : $COUNT node number cellnetworkgrid
#-----------------------------------------
sub getNodeCells{
    local ($nodenum,@cellnetworkgrid)=@_;
    local $cellnum=$NODECELLNUMSIZE; # number of cells per node
    local $arraycounter=0,$tempcell;
    local $row,$col,$cell1,$cell2,$cell3,$cell4;
    local @LTE_nodecells=(),$LTE_adjacentnodecells;
    if($nodenum>$NETWORKCELLSIZE/$NODECELLNUMSIZE)
       {$LTE_nodecells[$arraycounter]="ERROR NE $nodenum not within cell range";
       return(@LTE_nodecells);}# end if
    #find the first node cell1
    $cell1=&getNodeFirstCell($nodenum,@cellnetworkgrid);
    $LTE_adjacentnodecells=getNodeAdjacentCells($cell1,@cellnetworkgrid);
    $tempcell=$cell1."$delimeter".$LTE_adjacentnodecells;
    $tempcell=~s/\n//g;
    $LTE_nodecells[$arraycounter]=$tempcell;
    $tempcell="";
    $arraycounter++;;
    # find the second node cell2
    ($row,$col)=&getCellRowCol($cell1,$NETWORKCELLSIZE);
    $col++; # 1 cell east
    $cell2=$cellnetworkgrid[$row][$col];
    $LTE_adjacentnodecells=getNodeAdjacentCells($cell2,@cellnetworkgrid);
    $tempcell=$cell2."$delimeter".$LTE_adjacentnodecells;
    $tempcell=~s/\n//g;
    $LTE_nodecells[$arraycounter]=$tempcell;
    $tempcell="";
    $arraycounter++;
    # find the third node cell3
    ($row,$col)=&getCellRowCol($cell1,$NETWORKCELLSIZE);
    $row++; # 1 cell south of cell1
    $cell3=$cellnetworkgrid[$row][$col];
    $LTE_adjacentnodecells=getNodeAdjacentCells($cell3,@cellnetworkgrid);
    $tempcell=$cell3."$delimeter".$LTE_adjacentnodecells;
    $tempcell=~s/\n//g;
    $LTE_nodecells[$arraycounter]=$tempcell;
    $tempcell="";
    $arraycounter++;
    # find the fourth node cell4
    ($row,$col)=&getCellRowCol($cell3,$NETWORKCELLSIZE);
    $col++; # 1 cell east of cell3
    $cell4=$cellnetworkgrid[$row][$col];
    $cell3=$cellnetworkgrid[$row][$col];
    $LTE_adjacentnodecells=getNodeAdjacentCells($cell4,@cellnetworkgrid);
    $tempcell=$cell4."$delimeter".$LTE_adjacentnodecells;
    $tempcell=~s/\n//g;
    $LTE_nodecells[$arraycounter]=$tempcell;
    $arraycounter++;
    return(@LTE_nodecells);
}# end getNodeCells
#-----------------------------------------
#  Name : getNodeAdjacentCells
#  Description : returns the node cells
#  adjacent cells
#  where cell1 is the first cell
#        cell2 is east of cell1
#        cell3 is south of cell1
#        cell4 is south of cell2
#  Params : $COUNT node number cellnetworkgrid
#-----------------------------------------
sub getNodeAdjacentCells{
    local ($nodecell,@cellnetworkgrid)=@_;
    local $lrow,$lrow,$adjacentnodecells;
    local $lcounter=1,$element="";
    # find node cells adjacent cells
    # cells are found in position clockwise
    # ie. N,N1,N2,N3,E,E1,E2,E3,S,S1,S2,S3,W,W1,W2,W3
    # start : get North Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells="N";
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lrow--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get North Adjacent Cells
    # start : get North1 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."N1";
     $lcol++;$lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lrow--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get North1 Adjacent Cells
    # start : get North2 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."N2";
     $lcol=$lcol+2;$lcounter=1;
     while($lcounter<=2){
       $adjacentnodelcells=~s/\n//g;
       $lrow--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
    $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get North2 Adjacent Cells
    # start : get North3 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."N3";
     $lcol=$lcol+3;$lcounter=1;
     while($lcounter<=1){
       $adjacentnodelcells=~s/\n//g;
       $lrow--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get North3 Adjacent Cells
    # start : get East Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."E";
     $lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lcol++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get East Adjacent Cells
    # start : get East1 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."E1";
     $lrow++;$lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lcol++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get East1 Adjacent Cells
    # start : get East2 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."E2";
     $lrow=$lrow+2;$lcounter=1;
     while($lcounter<=2){
       $adjacentnodelcells=~s/\n//g;
       $lcol++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get East2 Adjacent Cells
    # start : get East3 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."E3";
     $lrow=$lrow+3;$lcounter=1;
     while($lcounter<=1){
       $adjacentnodelcells=~s/\n//g;
       $lcol++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get East3 Adjacent Cells
    # start : get South Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."S";
     $lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lrow++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get South Adjacent Cells
    # start : get South1 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."S1";
     $lcol--;$lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lrow++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get South1 Adjacent Cells
    # start : get South2 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."S2";
     $lcol=$lcol-2;$lcounter=1;
     while($lcounter<=2){
       $adjacentnodelcells=~s/\n//g;
       $lrow++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get South2 Adjacent Cells
    # start : get South3 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."S3";
     $lcol=$lcol-3;$lcounter=1;
     while($lcounter<=1){
       $adjacentnodelcells=~s/\n//g;
       $lrow++;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get South 3 Adjacent Cells
    # start : get West Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."W";
     $lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lcol--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get West Adjacent Cells
    # start : get West1 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."W1";
     $lrow--;$lcounter=1;
     while($lcounter<=3){
       $adjacentnodelcells=~s/\n//g;
       $lcol--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get West1 Adjacent Cells
    # start : get West2 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."W2";
     $lrow=$lrow-2;$lcounter=1;
     while($lcounter<=2){
       $adjacentnodelcells=~s/\n//g;
       $lcol--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get West2 Adjacent Cells
    # start : get West3 Adjacent Cells
    ($lrow,$lcol)=&getCellRowCol($nodecell,$NETWORKCELLSIZE);
     $adjacentnodelcells=$adjacentnodelcells."W3";
     $lrow=$lrow-3;$lcounter=1;
     while($lcounter<=1){
       $adjacentnodelcells=~s/\n//g;
       $lcol--;
       if ($lrow<1||$lrow>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       if ($lcol<1||$lcol>&getNetworkGridSize($NETWORKCELLSIZE)){last;}
       $adjacentnodelcells=$adjacentnodelcells."$delimeter".$cellnetworkgrid[$lrow][$lcol];
       $lcounter++;
     }# end while
     $adjacentnodelcells=$adjacentnodelcells."$delimeter";
    # end : get West3 Adjacent Cells
    $adjacentnodelcells=~s/\n//g;$adjacentnodelcells=~s/\*$//;
    return($adjacentnodelcells);
}# end getNodeAdjacentCells
#-----------------------------------------
#  Name : createNetworkCellSize
#  Description : creates a network grid by
#  (row,col) for the network cell size
#  Params : networksize - eg. 16000 cell network
#-----------------------------------------
sub createNetworkCellSize{
    my $networksize=$_[0];
    local $gridcellid=1,$networkgridsize;
    local $netsimcellid=1;
    $networkgridsize=&getNetworkGridSize($networksize);
    # populate networkgrid by row col starting @ 1,1
    # rows run south and cols run east
    for($row = 1; $row <= $networkgridsize; $row++){
        for($col = 1; $col <= $networkgridsize; $col++){
            $networkgrid[$row][$col]="$gridcellid";
            $gridcellid++;
            $netsimcellid++;
        } # end inner for
    }# end outer for
    return(@networkgrid);
}# end createNetworkCellSize
#-----------------------------------------
#  Name : getCellRowCol
#  Description : returns the cell networkgrid
#  row col location of a cell
#  Params : cell
#-----------------------------------------
sub getCellRowCol{
    local ($cellid,$networkgridsize)=@_;
    local $xcol,$xrow;
    $xcol=$cellid%(&getNetworkGridSize($networkgridsize));# mod
    $xrow=ceil($cellid/&getNetworkGridSize($networkgridsize)); # div

    # error fix in 16000 cell network where the last cell of each row
    # ex: 128 returns xcol=0
    if($xcol==0){$xcol=&getNetworkGridSize($networkgridsize);}  
    return($xrow,$xcol);
}# end getCellRowCol
#-----------------------------------------
#  Name : getNetworkGridSize
#  Description : returns the ceiling sqrt
#  of a cell network
#  example : getNetworkGridSize(16000)
#            returns 126+2=128
#  Params : networkgridsize ie. cell size
#-----------------------------------------
sub getNetworkGridSize{
    local $networksize=$_[0];
    local $networkgridsize="";
    $networkgridsize=sqrt($networksize);
    # need a square root table sgrt 16000 = 126
    # and rounded up = 127 and then + 1 = 128
    if ($networkgridsize=~/\./){# float
        $networkgridsize=ceil(sqrt($networksize))+1;
        if (($networkgridsize/2)=~/\./){# lose prime
            $networkgridsize=$networkgridsize+1;
        }# end inner if
    }# end if
    else {$networkgridsize=ceil(sqrt($networksize));}# end else
    return $networkgridsize;
}# end getNetworkGridSize
#-----------------------------------------
#  Name : getNodeFirstCell
#  Description : returns the first cell of
#  a node from the networkgrid
#  Params : nodenum cellnetworkgrid
#  Return : first node cell
#-----------------------------------------
sub getNodeFirstCell{
    local ($nodenum,@tcellnetworkgrid)=@_;
    local $trow=1,$tcol=1,$counter=1,$nodefirstcell=0;
    local $tnetworkgridsize=&getNetworkGridSize($NETWORKCELLSIZE);
    while($counter<=$nodenum){
          if ($tcol>$tnetworkgridsize){$trow=$trow+2,$tcol=1;}# end if
          if ($nodenum==$counter){
              $nodefirstcell=$tcellnetworkgrid[$trow][$tcol];
              last;}# end if
          $counter++;
          $tcol=$tcol+2;
    }# end while
    return($nodefirstcell);
}# end sub getNodeFirstCell
#-----------------------------------------
#  Name : changedecimalWGS84toint
#  Description : changes latitude longitude
#  decimal WGS84 to a 32 bit integer
#  with range between between -2,147,483,648
#  and 2,147,483,647
#  -90 degrees S <------Latitude------->+90 degrees N
#  -180 degrees W<------Longitude------>+180 degrees E
#  Params : type either latitude or longitude
#           decimal WGS84
#  example : changedecimalWGS84toint("latitude",53.4227778)
#-----------------------------------------
sub changedecimalWGS84toint{
    local ($ztype,$zvalue)=@_;
    local $direction,@decimalsplit,$intvalue,$tempintvalue;
    local $degrees,$minutes;
    # get direction
    if (($ztype eq "latitude")&&($zvalue>0))
        {$direction="N";}
    if (($ztype eq "latitude")&&($zvalue<0))
        {$direction="S";$zvalue=~s/-//;}
    if (($ztype eq "longitude")&&($zvalue>0))
        {$direction="E";}
    if (($ztype eq "longitude")&&($zvalue<0))
        {$direction="W";$zvalue=~s/-//;}
    # convert GPS coordinates from decimal WGS84
    # conversion site
    # http://boulter.com/gps/?c=37+23.516+-122+02.625#53.4227778%20-7.9372222
    #@decimalsplit=split(/\./,$zvalue);
    #$degrees=$decimalsplit[0];
    #$minutes=sprintf "%.3f",($zvalue-$degrees)*60;
    # convert GPS to 32 bit integer
    # info site
    # http://propeller.wikispaces.com/integer_navigation
    #$intvalue=($degrees*60+$minutes)*100000;
    #-----------------------------------------------------
    # start : wgs84 conversion amendment in OSS PCI 11.2.8
    #-----------------------------------------------------
    $tempintvalue=($zvalue*1000000);
    $intvalue=sprintf "%.0f", $tempintvalue; # rounded
    #-----------------------------------------------------
    # end : wgs84 conversion amendment in OSS PCI 11.2.8
    #-----------------------------------------------------
    if(($direction eq "S")||($direction eq "W")){
       $intvalue="-".$intvalue;
    }# end if
    return ($intvalue);
}# end sub
#-----------------------------------------
#  Name : getNodeNumfromCellId
#  Description : returns the node num
#  for a cellid
#  Params : $cellid, networkcellsize
#-----------------------------------------
sub getNodeNumfromCellId{
  local ($NNcellid,$NNnetworksize)=@_;
  local $nrow=1,$ncol=1,$nnodenum=1;
  local $temprow=1,$nodebordercol=1;
  local $nodecheckcomplete=0;
  local @NN_cellnetworkgrid=&createNetworkCellSize($NNnetworksize);
  local $nnetworkgridsize=&getNetworkGridSize($NNnetworksize);
  local $ttlnodes=$NNnetworksize/4,$colexceed=0;
  if($NNcellid==$NN_cellnetworkgrid[$nrow][$ncol]){return($nnodenum);}
  while($nnodenum<=$ttlnodes){
       if($NNcellid==$NN_cellnetworkgrid[$nrow][$ncol]){last;}
       $ncol++;
       if($NNcellid==$NN_cellnetworkgrid[$nrow][$ncol]){last;}
       $nrow++;$ncol--;
       if($NNcellid==$NN_cellnetworkgrid[$nrow][$ncol]){last;}
       $ncol++;
       if($NNcellid==$NN_cellnetworkgrid[$nrow][$ncol]){last;}
       $nrow--;$ncol=$ncol+1;
       if($ncol>$nnetworkgridsize){$nrow=$nrow+2;$ncol=1;}# max col width
       $nnodenum++;
  }# end while
  # trap error when cellid outside network grid range
  if($nnodenum>$ttlnodes){$nnodenum="ERROR";}
  return($nnodenum);
}# end getNodeNumfromCellId
#-----------------------------------------
#  Name : getNodeNumfromFlexibleCellId
#  Description : returns the node num
#  for a cellid from a network with 
#  flexible cellnums supported from LTE12.2 
#  ex: 6,3,3,6,1
#  example : $nodenum=&getNodeNumfromFlexibleCellId($cellid,$networkcellsize,@PRIMARY_NODECELLS);
#  Params : cellpattern,cellid,networkcellsize
#-----------------------------------------
sub getNodeNumfromFlexibleCellId{
  local ($cellid,$networkcellsize,$nodeNum,$blockSize,@PRIMARY_NODECELLS)=@_;
  #local $nodenum=1;
  #local $nodenum=&getLocationOfNodeFrom60KCellsArrayUsingPrimaryCellID($cellid);
  local $nodenum=&getclosestNodeNumfromNode($nodeNum,$blockSize);
  local $ttlnodes=$networkcellsize/4;
  local @primarycells;
  local $match=0;
  
  #my $filename = 'primary_node_cells_mod_2.txt';
  #open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
  
  while ($nodenum<=$ttlnodes){# while cycle thru network
        # get node primary cells
        @primarycells=@{$PRIMARY_NODECELLS[$nodenum]};
        $element="";
        foreach $element(@primarycells){
	#print $fh "Primary Node Cells: $element, Cell ID: $cellid\n";
        
          if($element==$cellid){
                     $match=1;  
		     #print $fh "Node: $nodenum, Primary Cell: $element \n";
                     last; # match found for cellid
                  }# end if
        }# end foreach
  if($match==1){last;}# found cellid 
  $nodenum++;
  }# end while cycle thru network
  if($match==0){$nodenum="ERROR cannot find cell $cellid";} 
  return($nodenum);
  
#close $fh; 

}# end getNodeNumfromFlexibleCellId

#---------------------------------------------------------
#  Name : getclosestNodeNumfromNode
#  Description : returns the closest node num to node
#  with in which all relations will be availabel
#  example : $nodenum=&getclosestNodeNumfromNode($nodeNum,$blockSize);
#  Params : cellpattern,cellid,networkcellsize
#---------------------------------------------------------

sub getclosestNodeNumfromNode{
  local($nodeNum, $blockSize)=@_;
  local $blockNum=int($nodeNum/$blockSize);
  local $blockRem=($nodeNum % $blockSize);

  $blockNum= ($blockRem==0) ? ($blockNum-1) : ($blockNum);
  local $closeNodeNum= ($blockNum==0) ? ("1") : (($blockNum*$blockSize)+1);

  return $closeNodeNum;
}

#-----------------------------------------
#  Name : getLocationOfNodeFrom60KCellsArrayUsingPriimaryCellID
#  Description : Instead of traversing through 60K, we will find location by algorithm
#  Params : Primary Cell ID
#-----------------------------------------
sub getLocationOfNodeFrom60KCellsArrayUsingPrimaryCellID{
    local ($cellid)=@_;
    local $locationInArray, $element;
    local $ENV="CONFIG.env";
    local $CELLPATTERN=&getENVfilevalue($ENV,"CELLPATTERN");
    local @CELLPATTERN=split(/\,/,$CELLPATTERN);
    
    $TotalCellInPattern = eval join '+', @CELLPATTERN; 
    $TotalNodesInPattern = @CELLPATTERN;
    $temp = int($cellid / $TotalCellInPattern); 
    $locationInArray = int($cellid / $TotalCellInPattern) * $TotalNodesInPattern ;
    return($locationInArray);
}# end getCellRowCol

#-----------------------------------------
#  Name : 
#  Description : Generate Primary Binary Equivalent of CellIds
#  Params : NRCell Id or GNBId
#-----------------------------------------
sub generateBinaryEquivalent {
   local ($decimal_input ,$bitlength) = @_ ;
   local $num;
   local $remainder;
   while($decimal_input >= 1)
   {
      if($decimal_input == 1) {

          $num .= 1;
          last;
      }
      $remainder = $decimal_input%2;
      $num .= $remainder;
      $decimal_input = $decimal_input/2;
   }
   my $binaryOutput = scalar reverse($num);
   my $output=sprintf ("%0${bitlength}d", $binaryOutput );
   return($output);
}
#-----------------------------------------
#  Name : 
#  Description : Generate Primary Binary Equivalent of CellIds
#  Params : NRCell Id or GNBId
#-----------------------------------------
sub convertBinary_to_Decimal {
   local ($binary_input) = @_;
   local @bits = reverse(split(//, $binary_input));
   local $sum = 0;
   for my $i (0 .. $#bits) {
       next unless $bits[$i];
       $sum += 2 ** $i;
   }
   return($sum);
}
########################
# END LIB MODULE
#######################
