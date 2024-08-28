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
#     Description : Creating External EUtranCellrelations
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
local $cellDistributionFile=$currentdir."/../../customdata/cellDistribution.csv";
local $ltehandoverFile=$currentdir."/../../customdata/LTE_to_NR_handover.csv";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $SIMNUM=($LTE);
local $eutranfreqDistribution=&getENVfilevalue($ENV,"EUTRANFREQRELATIONS");
local @eutranfreqShare=split ':' , $eutranfreqDistribution;
local @sim1,@sim2,$NUMOFNODES;
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
    my $startNodeNum=&getENVfilevalue($ENV,"STARTNODENUM");
    $borderNodeNum=int ($borderNodeNum + $startNodeNum);
   #return($borderNodeName);
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
# Make MO & MML Scripts
################################
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
local $borderNodeNum=&getBorderNodeNum($ENV);
local $eutranfreqNum;
while ($NODECOUNT<=$DG2NUMOFRBS){

	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        if ($NODENUM>$borderNodeNum) {
            $eutranfreqNum=$eutranfreqShare[1];
        } else {
            $eutranfreqNum=$eutranfreqShare[0];
        }
        my $nrcellLdns = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my @nrCells = split '\n',$nrcellLdns;
        my $nrCellSize=@nrCells;
        for (my $eutranfrequency=1;$eutranfrequency<=$eutranfreqNum;$eutranfrequency++) {
            @MOCmds=qq^
SET
(
    mo "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1,GNBCUCP:EUtranFrequency=$eutranfrequency"
    exception none
    nrOfAttributes 1
    "reservedBy" Array Ref $nrCellSize
^;
               $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);               
            for my $cellLdn (@nrCells) {
               my @cell=split ";", $cellLdn;
               my @cellId=split "=",$cell[2];
               my @cid=split "=",$cell[4];
               my $cellname=$LTENAME . "-" . $cellId[1];
               @MOCmds=qq^              "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname,EUtranFreqRelation=$eutranfrequency"^;
               $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
            }
            @MOCmds=qq^
)^;
            $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
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

