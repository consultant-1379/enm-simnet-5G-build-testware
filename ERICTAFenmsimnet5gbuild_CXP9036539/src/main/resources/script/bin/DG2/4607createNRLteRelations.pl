#!/usr/bin/perl
#####################################################################################
##     Version     : 1.7
##
##     Revision    : CXP 903 6539-1-67
##
##     Author      : Vinay Baratam
##
##     JIRA        : NSS-46327
##
##     Description : Removing localCellId attribute for latest versions
##
##     Date        : 27th Nov 2023
##
#####################################################################################
#####################################################################################
##     Version     : 1.6
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
#     Version     : 1.5
#
#     Revision    : CXP 903 6539-1-23
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-30194
#
#     Description : Setting PlmnId attribute in ExternalEnodeB Correctly
#
#     Date        : 20 May 2020
#
####################################################################################
#####################################################################################
#     Version     : 1.4
#
#     Revision    : CXP 903 6539-1-21
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-30194
#
#     Description : Setting PlmnId attribute to ExternalEnodeB
#
#     Date        : 30 April 2020
#
####################################################################################
#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-8
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-27262
#
#     Description : Creating External EUtranCells
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
#     Description  : Create 5G to LTE Relations
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
local $cellDistributionFile=$currentdir."/../../customdata/cellDistribution.csv";
local $eUtranFreqTopologyFile=$currentdir."/../../topology/eUtranFreqRelationTopology.csv";
local $ltehandoverFile=$currentdir."/../../customdata/LTE_to_NR_handover.csv";
local $externalEutranFile=$currentdir."/../../customdata/externalEUtranCells.csv";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $SIMNUM=($LTE);
local $eutranfreqDistribution=&getENVfilevalue($ENV,"EUTRANFREQRELATIONS");
local $extEutrancellnum=&getENVfilevalue($ENV,"EXTERNALEUTRANCELLNUM");
local @eutranfreqShare=split ':' , $eutranfreqDistribution;
local @sim1,@sim2,$NUMOFNODES;
local $eutranRelationDistribution=&getENVfilevalue($ENV,"EUTRANCELLRELATIONS");
local @eutranRelationShare=split ':' ,$eutranRelationDistribution;
@version1= split /x/, $SIMNAME;
my $nodeVersion=`echo ${version1[0]} | sed 's/[A-Z]//g' | sed 's/[a-z]//g' | sed 's/-//g'`;
print "NodeVersion in numbers is $nodeVersion for comparision to support older version attributes";
#########################################################
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
   #return($borderNodeName);
    my $startNodeNum=&getENVfilevalue($ENV,"STARTNODENUM");
    $borderNodeNum=int ($borderNodeNum + $startNodeNum);
    return($borderNodeNum);
}
####################
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
if ( -e $eUtranFreqTopologyFile){
    print "...removing old EutranRelation topology\n";
    unlink "$eUtranFreqTopologyFile";}
if ( -e $externalEutranFile ){
    print "...removing old ExternalEutranCells.csv\n";
    unlink "$externalEutranFile";}
################################
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
open(EH, '>', $eUtranFreqTopologyFile) or die $!;
open(EU, '>', $externalEutranFile) or die $!;
local $borderNodeNum=&getBorderNodeNum($ENV);
local $eutranfreqNum;
local $eutranRelationNum;
while ($NODECOUNT<=$DG2NUMOFRBS){

	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        my $totalextEUtrancellcount = 1;
        if ($NODENUM>$borderNodeNum) {
            $eutranfreqNum=$eutranfreqShare[1];
            $eutranRelationNum=$eutranRelationShare[1];
        } else {
            $eutranfreqNum=$eutranfreqShare[0];
            $eutranRelationNum=$eutranRelationShare[0];
        }
        @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:EUtraNetwork
    exception none
    nrOfAttributes 1
    "eUtraNetworkId" String "1"
)
^;
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        my $nrcellLdns = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my @nrCells = split '\n',$nrcellLdns;
        my $lteLdns = qx(cat $ltehandoverFile | grep "NRNODE=$NODENUM;");
        my @lteldns = split '\n', $lteLdns;
        for my $lteldn (@lteldns) {
           my @ldns =split ';' , $lteldn;
           my @lteNodeLdn=split '=' , $ldns[1];
           my @enbLdn=split '=' , $ldns[2];
           my @earfcndl=split '=' , $ldns[3];
           @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "$lteNodeLdn[1]"
    moType GNBCUCP:ExternalENodeBFunction
    exception none
    nrOfAttributes 3
    "eNodeBId" Int32 $enbLdn[1]
    "externalENodeBFunctionId" String "$lteNodeLdn[1]"
    "pLMNId" Struct
        nrOfElements 2
        "mcc" String "353"
        "mnc" String "57"

)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1,GNBCUCP:ExternalENodeBFunction=$lteNodeLdn[1]"
    identity "$enbLdn[1]"
    moType GNBCUCP:TermPointToENodeB
    exception none
    nrOfAttributes 1
    "termPointToENodeBId" String "$enbLdn[1]"
)
^;
           $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
           my $extEutrancellcount = 1;
           while ($extEutrancellcount<=$extEutrancellnum) {
              $eutranCellId=$lteNodeLdn[1] . "-" . $extEutrancellcount;
              if ( $totalextEUtrancellcount > $eutranRelationNum ) {
                 last;
              }
  if ($nodeVersion < 2342) {
              @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1,GNBCUCP:ExternalENodeBFunction=$lteNodeLdn[1]"
    identity "$eutranCellId"
    moType GNBCUCP:ExternalEUtranCell
    exception none
    nrOfAttributes 3
    "earfcndl" Int32 "$earfcndl[1]"
    "externalEUtranCellId" String "$eutranCellId"
    "localCellId" Int32 $extEutrancellcount
)
^;
              $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
              print EU "NODENAME=$LTENAME,ENODEB=$lteNodeLdn[1],EUTRANCELL=$eutranCellId\n";
              $extEutrancellcount++;
              $totalextEUtrancellcount++;
           }
  else {
  @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1,GNBCUCP:ExternalENodeBFunction=$lteNodeLdn[1]"
    identity "$eutranCellId"
    moType GNBCUCP:ExternalEUtranCell
    exception none
    nrOfAttributes 3
    "earfcndl" Int32 "$earfcndl[1]"
    "externalEUtranCellId" String "$eutranCellId"
)
^;
              $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
              print EU "NODENAME=$LTENAME,ENODEB=$lteNodeLdn[1],EUTRANCELL=$eutranCellId\n";
              $extEutrancellcount++;
              $totalextEUtrancellcount++;
      }
        }

        }
           for (my $eutranfrequency=1;$eutranfrequency<=$eutranfreqNum;$eutranfrequency++) {
               @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "$eutranfrequency"
    moType GNBCUCP:EUtranFrequency
    exception none
    nrOfAttributes 6
    "arfcnValueEUtranDl" Int32 $eutranfrequency
    "eUtranFrequencyId" String "$eutranfrequency"
)
^;
               $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);               
          }
          for my $cellLdn (@nrCells) {
               my @cell=split ";", $cellLdn;
               my @cellId=split "=",$cell[2];
               my @cid=split "=",$cell[4];
               my $cellname=$LTENAME . "-" . $cellId[1];
               for (my $eutranfreqCount=1;$eutranfreqCount<=$eutranfreqNum;$eutranfreqCount++) {
                   print EH "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,EUtranFreqRelation=$eutranfreqCount\n";
                   @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname"
    identity "$eutranfreqCount"
    moType GNBCUCP:EUtranFreqRelation
    exception none
    nrOfAttributes 1
    "eUtranFreqRelationId" String "$eutranfreqCount"
    "eUtranFrequencyRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,EUtraNetwork=1,EUtranFrequency=$eutranfreqCount"
)
^;
                  $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
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
close(EH);
# remove mo script
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
print "... ${0} ended running at $date\n";
################################
# END
################################

