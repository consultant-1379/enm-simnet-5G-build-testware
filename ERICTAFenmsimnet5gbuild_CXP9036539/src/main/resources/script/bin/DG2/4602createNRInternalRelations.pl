#!/usr/bin/perl

#####################################################################################
##     Version     : 2.0
##
##     Revision    : CXP 903 6539-1-27
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-33395
##
##     Description : Correcting NRCellRelation Id 
##
##     Date        : 30th Nov 2020
##
#####################################################################################
#####################################################################################
##     Version     : 1.9
##
##     Revision    : CXP 903 6539-1-25
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-32261
##
##     Description : NRM6.2 45K Cells Design Support
##
##     Date        : 8th Sep 2020
##
#####################################################################################
#####################################################################################
#     Version     : 1.8
#
#     Revision    : CXP 903 6539-1-8
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-27262
#
#     Description : Modified NRCellRelationId to nrrelationcount
#
#     Date        : 18 October 2019
#
####################################################################################
#####################################################################################
#     Version      : 1.2
#
#     Revision    : CXP 903 6539-1-3
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NSS-26474
#
#     Description  : Removing the hardcode of about number of nodes
#
#     Date         : 05th Aug 2019
#
#####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23610
#
#     Description  : Create 5G NR Internal Relations
#
#     Date         : April 2019
#
####################################################################################

####################
use FindBin qw($Bin);
use lib "$Bin/../../lib/cellconfig";
use Cwd;
use POSIX;
use LTE_CellConfiguration;
use LTE_General;
use LTE_OSS12;
use LTE_OSS13;
use LTE_Relations;
use LTE_OSS15;
####################
# Vars
####################
# start verify params
local @helpinfo=qq(Usage  : ${0} <sim name> <env file> <sim num>
Example: $0 LTEMSRBS-V415Bv6x160-RVDG2-FDD-LTE01 CONFIG.env 1);
if (!( @ARGV==3)){
   print "@helpinfo\n";exit(1);}
# end verify params
local $SIMNAME=$ARGV[0],$ENV=$ARGV[1],$LTE=$ARGV[2];
local $date=`date`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $cellDistributionFile=$currentdir."../../customdata/cellDistribution.csv";
local $cellRelationTopologyFile=$currentdir."/../../topology/cellRelationTopology.csv";
local $freqRelationTopologyFile=$currentdir."/../../topology/nrfreqRelationTopology.csv";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $nrfreqDistribution=&getENVfilevalue($ENV,"NRFREQRELATIONS");
local @nrfrequencyShare=split ":", $nrfreqDistribution;
local $majorfrequencyShare=$nrfrequencyShare[1];
local $minorfrequencyShare=$nrfrequencyShare[0];
local $totalfrequencies=0;
local $SIMNUM=$LTE;
local @sim1,@sim2,$NUMOFNODES;
####################
################################################################
sub getBorderNodeNum{
    my ($ENV)=@_;
    my $SIMSTART=&getENVfilevalue($ENV,"DG2SIMSTART");
    my $SIMEND=&getENVfilevalue($ENV,"DG2SIMEND");
    my $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
    my $NETWORKBREAKDOWN=&getENVfilevalue($ENV,"NETWORKBREAKDOWN");
    my @ntwkShare=split ":", $NETWORKBREAKDOWN ;
    my $minorShare=$ntwkShare[0];
    my $borderSimNum=(((($SIMEND - $SIMSTART + 1)*$DG2NUMOFRBS)*($minorShare/100))/$DG2NUMOFRBS);
    #my $borderNodeNum=($DG2NUMOFRBS - (int ((($SIMEND - $SIMSTART + 1)*$DG2NUMOFRBS)*($minorShare/100))%$DG2NUMOFRBS));
    #my $borderNodeName=&getLTESimStringNodeName($borderSimNum,$borderNodeNum,$ENV);
    my $borderNodeNum=($borderSimNum * $DG2NUMOFRBS);
    my $startNodeNum=&getENVfilevalue($ENV,"STARTNODENUM");
    $borderNodeNum=int ($borderNodeNum + $startNodeNum);
   #return($borderNodeName);
    return($borderNodeNum);
}
sub getNodeName{
    my ($extnodeNum,$ENV)=@_;
    my $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
    my $simNum=(int ($extnodeNum / $DG2NUMOFRBS));
    my $simCheck=($extnodeNum % $DG2NUMOFRBS);
    if ($simCheck==0) {
       $simNum=$simNum;
    } else {
       $simNum=($simNum + 1);
    }
    my $nodeNum=($extnodeNum % $DG2NUMOFRBS);
    if ($nodeNum==0) {
       $nodeNum=$DG2NUMOFRBS;
    }
    my $nodeName=&getLTESimStringNodeName($simNum,$nodeNum,$ENV);
   return($nodeName);
}

################################################################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
   unlink "$NETSIMMOSCRIPT";}
# check if SIMNAME is of type DG2
if(&isSimDG2($SIMNAME)=~m/NO/){exit;}
################################
# MAIN
################################
print "...${0} started running at $date\n";
################################
if ( -e $cellRelationTopologyFile){
    print "...removing old cellRelation topology\n";
    unlink "$cellRelationTopologyFile";}
if ( -e $freqRelationTopologyFile) {
    print "...removing old freqRelation topology\n";
    unlink "$freqRelationTopologyFile";}
###############################
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
open(RH, '>', $cellRelationTopologyFile) or die $!;
open(FH, '>', $freqRelationTopologyFile) or die $!;
my $borderNodeNum=&getBorderNodeNum($ENV);
while ($NODECOUNT<=$DG2NUMOFRBS){
	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT,$ENV);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        my $cells = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my $destinationCellsName = "NODE_" . $NODENUM . "_relations.csv";
        my $destinationCellsfile = $currentdir."../../customdata/".$destinationCellsName;
        my @cellLdns = split "\n", $cells;
        my @freqLdns = split "\n", $cells;
        my @reserveCellLdns = split "\n", $cells;
        @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:NRNetwork
    exception none
    nrOfAttributes 1
    "nRNetworkId" String "1"
)
^;
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        ## Chekk for border Node ##
        if ($NODENUM > $borderNodeNum) {
           $totalfrequencies = $majorfrequencyShare;
        } else {
           $totalfrequencies = $minorfrequencyShare;
        }

        for (my $frequencyCount=1;$frequencyCount<=$minorfrequencyShare;$frequencyCount++) {

        # Create frequencies ##
           @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1"
    identity "$frequencyCount"
    moType GNBCUCP:NRFrequency
    exception none
    nrOfAttributes 1
    "nRFrequencyId" String "$frequencyCount"
)
^;
           $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        }
        ## Create relations ##
        for my $cellLdn (@cellLdns) {
           my @cell=split ";", $cellLdn;
           my @cellId=split "=",$cell[2];
           my @cid=split "=",$cell[4];
           my $cellType=$cellId[1];
           my $cellIdentity=$cellType . "-" . $cellType;
           my $cellname=$LTENAME . "-" . $cellId[1];
           ### Create NR Frequencies ####
           for (my $frequencycount=1;$frequencycount<=$totalfrequencies;$frequencycount++) {
              @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname"
    identity "$frequencycount"
    moType GNBCUCP:NRFreqRelation
    exception none
    nrOfAttributes 2
    "nRFreqRelationId" String "$frequencycount"
    "nRFrequencyRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRNetwork=1,NRFrequency=$frequencycount"

)
^;
              $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
              print FH "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,NRFreqRelation=$frequencycount\n";
           }
           my $destinations = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;" | grep -v "$cellLdn");
           my @freqLdns = split "\n", $destinations;
           ### Create NR CellRelations ##########
           my $size=@freqLdns;
           my $relationCount=1;
               for my $totalLdn  (@freqLdns){
                  my @destLdn=split ";", $totalLdn;
                  my @destId=split "=", $destLdn[4];
                  my $destCid=$destId[1];
                  my @extnodeLdn=split "=", $destLdn[0];
                  my $extnodeNum=$extnodeLdn[1];
                  my @destcellTypeLdn=split "=", $destLdn[2];
                  my $destcellType=$destcellTypeLdn[1];
                  
                  my $extNodeName=&getNodeName($extnodeNum,$ENV);
                  my $destCellIdentity=$extNodeName . "-" . $destcellType;
                  my @nrfreq=split "=",$destLdn[3];
                  print RH "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,NRCellRelation=$relationCount\n";
                  @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname"
    identity "$relationCount"
    moType GNBCUCP:NRCellRelation
    exception none
    nrOfAttributes 3
    "nRCellRelationId" String "$relationCount"
    "nRFreqRelationRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,NRFreqRelation=$nrfreq[1]"
    "nRCellRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$destCellIdentity"
)
^; #end @MO
                 $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
                 $relationCount++;
               }
           
        }
push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT); 

	  
################################################
# build mml script 
################################################
  @MMLCmds=(".open ".$SIMNAME,
            ".select ".$LTENAME,
            ".start ",
            "useattributecharacteristics:switch=\"off\"; ",
            "kertayle:file=\"$NETSIMMOSCRIPT\";"         
  	   );# end @MMLCmds   
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
	$NODECOUNT++;
}# end outer while DG2NUMOFRBS

# execute mml script
@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
# output mml script execution 
close(FH);
close(RH);
print "@netsim_output\n";
################################
# CLEANUP
################################
$date=`date`;
# remove mo script
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
print "... ${0} ended running at $date\n";
################################
# END
################################

