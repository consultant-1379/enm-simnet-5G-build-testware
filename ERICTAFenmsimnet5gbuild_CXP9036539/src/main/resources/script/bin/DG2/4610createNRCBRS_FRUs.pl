#!/usr/bin/perl
### VERSION HISTORY
###################################################################
#  Version     : 1.5
#  Revision    : CXP 903 6539-1-60
#  Jira        : NSS-42316
#  Purpose     : Included CBRS 3268 mos
#  Date        : 23 February 2023
#  Who         : zjaisai
###################################################################
## Version     : 1.4
## Revision    : CXP 903 6539-1-55
## Jira        : NSS-42083,NSS-41346
## Purpose     : This will support 3268 CBRS configuration
## Date        : 23 January 2023
## Who         : znamjag
###################################################################
# Version     : 1.3
# Revision    : CXP 903 6539-1-55
# Jira        : NSS-40265,NSS-40235
# Purpose     : This will reduce the format errors and to include the changes required for NRM6.4 4408 CBRS devices
# Date        : 08 July 2022
# Who         : zjaisai
###################################################################
# Version     : 1.2
# Revision    : CXP 903 6539-1-54
# Jira        : NSS-40026
# Purpose     : This will create the 4469 DOT devices 
# Description : This creates the mos related to the 4469 NR 
# Date        : 28 June 2022
# Who         : zjaisai
####################################################################
# Version     : 1.1
# Revision    : CXP 903 6539-1-47
# Jira        : NSS-38914
# Purpose     : For creating cbrs_config.txt file 
# Description : To create cbrs_config.txt that implies sim has CBRS configuration
# Date        : 09 March 2022
# Who         : zjaisai
####################################################################
# Version6    : 1.0
# Revision    : CXP 903 0491-361-1
# Jira        : NSS-37479
# Purpose     : Create CBSD support for NR 4408 
# Description : To create FRU,SectorEquipmentFunction and other mos required for CBRS configuration 
# Date        : October 2021
# Who         : znamjag
####################################################################


####################
# Env
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

local @helpinfo=qq(Usage  : ${0} <sim name> <env file> <sim num>
#Example: $0 LTEMSRBS-V415Bv6x160-RVDG2-FDD-LTE01 CONFIG.env 1);
#start verify params
if(!( @ARGV==3)){
  print "@helpinfo\n";exit(1);}
#end verify params
 local $SIMNAME=$ARGV[0],$ENV=$ARGV[1],$LTE=$ARGV[2];
 local $date=`date`,$LTENAME;
 local $dir=cwd,$currentdir=$dir."/";
 local $cellDistributionFile=$currentdir."/../../customdata/cellDistribution.csv";
 local $scriptpath="$currentdir";
 local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
 local $MOSCRIPT="$scriptpath".${0}.".mo";
 local $MMLSCRIPT="$scriptpath".${0}.".mml";
 local @MOCmds,@MMLCmds,@netsim_output;
 local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
 local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
 local $SIMNUM=($LTE);
 local @sim1,@sim2,$NUMOFNODES;
local $TYPE="GNBDU:NRCellDU";
 local $DOTTYPE=&getENVfilevalue($ENV,"DOTTYPE");
####################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
   unlink "$NETSIMMOSCRIPT";}
#check if SIMNAME is of type DG2
if(&isSimDG2($SIMNAME)=~m/NO/){exit;}
################################
# MAIN
################################
print "DOTTYPE=$DOTTYPE";
if($DOTTYPE eq "YES"){
print "...${0} started running at $date\n";
################################
################################
@sim1= split /x/, $SIMNAME;
@sim2= split /-/, $sim1[1];
$NUMOFNODES="$sim2[0]";
while ($NODECOUNT<=$DG2NUMOFRBS){


    ##########################

  # get node name
  ####################################################
  my $NODENUM=((($SIMNUM - 1) * $NUMOFNODES) + $NODECOUNT);
$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
  my $cells = qx(cat $cellDistributionFile | grep "NODE=$NODENUM;");
   my @cellLdns = split "\n", $cells;
   my $cellSize=@cellLdns;
my $cbrs=&getCbrsType($NODENUM,$cellSize);
  if (($cbrs eq "4408") or ($cbrs eq "4469") or ($cbrs eq "3268")) {
	   my $str = "This ".$SIMNAME." has CBRS device";
           my $filename = $scriptpath."/cbrs_config.txt";
           open(FH, '>', $filename) or die $!;
           print FH $str;
           close(FH);
}
if ($cbrs eq "4408"){
         $sectorEquipmentNum = int($cellSize / 2); # for nrm6.3 and nrm6.4
         #$sectorEquipmentNum = int($cellSize / 4); # for reducing devices with offset 4
         $sectoroffset=6;
         $totalTilt=-900;
	 $totalAntennaGroups=$sectorEquipmentNum;
	$fieldreplaceableUnitNum=$sectorEquipmentNum;
 
    @MOCmds=();

   ################################
   # start FieldReplaceableUnit
   ################################


           ## Creating FRUs #############
	print "Creating CBRS FRUs for $LTENAME\n";

        if ($fieldreplaceableUnitNum < 1 ) {
           $fieldreplaceableUnitNum=1;
        }
       $fieldreplaceableUnitCount=1;
       my $serialString="D8301E";
       my $serialcount=1;
       while(($fieldreplaceableUnitCount<=$fieldreplaceableUnitNum)){
          my $serialNum=$serialString . $LTE . $NODECOUNT . "00" . $serialcount;
         my $latitude=33074892;
	my $longitude=-96832116;
          @MOCmds=qq^

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity $fieldreplaceableUnitCount
    moType ReqFieldReplaceableUnit:FieldReplaceableUnit
    exception none
    nrOfAttributes 6
    "fieldReplaceableUnitId" String $fieldreplaceableUnitCount
    "positionCoordinates" Struct
        nrOfElements 4
        "altitude" Int32 70
        "geoDatum" String "WGS84"
        "latitude" Int32 $latitude
        "longitude" Int32 $longitude
    "productData" Struct
        nrOfElements 5
        "productionDate" String "20190819"
        "productName" String "Radio 4408 B48"
        "productNumber" String "KRC 161 746/1"
        "productRevision" String "R1B"
        "serialNumber" String "$serialNum"
    "administrativeState" Integer 1
    "operationalState" Integer 1
    "availabilityStatus" Array Integer 1
	0
    )
    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "1"
    moType ReqRcvdPowerScanner:RcvdPowerScanner
    exception none
    nrOfAttributes 1
    "rcvdPowerScannerId" String "1"
    )
    CREATE
    (
       parent "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1"
       identity $fieldreplaceableUnitCount
       moType RmeSectorEquipmentFunction:SectorEquipmentFunction
       exception none
       nrOfAttributes 1
       sectorEquipmentFunctionId String $fieldreplaceableUnitCount
    ) 

  CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
       identity $fieldreplaceableUnitCount
       moType ReqAntennaSystem:AntennaUnitGroup
       exception none
       nrOfAttributes 1
       antennaUnitGroupId String $fieldreplaceableUnitCount
       )
   CREATE
          (
          parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
          identity 1
          moType ReqAntennaSystem:AntennaUnit
          exception none
          nrOfAttributes 1
          antennaUnitId String 1
          )
          CREATE
        (
        parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount,ReqAntennaSystem:AntennaUnit=1"
        identity 1
        moType ReqAntennaSystem:AntennaSubunit
        exception none
        nrOfAttributes 2
         antennaSubunitId String 1
         totalTilt Int32 0
        )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
    identity 1
    moType ReqAntennaSystem:RfBranch
    exception none
    nrOfAttributes 1
    rfBranchId String 1
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
    identity 2
    moType ReqAntennaSystem:RfBranch
    exception none
    nrOfAttributes 1
    rfBranchId String 2
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
    identity 3
    moType ReqAntennaSystem:RfBranch
    exception none
    nrOfAttributes 1
    rfBranchId String 3
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
    identity 4
    moType ReqAntennaSystem:RfBranch
    exception none
    nrOfAttributes 1
    rfBranchId String 4
    )
    SET
    (
       mo "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1,RmeSectorEquipmentFunction:SectorEquipmentFunction=$fieldreplaceableUnitCount"
       exception none
       nrOfAttributes 1
       administrativeState Integer 1
       "rfBranchRef" Array Ref 4
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,RfBranch=1"
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,RfBranch=2"
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,RfBranch=3"
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,RfBranch=4"
       )


    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "A"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 3
    "rfPortId" String "A"
    "administrativeState" Integer 1
    "ulFrequencyRanges" String "3550000-3700000 KHz"
    )

    SET
        (
        mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount,ReqAntennaSystem:RfBranch=1"
        exception none
        nrOfAttributes 1
        "rfPortRef" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,RfPort=A"
        )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "B"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 3
    "rfPortId" String "B"
    "administrativeState" Integer 1
    "ulFrequencyRanges" String "3550000-3700000 KHz"
    )

    SET
        (
        mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount,ReqAntennaSystem:RfBranch=2"
        exception none
        nrOfAttributes 1
        "rfPortRef" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,RfPort=B"
        )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "C"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 3
    "rfPortId" String "C"
    "administrativeState" Integer 1
    "ulFrequencyRanges" String "3550000-3700000 KHz"
    )

     SET
        (
        mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount,ReqAntennaSystem:RfBranch=3"
        exception none
        nrOfAttributes 1
        "rfPortRef" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,RfPort=C"
        )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "D"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 3
    "rfPortId" String "D"
    "administrativeState" Integer 1
    "ulFrequencyRanges" String "3550000-3700000 KHz"
    )

    SET
        (
        mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount,ReqAntennaSystem:RfBranch=4"
        exception none
        nrOfAttributes 1
        "rfPortRef" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,RfPort=D"
        )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "RXA_IO"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 1
    "rfPortId" String "RXA_IO"
    )^;# end @MO
          $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
          $fieldreplaceableUnitCount++;
          $serialcount++;
       }
$tempcellnum=1;
$tempsef=0;
  while($tempcellnum<=$cellSize){
      if($tempcellnum % 2 != 0){
	  $tempsef++;
      }
    @MOCmds=qq^
       SET
       (
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,$TYPE=$LTENAME-$tempcellnum"
        exception none
        nrOfAttributes 2
	"administrativeState" Integer 0 
        nRSectorCarrierRef Array Ref 1
             "ManagedElement=$LTENAME,GNBDUFunction=1,NRSectorCarrier=$tempcellnum"
       )^;# end @MO
	
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    $tempcellnum++; }
    @MOCmds=qq^
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=1"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=2"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=3"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=4"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=5"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=6"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=7"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=8"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=9"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=10"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=11"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=12"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
   
 push(@NETSIMMOSCRIPTS,$NETSIMMOSCRIPT);
# build mml script
@MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
}
###########################this part of code is for testing ######################
elsif ($cbrs eq "4469") {
print "Creating CBRS FRUs for $LTENAME\n";
#$NODECOUNT = '0' . $NODECOUNT if $NODECOUNT < 10;
#$LTE = '0' . $LTE if $LTE < 10;
if ($NODECOUNT<10){
$NODENUM1='0'.$NODECOUNT ; }
else {
$NODENUM1=$NODECOUNT;
}
if ($LTE<10){
$LTE1='0'.$LTE;
}
else {
$LTE1=$LTE;
}
	 $sectorEquipmentNum = int($cellSize / 4);
	 $sectoroffset=6;
         $totalTilt=-900;
	 $totalAntennaGroups=$sectorEquipmentNum;
	 $fieldreplaceableUnitNum= int($cellSize * 2);
################################
# start FieldReplaceableUnit
################################
my $serialString="TD3W";
       my $fieldreplaceableUnitCount=1;
       while(($fieldreplaceableUnitCount<=$fieldreplaceableUnitNum)){
       if ($fieldreplaceableUnitCount<10){
	   $serialNum=$serialString.$LTE1.$NODENUM1."0".$fieldreplaceableUnitCount; 
	
	}
	else {
	
	   $serialNum=$serialString.$LTE1.$NODENUM1.$fieldreplaceableUnitCount; }
         my $latitude=33074892;
        my $longitude=-96832116;

          @MOCmds=qq^
  CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity $fieldreplaceableUnitCount
    moType ReqFieldReplaceableUnit:FieldReplaceableUnit
    exception none
    nrOfAttributes 6
    "fieldReplaceableUnitId" String $fieldreplaceableUnitCount
    "positionCoordinates" Struct
        nrOfElements 4
        "altitude" Int32 70
        "geoDatum" String "WGS84"
        "latitude" Int32 $latitude
        "longitude" Int32 $longitude
    "productData" Struct
        nrOfElements 5
        "productionDate" String "20211222"
        "productName" String "RD 4469 B48"
        "productNumber" String "KRY 901 516/2"
        "productRevision" String "R1A"
        "serialNumber" String "$serialNum"
    "administrativeState" Integer 1
    "operationalState" Integer 1
    "availabilityStatus" Array Integer 1
        0
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "1"
    moType ReqTransceiver:Transceiver
    exception none
    nrOfAttributes 1
    "transceiverId" String "1"
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "2"
    moType ReqTransceiver:Transceiver
    exception none
    nrOfAttributes 1
    "transceiverId" String "2"
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity 1
    moType ReqRdiPort:RdiPort
    exception none
    nrOfAttributes 1
    "rdiPortId" String "1"
    )
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "1"
    moType ReqRcvdPowerScanner:RcvdPowerScanner
    exception none
    nrOfAttributes 1
    "rcvdPowerScannerId" String "1"
    )^;# end @MO
	  $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
          $fieldreplaceableUnitCount++;
}
@MOCmds=qq^
CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME"
       identity "1"
       moType RmeSupport:NodeSupport
       exception none
       nrOfAttributes 1
       nodeSupportId String "1"
       )^;# end @MO
          $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

my $fieldreplaceableUnitCount=1;
while(($fieldreplaceableUnitCount<=$sectorEquipmentNum)){
@MOCmds=qq^
CREATE
      (
       parent "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1"
       identity $fieldreplaceableUnitCount
       moType RmeSectorEquipmentFunction:SectorEquipmentFunction
       exception none
       nrOfAttributes 1
       sectorEquipmentFunctionId String $fieldreplaceableUnitCount
       )
CREATE
(
       parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
       identity $fieldreplaceableUnitCount
       moType ReqAntennaSystem:AntennaUnitGroup
       exception none
       nrOfAttributes 1
       antennaUnitGroupId String $fieldreplaceableUnitCount
   )
CREATE
(
parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
     identity 1
     moType ReqAntennaSystem:MulticastAntennaBranch
     exception none
     nrOfAttributes 1
     "multicastAntennaBranchId" String 1
)
CREATE
(
parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
     identity 2
     moType ReqAntennaSystem:MulticastAntennaBranch
     exception none
     nrOfAttributes 1
     "multicastAntennaBranchId" String 2
)
CREATE
(
parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
     identity 3
     moType ReqAntennaSystem:MulticastAntennaBranch
     exception none
     nrOfAttributes 1
     "multicastAntennaBranchId" String 3
)
CREATE
(
parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=$fieldreplaceableUnitCount"
     identity 4
     moType ReqAntennaSystem:MulticastAntennaBranch
     exception none
     nrOfAttributes 1
     "multicastAntennaBranchId" String 4
)
SET
(
mo "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1,RmeSectorEquipmentFunction:SectorEquipmentFunction=$fieldreplaceableUnitCount"
       exception none
       nrOfAttributes 1
       administrativeState Integer 1
       "rfBranchRef" Array Ref 4
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,MulticastAntennaBranch=1"
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,MulticastAntennaBranch=2"
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,MulticastAntennaBranch=3"
           "ManagedElement=$LTENAME,Equipment=1,AntennaUnitGroup=$fieldreplaceableUnitCount,MulticastAntennaBranch=4"
)^;# end @MO
          $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
          $fieldreplaceableUnitCount++;
}
@MOCmds=qq^
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=1"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=2"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=3"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=4"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=1"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=5"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=6"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=7"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=8"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=2"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=9"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=10"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=11"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)
SET
(
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=12"
        exception none
        nrOfAttributes 8
        "administrativeState" Integer 1
        "operationalState" Integer 1
        "cbrsEnabled" Boolean true
        "cbrsTxExpireTime" String ""
        "configuredMaxTxPower" Int32 10000
        "noOfTxAntennas" Int32 4
        "noOfRxAntennas" Int32 4
        sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=3"
)^;# end @MO
          $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
my $fieldreplaceableUnitCount=1;
my $tempcellnum=1;
while($tempcellnum<=$cellSize){
@MOCmds=qq^
SET
       (
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRCellDU=$LTENAME-$tempcellnum"
        exception none
        nrOfAttributes 2
        "administrativeState" Integer 0
        nRSectorCarrierRef Array Ref 1
             "ManagedElement=$LTENAME,GNBDUFunction=1,NRSectorCarrier=$tempcellnum"
       )^;# end @MO
          $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$tempcellnum++;
}
@MOCmds=qq^
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=1,ReqAntennaSystem:MulticastAntennaBranch=1"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=1,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=2,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=3,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=4,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=5,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=6,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=7,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=8,Transceiver=1"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=1,ReqAntennaSystem:MulticastAntennaBranch=2"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=1,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=2,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=3,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=4,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=5,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=6,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=7,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=8,Transceiver=2"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=1,ReqAntennaSystem:MulticastAntennaBranch=3"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=1,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=2,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=3,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=4,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=5,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=6,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=7,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=8,Transceiver=1"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=1,ReqAntennaSystem:MulticastAntennaBranch=4"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=1,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=2,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=3,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=4,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=5,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=6,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=7,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=8,Transceiver=2"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=2,ReqAntennaSystem:MulticastAntennaBranch=1"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=9,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=10,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=11,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=12,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=13,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=14,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=15,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=16,Transceiver=1"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=2,ReqAntennaSystem:MulticastAntennaBranch=2"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=9,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=10,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=11,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=12,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=13,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=14,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=15,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=16,Transceiver=2"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=2,ReqAntennaSystem:MulticastAntennaBranch=3"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=9,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=10,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=11,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=12,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=13,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=14,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=15,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=16,Transceiver=1"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=2,ReqAntennaSystem:MulticastAntennaBranch=4"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=9,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=10,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=11,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=12,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=13,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=14,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=15,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=16,Transceiver=2"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=3,ReqAntennaSystem:MulticastAntennaBranch=1"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=17,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=18,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=19,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=20,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=21,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=22,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=23,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=24,Transceiver=1"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=3,ReqAntennaSystem:MulticastAntennaBranch=2"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=17,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=18,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=19,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=20,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=21,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=22,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=23,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=24,Transceiver=2"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=3,ReqAntennaSystem:MulticastAntennaBranch=3"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=17,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=18,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=19,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=20,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=21,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=22,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=23,Transceiver=1"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=24,Transceiver=1"
    )
SET
    (
    mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqAntennaSystem:AntennaUnitGroup=3,ReqAntennaSystem:MulticastAntennaBranch=4"
    exception none
    nrOfAttributes 1
     "transceiverRef" Array  Ref 8
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=17,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=18,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=19,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=20,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=21,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=22,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=23,Transceiver=2"
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=24,Transceiver=2"
    )
^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
if ($NODECOUNT<10){
$NODENUM2='0'.$NODECOUNT ; }
else {
$NODENUM2=$NODECOUNT;
}
if ($LTE<10){
$LTE2='0'.$LTE;
}
else {
$LTE2=$LTE;
}
#########################Start creating IRU#######################
my $serialString2="TD3F";
       my $fieldreplaceableUnitCount2=1;
           $serialNum2=$serialString2 . $LTE2 .$NODENUM2 ."0". $fieldreplaceableUnitCount2; 
         my $latitude=33074892;
        my $longitude=-96832116;
	my $fruId="IRU"."-"."1";         
 @MOCmds=qq^
CREATE
(
parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity $fruId
    moType ReqFieldReplaceableUnit:FieldReplaceableUnit
    exception none
    nrOfAttributes 5
    "fieldReplaceableUnitId" String $fruId
    "administrativeState" Integer 1
    "operationalState" Integer 1
    "availabilityStatus" Array Integer 1
        0
    "productData" Struct
        nrOfElements 5
        "productionDate" String "20210617"
        "productName" String "IRU 1648"
        "productNumber" String "KRC 161 842/3"
        "productRevision" String "R1D"
        "serialNumber" String "$serialNum2"
    )
^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
my $tempcellnum=1;
while($tempcellnum<=$fieldreplaceableUnitNum){
@MOCmds=qq^
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fruId"
    identity "$tempcellnum"
    moType ReqRdiPort:RdiPort
    exception none
    nrOfAttributes 1
    "rdiPortId" String "$tempcellnum"
    )
SET
   (
     mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$tempcellnum,ReqRdiPort:RdiPort=1"
    exception none
     nrOfAttributes 1
     "remoteRdiPortRef"  Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fruId,RdiPort=$tempcellnum"
   )^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$tempcellnum++;
}
 push(@NETSIMMOSCRIPTS,$NETSIMMOSCRIPT);
 # build mml script
 @MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
}
elsif ( $cbrs eq "3268" ){
    print "3268 CBRS case";
           $fieldreplaceableUnitNum=1;
        
       $fieldreplaceableUnitCount=1;
	$maxAllowedEirpPsd=-1;
	$maxtranspower=500;
       my $serialString="E23E";
       my $serialcount=1;
       while(($fieldreplaceableUnitCount<=$fieldreplaceableUnitNum)){
          my $serialNum=$serialString . $LTE . $NODECOUNT . "00" . $serialcount;
          #my ($latitude,$longitude)=&getPositionCoordinates($LTE,$NODECOUNT,$fieldreplaceableUnitCount,$fieldreplaceableUnitNum,$DG2NUMOFRBS);
          my $latitude=33074893;
          my $longitude=-96832117;
          @MOCmds=qq^
    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity $fieldreplaceableUnitCount
    moType ReqFieldReplaceableUnit:FieldReplaceableUnit
    exception none
    nrOfAttributes 6
    "fieldReplaceableUnitId" String $fieldreplaceableUnitCount
    "availabilityStatus" Array Integer 1
	0
    "positionCoordinates" Struct
        nrOfElements 4
        "altitude" Int32 70
        "geoDatum" String "WGS84"
        "latitude" Int32 $latitude
        "longitude" Int32 $longitude
    "productData" Struct
        nrOfElements 5
        "productionDate" String "20221028"
        "productName" String "AIR 3268 B48"
        "productNumber" String "KRD 901 254/31"
        "productRevision" String "R1B"
        "serialNumber" String "$serialNum"
    "administrativeState" Integer 1
    "operationalState" Integer 1
    )
    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "1"
    moType ReqTransceiver:Transceiver
    exception none
    nrOfAttributes 1
    "transceiverId" String "1"
    )
    CREATE
    (
       parent "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1"
       identity $fieldreplaceableUnitCount
       moType RmeSectorEquipmentFunction:SectorEquipmentFunction
       exception none
       nrOfAttributes 1
       sectorEquipmentFunctionId String $fieldreplaceableUnitCount
    ) 
   SET
   (
	mo "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1,RmeSectorEquipmentFunction:SectorEquipmentFunction=$fieldreplaceableUnitCount"
       exception none
       nrOfAttributes 1
       administrativeState Integer 1
       "rfBranchRef" Array Ref 1
                "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,Transceiver=1"
)


CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "A"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "A"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount,ReqSfpModule:SfpModule=A"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "B"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "B"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount,ReqSfpModule:SfpModule=B"
    identity "2"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "A"
    moType ReqRiPort:RiPort
    exception none
    nrOfAttributes 5
    "administrativeState" Integer 1
    "channelRef" Array Ref 1
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,SfpModule=A,SfpChannel=1"
    "riPortId" String "A"
    "sfpModuleRef" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,SfpModule=A"
    "transmissionStandard" Integer 1
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "B"
    moType ReqRiPort:RiPort
    exception none
    nrOfAttributes 5
    "administrativeState" Integer 1
    "channelRef" Array Ref 1
        "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,SfpModule=B,SfpChannel=2"
    "riPortId" String "B"
    "sfpModuleRef" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$fieldreplaceableUnitCount,SfpModule=B"
    "transmissionStandard" Integer 1
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$count"
    identity "1"
    moType ReqRiPort:RiPort
    exception none
    nrOfAttributes 3
    "administrativeState" Integer 1
    "riPortId" String "1"
    "transmissionStandard" Integer 1
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$count"
    identity "2"
    moType ReqRiPort:RiPort
    exception none
    nrOfAttributes 3
    "administrativeState" Integer 1
    "riPortId" String "2"
    "transmissionStandard" Integer 1
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity "3
    moType ReqRiLink:RiLink
    exception none
    nrOfAttributes 3
    "riPortRef1" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$count,RiPort=1" 
    "riLinkId" String "3"
    "riPortRef2" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$count,RiPort=A"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity "4"
    moType ReqRiLink:RiLink
    exception none
    nrOfAttributes 3
    "riPortRef1" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$count,RiPort=2"
    "riLinkId" String "4"
    "riPortRef2" Ref "ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=$count,RiPort=B"
)
CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldreplaceableUnitCount"
    identity "1"
    moType ReqRcvdPowerScanner:RcvdPowerScanner
    exception none
    nrOfAttributes 1
    "rcvdPowerScannerId" String "1"
    )    ^;# end @MO
          $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
          $fieldreplaceableUnitCount++;
          $serialcount++;
       }
  $tempcellnum=1;
  $tempsef=1;
  while($tempcellnum<=$CELLNUM){
      
    @MOCmds=qq^
       SET
       (
        mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,$TYPE=$LTENAME-$tempcellnum"
        exception none
        nrOfAttributes 2
	"administrativeState" Integer 1 
        nRSectorCarrierRef Array Ref 1
             "ManagedElement=$LTENAME,GNBDUFunction=1,NRSectorCarrier=$tempcellnum"
       )
	
	SET
	(
        	mo "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:NRSectorCarrier=$tempcellnum"
		exception none
		nrOfAttributes 8
		"administrativeState" Integer 1
		"operationalState" Integer 1
		"cbrsEnabled" Boolean true
		"cbrsTxExpireTime" String ""
		"configuredMaxTxPower" Int32 $maxtranspower
		"maximumTransmissionPower" Int32 $maxtranspower
		"maxAllowedEirpPsd" Int32 $maxAllowedEirpPsd
		"noOfTxAntennas" Int32 0
		"noOfRxAntennas" Int32 0
		sectorEquipmentFunctionRef Ref "ManagedElement=$LTENAME,NodeSupport=1,SectorEquipmentFunction=$$fieldreplaceableUnitCount"
	)^;# end @MO
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    } # end while loop
	push(@NETSIMMOSCRIPTS,$NETSIMMOSCRIPT);
 	# build mml script
 	@MMLCmds=(".open ".$SIMNAME,
    	      	  ".select ".$LTENAME,
        	  ".start ",
        	  "useattributecharacteristics:switch=\"off\"; ",
        	  "kertayle:file=\"$NETSIMMOSCRIPT\";"
  	);# end @MMLCmds
	$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
}
 

  
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
}
else{
exit; }
################################
# END
################################
