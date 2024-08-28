#!/usr/bin/perl

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
#     Description : Creating External NRCellRelation Mos
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
local $extcellRelationTopologyFile=$currentdir."/../../topology/ExternalcellRelationTopology.csv";
local $externalNrCellDataFile=$currentdir."../../customdata/externalNRcellInformation.csv";
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
local $nodeLinkFile=$currentdir."/../../customdata/nodeLinks.csv";
local $nrcellRelationDistribution=&getENVfilevalue($ENV,"NRCELLRELATIONS");
local $EXTERNALNRCELLRATIO=&getENVfilevalue($ENV,"EXTERNALNRCELLRATIO");
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
    my $borderSimNum=((($SIMEND - $SIMSTART + 1)*$DG2NUMOFRBS)*($minorShare/100))/$DG2NUMOFRBS;
    #my $borderNodeNum=($DG2NUMOFRBS - (int ((($SIMEND - $SIMSTART + 1)*$DG2NUMOFRBS)*($minorShare/100))%$DG2NUMOFRBS));
    #my $borderNodeName=&getLTESimStringNodeName($borderSimNum,$borderNodeNum,$ENV);
    my $borderNodeNum=($borderSimNum * $DG2NUMOFRBS);
   #return($borderNodeName);
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
if(! -e $externalNrCellDataFile){
   print "ERROR : ExternalNRCellInformation not found.. Exiting the script..!\n";
   exit;}
################################
# MAIN
################################
print "...${0} started running at $date\n";
################################
if ( -e $extcellRelationTopologyFile){
    print "...removing old externalNRcellRelation topology\n";
    unlink "$extcellRelationTopologyFile";}
###############################
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
open(EH, '>', $extcellRelationTopologyFile) or die $!;
my $borderNodeNum=&getBorderNodeNum($ENV);
my $totalextnrrelations;
my $extnrcelllocalnum;
my @nrcellrelationShare= split /:/ , $nrcellRelationDistribution;
my @extnrcellshare=split /:/ , $EXTERNALNRCELLRATIO;
print "borderNodeNum=$borderNodeNum\n";
while ($NODECOUNT<=$DG2NUMOFRBS){
	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT,$ENV);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        my $cells = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my $line = qx(cat $externalNrCellDataFile | grep "NODE=$LTENAME,");
        my @cellLdns = split "\n", $cells;
        chomp $line;
        my @linkLines = split "\n", $line;
        my $extnrLinkcount = 1;
        if ($NODENUM > $borderNodeNum) {
           $totalextnrrelations = $nrcellrelationShare[1];
        } else {
           $totalextnrrelations = $nrcellrelationShare[0];
        }
        for my $cellLdn (@cellLdns) {
           my @cell=split ";", $cellLdn;
           my @cellId=split "=",$cell[2];
           my @cid=split "=",$cell[4];
           my $cellType=$cellId[1];
           my $cellIdentity=$cellType . "-" . $cellType;
           my $cellname=$LTENAME . "-" . $cellId[1];
           my $extnrrelationcount = scalar @cellLdns ;
           my $nrfrequencycount =1;
           while ($extnrrelationcount <= $totalextnrrelations) {
               if ($extnrLinkcount > (scalar @linkLines)) {
                   $extnrLinkcount = 1;
               }
               my @extNodeinfo = split "," , $linkLines[$extnrLinkcount - 1];
               my $extCellname = $extNodeinfo[2] . "-" . $extNodeinfo[3];
               @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname"
    identity "$extnrrelationcount"
    moType GNBCUCP:NRCellRelation
    exception none
    nrOfAttributes 3
    "nRCellRelationId" String "$extnrrelationcount"
    "nRFreqRelationRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,NRFreqRelation=$extNodeinfo[1]"
    "nRCellRef" Ref "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRNetwork=1,ExternalGNBCUCPFunction=$extNodeinfo[2],ExternalNRCellCU=$extCellname"
)
^; #end @MO
               $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
               print EH "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,NRCellRelation=$extnrrelationcount\n";
               $extnrrelationcount++;
               $extnrLinkcount++;
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
close(EH);
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

