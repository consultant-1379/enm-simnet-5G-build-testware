#!/usr/bin/perl
#
#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-67
#
#     Author      : Vinay Baratam
#
#     JIRA        : NSS-46327
#
#     Description : Updating nCI attribute for supported versions.
#
#     Date        : 27th Nov 2020
#####################################################################################
#####################################################################################
##     Version     : 1.2
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
#     Version     : 1.1
#
#     Revision    : CXP 903 6539-1-8
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-27262
#
#     Description : Creating External NRCells and external GNBCUCP mos
#
#     Date        : 18 October 2019
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
local $externalNrCellDataFile=$currentdir."../../customdata/externalNRcellInformation.csv";
local $termPointGNBTopologyFile=$currentdir."/../../topology/termPointGNBTopology.csv";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MOSCRIPT1="$scriptpath".${0}."1.mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local $MMLSCRIPT1="$scriptpath".${0}."1.mml";
local @MOCmds,@MMLCmds,@netsim_output,@netsim_output1;
local $NETSIMMOSCRIPT,$NETSIMMOSCRIPT1,$NETSIMMMLSCRIPT,$NETSIMMMLSCRIPT1,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $EXTERNALNRCELLRATIO=&getENVfilevalue($ENV,"EXTERNALNRCELLRATIO");
local $EXTERNALNRCELLNUM=&getENVfilevalue($ENV,"EXTERNALNRCELLNUM");
local $EXTERNALGNB=&getENVfilevalue($ENV,"EXTERNALGNB");
local $NrFrequenices=&getENVfilevalue($ENV,"NRFREQRELATIONS");
local $SIMNUM=$LTE;
local $nodeLinkFile=$currentdir."/../../customdata/nodeLinks.csv";
local @sim1,@sim2,$NUMOFNODES;
@version1= split /x/, $SIMNAME;
my $nodeVersion=`echo ${version1[0]} | sed 's/[A-Z]//g' | sed 's/[a-z]//g' | sed 's/-//g'`;
print "NodeVersion in numbers is $nodeVersion for comparision to support older version attributes";
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
if ( -e $termPointGNBTopologyFile){
    print "...removing old TermPointGNodeB topology\n";
    unlink "$termPointGNBTopologyFile";}
if ( -e $externalNrCellDataFile){
    print "...removing old externalNRcellInformation\n";
    unlink "$externalNrCellDataFile";}
###############################
my @externalnrratio = split /:/ , $EXTERNALNRCELLRATIO;
my @externalnrcell = split /:/ , $EXTERNALNRCELLNUM;
my @externalgnb = split /:/ , $EXTERNALGNB;
my @nrfreq = split /:/ , $NrFrequenices;
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
open(TH, '>', $termPointGNBTopologyFile) or die $!;
open(NH, '>', $externalNrCellDataFile) or die $!;
my $borderNodeNum=&getBorderNodeNum($ENV);
while ($NODECOUNT<=$DG2NUMOFRBS){
	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT,$ENV);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        my $cells = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my $line = qx(cat $nodeLinkFile | grep "NODE=$NODENUM-->");
        chomp $line;
        my @linkLine = split />/ , $line ;
        my @extnodenums = split "," , $linkLine[1];
        my $Count = 1;
        foreach $extnodenum ( @extnodenums ) {
           my $extNodeName = &getNodeName($extnodenum,$ENV);
           @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1"
    identity "$extNodeName"
    moType GNBCUCP:ExternalGNBCUCPFunction
    exception none
    nrOfAttributes 4
    "externalGNBCUCPFunctionId" String "$extNodeName"
    "gNBId" Int64 $extnodenum
    "gNBIdLength" Int32 22
    "pLMNId" Struct
        nrOfElements 2
        "mcc" String "128"
        "mnc" String "49"

)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1,GNBCUCP:ExternalGNBCUCPFunction=$extNodeName"
    identity "1"
    moType GNBCUCP:TermPointToGNodeB
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 0
    "termPointToGNodeBId" String "1"
)
^;
           $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
           print TH "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRNetwork=1,ExternalGNBCUCPFunction=$extNodeName,TermPointToGNodeB=1\n";
        }
           ## Chekk for border Node ##
        if ($NODENUM > $borderNodeNum) {
            $extnrcellcount = $externalnrratio[1];
            $extnrcellLimit = $externalnrcell[1];
            $nrfreqLimit = $nrfreq[1];
         } else {
            $extnrcellcount = $externalnrratio[0];
            $extnrcellLimit = $externalnrcell[0];
            $nrfreqLimit = $nrfreq[0];
         }
         my $totalextNrCellCount=1;
         my $nrfreqnum=1;
ENDNRCELL:for (my $extcount=1 ; $extcount <= $extnrcellcount ; $extcount++)
         {
             for (my $extNodeIndex=0 ; $extNodeIndex < (scalar @extnodenums); $extNodeIndex++)
             {
                  if ( $nrfreqnum > $nrfreqLimit) {
                     $nrfreqnum=1;
                  }
                  if ($totalextNrCellCount>$extnrcellLimit) {
                      last ENDNRCELL;
                  }
                  my $gnbBin=&generateBinaryEquivalent($extnodenums[$extNodeIndex],22);
                  my $extNodeName = &getNodeName($extnodenums[$extNodeIndex],$ENV);
                  my $extCellInfo = qx(cat $cellDistributionFile | grep "NODE=$extnodenums[$extNodeIndex];" | grep "CELL=$extcount;");
                  my @extCellLine = split /;/, $extCellInfo;
                  my @extCellId = split /=/ , $extCellLine[4];
                  my @nrfrequency = split /=/ , $extCellLine[3];
                  my $cidBin = &generateBinaryEquivalent($extCellId[1],14);
                  my $nciBin=$gnbBin . $cidBin;
                  my $nci = &convertBinary_to_Decimal($nciBin);
                  my $externalNRCellId =$extNodeName . "-" . $extcount;
                  print NH "NODE=$LTENAME,$nrfreqnum,$extNodeName,$extcount\n";
    if ($nodeVersion < 2342) {
                  @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1,GNBCUCP:ExternalGNBCUCPFunction=$extNodeName"
    identity "$externalNRCellId"
    moType GNBCUCP:ExternalNRCellCU
    exception none
    nrOfAttributes 2
    "externalNRCellCUId" String "$externalNRCellId"
    "nCI" Int64 $nci
    "nRFrequencyRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRNetwork=1,NRFrequency=$nrfreqnum"
    "plmnIdList" Array Struct 3
        nrOfElements 2
        "mcc" String "128"
        "mnc" String "49"

        nrOfElements 2
        "mcc" String "129"
        "mnc" String "50"

        nrOfElements 2
        "mcc" String "130"
        "mnc" String "51"
)
^;
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
else {
    @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1,GNBCUCP:ExternalGNBCUCPFunction=$extNodeName"
    identity "$externalNRCellId"
    moType GNBCUCP:ExternalNRCellCU
    exception none
    nrOfAttributes 2
    "externalNRCellCUId" String "$externalNRCellId"
    "nRFrequencyRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRNetwork=1,NRFrequency=$nrfreqnum"
    "plmnIdList" Array Struct 3
        nrOfElements 2
        "mcc" String "128"
        "mnc" String "49"

        nrOfElements 2
        "mcc" String "129"
        "mnc" String "50"

        nrOfElements 2
        "mcc" String "130"
        "mnc" String "51"
)
^;
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRNetwork=1,GNBCUCP:ExternalGNBCUCPFunction=$extNodeName,GNBCUCP:ExternalNRCellCU=$externalNRCellId"
    identity "1"
    moType GNBCUCP:ExternalBroadcastPLMNInfo
    exception none
    nrOfAttributes 1
    "externalBroadcastPLMNInfoId" String "1"
)
^;
                  $totalextNrCellCount++;
                  $nrfreqnum;
                  $NETSIMMOSCRIPT1=&makeMOscript("append",$MOSCRIPT1.$NODECOUNT,@MOCmds);
             }
         }
        push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT1); 
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
@MMLCmds=(".open ".$SIMNAME,
                  ".select ".$LTENAME,
                  ".start ",
                  "useattributecharacteristics:switch=\"off\"; ",
                  "kertayle:file=\"$NETSIMMOSCRIPT1\";"
                  );# end @MMLCmds
        $NETSIMMMLSCRIPT1=&makeMMLscript("append",$MMLSCRIPT1,@MMLCmds);
	$NODECOUNT++;
}# end outer while DG2NUMOFRBS

# execute mml script
@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
print "@netsim_output\n";
@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT1`;
# output mml script execution
close(TH);
close(NH);
print "@netsim_output\n";
################################
# CLEANUP
################################
$date=`date`;
# remove mo script
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
unlink "$NETSIMMMLSCRIPT1";
print "... ${0} ended running at $date\n";
################################
# END
################################
