#!/usr/bin/perl
######################################################################################
#     Version     : 1.11
#
#     Revision    : CXP 903 6539-1-67
#
#     Author      : Vinay Baratam
#
#     JIRA        : NSS-46327
#
#     Description : Updating GNBCUCP:UeMeasControl MO for supported version.
#
#     Date        : 27th Nov 2023
######################################################################################
#     Version     : 1.10
#     Revision    : CXP 903 6539-1-64
#     Author      : Saivikas Jaini
#     JIRA        : NSS-40032
#     Description : Reverting the NRSectorcarrier latitude,longitude attribute changes
#     Date        : 25th Aug 2023
######################################################################################
#     Version     : 1.9
#     
#     Revision    : CXP 903 6539-1-59
#     
#     Author      : Vinay Baratam
#     
#     JIRA        : NSS-42322
#     
#     Description : Updating code base to support the attributes for both older and newer versions.
#     
#     Date        : 21st Feb 2023
######################################################################################
#     Version     : 1.8
#     
#     Revision    : CXP 903 6539-1-56
#     
#     Author      : Saivikas Jaini
#     
#     JIRA        : NSS-41026
#     
#     Description : Updating latitude,longitude co-ordinates in NRSectorCarrier
#     
#     Date        : 29 Oct 2022
#####################################################################################
#     Version     : 1.7
#
#     Revision    : CXP 903 6539-1-44
#
#     Author      : Nainesha Chilakala
#
#     JIRA        : NSS-38265
#
#     Description : Updating pLMnIdList attributes in NRCellCU
#
#     Date        : 24 Dec 2021
#####################################################################################
#     Version     : 1.6
#
#     Revision    : CXP 903 6539-1-43
#
#     Author      : Nainesha Chilakala
#
#     JIRA        : NSS-38265
#
#     Description : Updating pLMnIdList attributes in GNBDU
#
#     Date        : 20 Dec 2021
#####################################################################################
#     Version     : 1.5
#
#     Revision    : CXP 903 6539-1-22
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-30445
#
#     Description : Adding nrFrequency ref for NRCellCU
#
#     Date        : 8 May 2020
#
####################################################################################
#####################################################################################
#     Version     : 1.4
#
#     Revision    : CXP 903 6539-1-8
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-27262
#
#     Description : Adding nrFrequency ref for NRCellCU
#
#     Date        : 18 October 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-7
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-25837
#
#     Description : Setting unique NCI attribute values
#
#     Date        : 1st October 2019
#
#####################################################################################
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
#     JIRA         : NSS-23738
#
#     Description  : Create 5G NR cells
#
#     Date         : March 2019
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
local $cellTopologyFile=$currentdir."/../../topology/cellTopology.csv";
local $nrCellDuTopologyFile=$currentdir."/../../topology/cellDuTopology.csv";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $SIMNUM=($LTE);
local @sim1,@sim2,$NUMOFNODES;
#local $NETWORKCELLSIZE=&getENVfilevalue($ENV,"NETWORKCELLSIZE");
#local $nodecountinteger,@primarycells=(),$gridrow,$gridcol;
#local (@FULLNETWORKGRID)=&getAllNodeCells(2,1,$NETWORKCELLSIZE); 
@version1= split /x/, $SIMNAME;
my $nodeVersion=`echo ${version1[0]} | sed 's/[A-Z]//g' | sed 's/[a-z]//g' | sed 's/-//g'`;
print "NodeVersion in numbers is $nodeVersion for comparision to support older version attributes";
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
if ( -e $cellTopologyFile){
    print "...removing old cellDistribution topology\n";
    unlink "$cellTopologyFile";}
################################
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
open(CH, '>', $cellTopologyFile) or die $!;
open(NH, '>', $nrCellDuTopologyFile) or die $!;
#get the new cellpattern
#$min=(($LTE-1)*$DG2NUMOFRBS)+1;
#$max=($LTE*$DG2NUMOFRBS);
#@pat=();
#@pat1=();
#while ($min<=$max){
# $count =`cat $cellDistributionFile | grep -c "NODE=$min;"`;
#push (@pat , "$count");
#$min++;
#}
#foreach my $line (@pat) { my @items = split "\n", $line; push @pat1, @items; } 
#local (@PRIMARY_NODECELLS)=&buildNodeCells(@pat1,$NETWORKCELLSIZE);
while ($NODECOUNT<=$DG2NUMOFRBS){

	$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
        my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
        my $cells = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
        my @cellLdns = split "\n", $cells;
        my $cellCount= @cellLdns;
        my $sectornum=1;
        for my $cellLdn (@cellLdns) {
           my @cell=split ";", $cellLdn;
           my @cellId=split "=",$cell[2];
           my @cid=split "=",$cell[4];
           my @nfFreq=split "=",$cell[3];
           my $gnbBin=&generateBinaryEquivalent($NODENUM,22);
           my $cidBin=&generateBinaryEquivalent($cid[1],14);
           my $nciBin=$gnbBin . $cidBin ;
           my $nci=&convertBinary_to_Decimal($nciBin);
           my $cellname=$LTENAME . "-" . $cellId[1];
           my $plmnIdBin=&generateBinaryEquivalent(12849,24);
           my $ncgiBin=$plmnIdBin . $nciBin;
           my $ncgi=&convertBinary_to_Decimal($ncgiBin);
           print CH "ManagedElement=$LTENAME,GNBCUCPFunction=1,NRCellCU=$cellname\n";
           print NH "ManagedElement=$LTENAME,GNBDUFunction=1,NRCellDU=$cellname\n";

           @MOCmds=qq^          
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1"
    identity "$cellname"
    moType GNBCUCP:NRCellCU
    exception none
    nrOfAttributes 5
    "nRCellCUId" String "$cellname"
    "nCI" Int64 "$nci"
    "cellLocalId" Int32 $cid[1]
    "pLMNIdList" Array Struct $cellCount
^;
 $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
 my $mCCStartValue=128;
 my $mNcStartValue=49;
for( my $count = 1; $count <= $cellCount; $count++){
 @MOCmds=qq^

        nrOfElements 2
        "mCC" String "$mCCStartValue"
        "mNC" String "$mNcStartValue"
^;
   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $mCCStartValue++;
   $mNcStartValue++;
}
 @MOCmds=qq^
)  
^;
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	if ($nodeVersion < 2244) {
	@MOCmds=qq^
 
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
    identity "$cellname"
    moType GNBDU:NRCellDU
    exception none
    nrOfAttributes 28
    "administrativeState" Integer 0
    "cellLocalId" Int32 $cid[1]
    "csiRsPeriodicity" Int32 40
    "endcDlNrLowQualThresh" Int32 -8
    "endcDlNrQualHyst" Int32 8
    "nCGI" Int64 "$ncgi"
    "nCI" Int64 $nci
    "nRCellDUId" String "$cellname"
    "nRPCI" Int32 0
    "nRTAC" Int32 999
    "operationalState" Integer 0
    "pLMNIdList" Array Struct $cellCount
^;
 $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
 my $mCCStartValue=128;
 my $mNcStartValue=49;
for( my $count = 1; $count <= $cellCount; $count++){
 @MOCmds=qq^

        nrOfElements 2
        "mCC" String "$mCCStartValue"
        "mNC" String "$mNcStartValue"
^;
   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $mCCStartValue++;
   $mNcStartValue++;
}
}
else {
@MOCmds=qq^

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
    identity "$cellname"
    moType GNBDU:NRCellDU
    exception none
    nrOfAttributes 27
    "administrativeState" Integer 0
    "cellLocalId" Int32 $cid[1]
    "csiRsPeriodicity" Int32 40
    "endcDlNrLowQualThresh" Int32 -8
    "endcDlNrQualHyst" Int32 8
    "nCI" Int64 $nci
    "nRCellDUId" String "$cellname"
    "nRPCI" Int32 0
    "nRTAC" Int32 999
    "operationalState" Integer 0
    "pLMNIdList" Array Struct $cellCount
^;
 $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
 my $mCCStartValue=128;
 my $mNcStartValue=49;
for( my $count = 1; $count <= $cellCount; $count++){
 @MOCmds=qq^

        nrOfElements 2
        "mCC" String "$mCCStartValue"
        "mNC" String "$mNcStartValue"
^;
   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $mCCStartValue++;
   $mNcStartValue++;
}
}
 @MOCmds=qq^
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
    identity "$sectornum"
    moType GNBDU:NRSectorCarrier
    exception none
    nrOfAttributes 1
    "nRSectorCarrierId" String "$sectornum"
)
 ^;
         $sectornum++;  
           $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

if ($nodeVersion < 2341) {
    @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname"
    identity "1"
    moType GNBCUCP:UeMeasControl
    exception none
    nrOfAttributes 1
    "ueMeasControlId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=$cellname,GNBCUCP:UeMeasControl=1"
    identity "1"
    moType GNBCUCP:ReportConfigA2
    exception none
    nrOfAttributes 1
    "reportConfigA2Id" String "1"
)

^; #end @MO
 	$sectornum++;  
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
# remove mo script
close(CH);
close(NH);
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
print "... ${0} ended running at $date\n";
################################
# END
################################

