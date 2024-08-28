#!/usr/bin/perl

#####################################################################################
##     Version     : 1.4
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
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-8
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-27262
#
#     Description : Modifying NRCellRelation reference attribute
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
#     Description  : Set 5G NR Internal Relations
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
    my $borderSimNum= (((($SIMEND - $SIMSTART + 1)*$DG2NUMOFRBS)*($minorShare/100))/$DG2NUMOFRBS);
    my $borderNodeNum=($borderSimNum * $DG2NUMOFRBS);
    my $startNodeNum=&getENVfilevalue($ENV,"STARTNODENUM");
    $borderNodeNum=int ($borderNodeNum + $startNodeNum);
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
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
my $borderNodeNum=&getBorderNodeNum($ENV);
while ($NODECOUNT<=$DG2NUMOFRBS){
	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT,$ENV);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        my $cells = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my $destinationCellsName = "NODE_" . $NODENUM . "_relations.csv"; #### For External Relations ###
        my $destinationCellsfile = $currentdir."../../customdata/".$destinationCellsName; #### For External Relations ###
        my @cellLdns = split "\n", $cells;
        my @freqCellLdns = split "\n", $cells;
        ## Chekk for border Node ##
        if ($NODENUM > $borderNodeNum) {
           $totalfrequencies = $majorfrequencyShare;
        } else {
           $totalfrequencies = $minorfrequencyShare;
        }
        # Set frequencies ##
        my $cellSize=@cellLdns;
        for (my $freqcount=1;$freqcount<=$totalfrequencies;$freqcount++) {
            @MOCmds=qq^
SET
(
    mo "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1,GNBCUCP:NRFrequency=$freqcount"
    exception none
    nrOfAttributes 2
    "arfcnValueNRDl" Int32 $freqcount
    "reservedBy" Array Ref $cellSize
^;    
            $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        
        ## reserved by to NR frequency ##
            for my $cellLdn (@cellLdns) {
               my @cell=split ";", $cellLdn;
               my @cellId=split "=",$cell[2];
               my @cid=split "=",$cell[4];
               my $cellType=$cellId[1];
               my $cellIdentity=$cellType . "-" . $cellType;
               my $cellname=$LTENAME . "-" . $cellId[1];
               ### Create NR Frequencies ####    
               @MOCmds=qq^          "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,NRFreqRelation=$freqcount"^;#end @MO
               $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
            }
            @MOCmds=qq^
)^;#end @MO
            $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        }
        ## reserve for frequency relation
        for my $freqCellLdn (@freqCellLdns) {
           my @freqcell=split ";", $freqCellLdn;
           my @freqLdn=split "=", $freqcell[3];
           my @freqcellId=split "=", $freqcell[4];
           my @freqcellType=split "=", $freqcell[2];
           my $cellname=$LTENAME . "-" . $freqcellType[1];
           my $destCellLdns = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;" | grep -v "CID=$freqcellId[1];");
           my @destLdns =split "\n", $destCellLdns;
           for (my $freqCount=1;$freqCount<=$totalfrequencies;$freqCount++) {
              my @destArray=();
              my $cellrelationCount=1;
              for my $destLdn (@destLdns) {
                 my @destfreqLdn=split ";", $destLdn;
                 my @destfreq=split "=", $destfreqLdn[3];
                 if ($freqCount==$destfreq[1]) {
                   my @destfreqcellId=split "=", $destfreqLdn[4];
                   my @destfreqcellType=split "=", $destfreqLdn[2];
                   my @extnodeLdn=split "=", $destfreqLdn[0];
                   my $extNodeName=&getNodeName($extnodeLdn[1],$ENV);
                   my $destCellIdentity=$extNodeName . "-" . $destfreqcellType[1];
                   my $destfreqRelation="ManagedElement=" . $LTENAME .",GNBCUCPFunction=1," . "NRCellCU=" . $cellname . ",NRCellRelation=" . $cellrelationCount;
                   push @destArray , $destfreqRelation;
                   $cellrelationCount++;
                 }
              }
              my $freqsize=@destArray;
              if ($freqsize!=0) {
                  @MOCmds=qq^
SET
(
    mo "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname,GNBCUCP:NRFreqRelation=$freqCount"
    exception none
    nrOfAttributes 1
    "reservedBy" Array Ref $freqsize
^;
                  $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
                  for my $reference (@destArray) {
                      @MOCmds=qq^           "$reference"^;
                      $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
                  }
                  @MOCmds=qq^
)^;
                  $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
              }
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

