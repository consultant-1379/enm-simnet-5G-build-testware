#!/usr/bin/perl
### VERSION HISTORY
#####################################################################################
#     Version      : 1.2
#
#     Revision    : CXP 903 6539-1-42
#
#     Author       : Nainesha Chilakala
#
#     JIRA         : NSS-38085
#
#     Description  : Support for multiple celltypes
#
#     Date         : Dec 2021
#
####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Create Antenna Group MOs
#
#     Date         : March 2019
#
####################################################################################

####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../../lib/cellconfig";
use Cwd;
use LTE_CellConfiguration;
use LTE_General;
use POSIX;
use LTE_OSS14;
use LTE_OSS15;
####################
# Vars
####################
local $SIMNAME=$ARGV[0],$ENV=$ARGV[1],$LTE=$ARGV[2];
#----------------------------------------------------------------
# start verify params and sim node type
local @helpinfo=qq(Usage  : ${0} <sim name> <env file> <sim num>
Example: $0 LTE15B-v6x160-RVDG2-FDD-LTE01 CONFIG.env 1);
if (!( @ARGV==3)){
   print "@helpinfo\n";exit(1);}
# check if SIMNAME is of type PICO or DG2
if(&isSimDG2($SIMNAME)=~m/NO/){exit;}
# end verify params and sim node type
#----------------------------------------------------------------
sub getCellType{
    my ($simNum,$nodeNum)=@_;
    my $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
    my $cellDistributionFile=$currentdir."../../customdata/cellDistribution.csv";
    my $nodeNumInNetwork=((($simNum - 1)*$DG2NUMOFRBS) + $nodeNum);
    my $cellType = `cat $cellDistributionFile | grep -w "NODE=$nodeNumInNetwork" | head -1 | cut -d ';' -f2 | cut -d '=' -f2`;
    return($cellType);
}
#----------------------------------------------------------------
local $cellDistributionFile=$currentdir."../../customdata/cellDistribution.csv";
local $date=`date`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $whilecounter;
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $NETWORKCELLSIZE=&getENVfilevalue($ENV,"NETWORKCELLSIZE");
local $STATICCELLNUM=&getCellType($LTE,$NODECOUNT),$CELLCOUNT;
local $CELLNUM;
local $NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $nodecountinteger,$tempcellnum,$tempAntennaUnit,$maxAntennaUnit,$tempRetSubUnit,$maxRetSubUnit;
local $bearing;
local $NODESIM,$nodecountinteger;
# get cell configuration ex: 6,3,3,1 etc.....
local $CELLPATTERN=&getENVfilevalue($ENV,"CELLPATTERN");
local @CELLPATTERN=split(/\,/,$CELLPATTERN);
local (@PRIMARY_NODECELLS)=&buildNodeCells(@CELLPATTERN,$NETWORKCELLSIZE);


local $percentmultisector=&getENVfilevalue($ENV,"PERCENTAGEOFMULTISECTORCELLS");
local $maxmultisectors=&getENVfilevalue($ENV,"MAXMULTISECTORCELLS");
local $numberofmultisectornodes=ceil(($NETWORKCELLSIZE/100)*$percentmultisector);
# when supported node interval for multisector cells
local $multisectornodeinterval=ceil(($NETWORKCELLSIZE/$numberofmultisectornodes)/$STATICCELLNUM);
local $requiredsectorcarriers;
local $MAXALLOWEDSECTORMOS=48;
local $maxtranspower=120;
####################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
    unlink "$NETSIMMOSCRIPT";}
################################
# MAIN
################################
print "...${0} started running at $date\n";
################################
# MAIN
################################
################################
# Make MO & MML Scripts
################################

while ($NODECOUNT<=$NUMOFRBS){

    ##########################
    # MIM version support
    ##########################
    local $MIMVERSION=&queryMIM($SIMNAME,$NODECOUNT);
    local $post15BV11MIM=&isgreaterthanMIM($MIMVERSION,"15B-V13");
    local $post16AMIM=&isgreaterthanMIM($MIMVERSION,"16A-V1");
    local $intDataType=($post16AMIM eq "yes") ? "Int64" : "Int32";
    local $post17AV10MIM=&isgreaterthanMIM($MIMVERSION,"17A-V10");
    local $ANTENNAGAINMO=($post17AV10MIM eq "yes") ? "iuantAntennaOperatingGain" : "iuantAntennaGain";

  # get node name
  $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);

  # get node primary cells
  $nodecountinteger=&getLTESimIntegerNodeNum($LTE,$NODECOUNT,$NUMOFRBS);

  # set cell configuration ex: 6,3,3,1 etc.....
  @primarycells=@{$PRIMARY_NODECELLS[$nodecountinteger]};
#  $CELLNUM=@primarycells;

   $CELLNUM=&getCellType($LTE,$NODECOUNT);
  # check cell type
  # CXP 903 0491-135-1
  if(($NODECOUNT<=$NUMOFRBS) && (!(&isSimflaggedasTDDinCONFIG($ENV,"TDDSIMS",$LTE)))){
      $TYPE="Lrat:EUtranCellFDD";
  }# end if
  else{
     $TYPE="Lrat:EUtranCellTDD";
  }# end else

  # check no of RetSubUnit's required
  # CXP 903 0491-288-1
  if (&isNodeNumLocInReqPer($nodecountinteger) eq "true") {
	$maxAntennaUnit=2;
	$maxRetSubUnit=2;
  }
  else {
  	$maxAntennaUnit=1;
	$maxRetSubUnit=1;
  }

   ################################
   # start SectorCarrier
   ################################
   $tempcellnum=1;
   # enable cell multi sectors
   if ($nodecountinteger % $multisectornodeinterval==0){# start if multi sectors
      $requiredsectorcarriers=($CELLNUM*$maxmultisectors);
      if($requiredsectorcarriers>$MAXALLOWEDSECTORMOS){$requiredsectorcarriers=$MAXALLOWEDSECTORMOS;}
   }# end if
   # enable cell single sector
   else{$requiredsectorcarriers=$CELLNUM;}
   
   while($tempcellnum<=$requiredsectorcarriers){
    @MOCmds=qq^ CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME,Lrat:ENodeBFunction=1"
       identity $tempcellnum
       moType Lrat:SectorCarrier
       exception none
       nrOfAttributes 11
        sectorCarrierId  String $tempcellnum
        maximumTransmissionPower Int32 $maxtranspower
       )
     ^;# end @MO
#    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $tempcellnum++;
   }# end while
   ################################
   # end SectorCarrier
   ################################
   ################################
   # start SectorEquipmentFunction
   ################################
   if ($post15BV11MIM=~m/no/) {
       $tempcellnum=1;
       while($tempcellnum<=$CELLNUM){
        @MOCmds=qq^ CREATE
        (
        parent "ComTop:ManagedElement=$LTENAME"
        identity $tempcellnum
        moType RmeSectorEquipmentFunction:SectorEquipmentFunction
        exception none
        nrOfAttributes 1
        sectorEquipmentFunctionId String $tempcellnum
        )
        ^;# end @MO
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        $tempcellnum++;
       }# end while
   }# end if
   ################################
   # end SectorEquipmentFunction
   ################################
   ################################
   # start NodeSupport 
   ################################
    @MOCmds=qq^ CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME"
       identity "1"
       moType RmeSupport:NodeSupport
       exception none
       nrOfAttributes 1
       nodeSupportId String "1"
       )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   ################################
   # end NodeSupport 
   ################################
   ############################################
   # start NodeSupport SectorEquipmentFunction
   ############################################
   $tempcellnum=1;
   while($tempcellnum<=$CELLNUM){
    @MOCmds=qq^ CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1"
       identity $tempcellnum
       moType RmeSectorEquipmentFunction:SectorEquipmentFunction
       exception none
       nrOfAttributes 1
       sectorEquipmentFunctionId String $tempcellnum
       )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $tempcellnum++;
   }# end while
   ############################################
   # end NodeSupport SectorEquipmentFunction
   ############################################
   ################################
   # start AntennaUnitGroup
   ################################
   $tempcellnum=1;
   while($tempcellnum<=$CELLNUM){ 
    @MOCmds=qq^ CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
       identity $tempcellnum 
       moType ReqAntennaSystem:AntennaUnitGroup
       exception none
       nrOfAttributes 1
       antennaUnitGroupId String $tempcellnum 
       )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $tempcellnum++;
   }# end while
   ################################
   # end AntennaUnitGroup
   ################################
   ################################
   # start RfBranch
   ################################
   $tempcellnum=1;
   while($tempcellnum<=$CELLNUM){ 
    @MOCmds=qq^ CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum"
    identity 1 
    moType ReqAntennaSystem:RfBranch
    exception none
    nrOfAttributes 1
    rfBranchId String 1 
    )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    @MOCmds=qq^ CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum"
    identity 2 
    moType ReqAntennaSystem:RfBranch
    exception none
    nrOfAttributes 1
    rfBranchId String 2     
    )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $tempcellnum++;
   }# end while
   ################################
   # end RfBranch
   ################################
   ################################
   # start AntennaNearUnit
   ################################
   $tempcellnum=1;
   while($tempcellnum<=$CELLNUM){ 
    @MOCmds=qq^ CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum"
    identity 1 
    moType ReqAntennaSystem:AntennaNearUnit
    exception none
    )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $tempcellnum++;
   }# end while
   ################################
   # end AntennaNearUnit
   ################################
  ################################
  # start TmaSubUnit
  ################################
  $tempcellnum=1;
  while($tempcellnum<=$CELLNUM){
    $bearing=($tempcellnum-1)*int(3600/$CELLNUM);
    @MOCmds=qq^ CREATE
    (
      parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum,ReqAntennaSystem:AntennaNearUnit=1"
      identity 1
      moType ReqAntennaSystem:TmaSubUnit
      exception none
      nrOfAttributes 3
      tmaSubUnitId String 1 
      iuantAntennaBearing  Int32 $bearing 
      iuantAntennaOperatingGain Array Int32 1
      185
    )
    ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   $tempcellnum++;
 }# end while
 ################################
 # end TmaSubUnit
 ################################
 ################################
 # start RetSubUnit
 ################################
 $tempcellnum=1;
 if ($ANTENNAGAINMO eq 'iuantAntennaGain'){
  while($tempcellnum<=$CELLNUM){
  $tempRetSubUnit=1;
     $bearing=($tempcellnum-1)*int(3600/$CELLNUM);
	 while ($tempRetSubUnit <= $maxRetSubUnit) {
		 @MOCmds=qq^ CREATE
		 (
		   parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum,ReqAntennaSystem:AntennaNearUnit=1"
		   identity $tempRetSubUnit
		   moType ReqAntennaSystem:RetSubUnit
		   exception none
		   nrOfAttributes 3
			retSubUnitId String $tempRetSubUnit
			iuantAntennaBearing Int32 $bearing
			$ANTENNAGAINMO $intDataType 185
		 )
		 ^;# end @MO
		 $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
		 $tempRetSubUnit++;
	 }
    $tempcellnum++;
  }# end while
 }# end if

 else{
  while($tempcellnum<=$CELLNUM){
  $tempRetSubUnit=1;
  $bearing=($tempcellnum-1)*int(3600/$CELLNUM);
	while ($tempRetSubUnit <= $maxRetSubUnit) {
		 @MOCmds=qq^ CREATE
		 (
		   parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum,ReqAntennaSystem:AntennaNearUnit=1"
		   identity $tempRetSubUnit
		   moType ReqAntennaSystem:RetSubUnit
		   exception none
		   nrOfAttributes 3
			retSubUnitId String $tempRetSubUnit
			iuantAntennaBearing Int32 $bearing
			$ANTENNAGAINMO Array Int32 4
			185
			0
			0
			0
		 )
		 ^;# end @MO
		 $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
		 $tempRetSubUnit++;
	 }
    $tempcellnum++;
  }# end while
 }# end if

 ################################
 # end RetSubUnit
 ################################
 ################################
 # start AntennaUnit
 ################################
 $tempcellnum=1;
 while($tempcellnum<=$CELLNUM){
 $tempAntennaUnit=1;
 	while ($tempAntennaUnit <= $maxAntennaUnit){
	  @MOCmds=qq^ CREATE
	  (
	  parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum"
	  identity $tempAntennaUnit
	  moType ReqAntennaSystem:AntennaUnit
	  exception none
	  nrOfAttributes 1
	  antennaUnitId String $tempAntennaUnit
	  )
	  ^;# end @MO
	  $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	  $tempAntennaUnit++;
	  }
 $tempcellnum++;
 }# end while
 ################################
 # end AntennaUnit
 ################################
 ################################
 # start AntennaSubUnit
 ################################
 $tempcellnum=1;
 while($tempcellnum<=$CELLNUM){
 $tempAntennaUnit=1;
	while ($tempAntennaUnit <= $maxAntennaUnit){
	@MOCmds=qq^ CREATE
	(
	parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum,ReqAntennaSystem:AntennaUnit=$tempAntennaUnit"
	identity 1
	moType ReqAntennaSystem:AntennaSubunit
	exception none
	nrOfAttributes 1
	 antennaSubunitId String 1
	 totalTilt Int32 -900
	)
	^;# end @MO
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	$tempAntennaUnit++;
	}
   $tempcellnum++;
 }# end while
 ################################
 # end AntennaSubUnit
 ################################
 ################################
 # start AuPort
 ################################
 $tempcellnum=1;
 while($tempcellnum<=$CELLNUM){
 $tempAntennaUnit=1;
	while ($tempAntennaUnit <= $maxAntennaUnit){
		@MOCmds=qq^ CREATE
		(
		parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum,ReqAntennaSystem:AntennaUnit=$tempAntennaUnit,ReqAntennaSystem:AntennaSubunit=1"
		identity 1
		moType ReqAntennaSystem:AuPort
		exception none
		nrOfAttributes 3
		auPortId String 1
		)
		^;# end @MO
		$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

		@MOCmds=qq^ CREATE
		(
		parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$tempcellnum,ReqAntennaSystem:AntennaUnit=$tempAntennaUnit,ReqAntennaSystem:AntennaSubunit=1"
		identity 2 
		moType ReqAntennaSystem:AuPort
		exception none
		nrOfAttributes 3
		auPortId String 2 
		)
		^;# end @MO
		$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
		$tempAntennaUnit++;
		}
   $tempcellnum++;
 }# end while tempcellnum
 ################################
 # end AuPort
 ################################

 push(@NETSIMMOSCRIPTS,$NETSIMMOSCRIPT);

 # build mml script
  @MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds
 
  $NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

  
  $NODECOUNT++;
}# end outer NODECOUNT while

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

