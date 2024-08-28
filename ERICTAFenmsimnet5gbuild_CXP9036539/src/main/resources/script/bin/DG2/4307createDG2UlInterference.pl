#!/usr/bin/perl

#####################################################################################
#     Version      : 1.3
#
#     Revision     : CXP 903 6539-1-27
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NSS-33395
#
#     Description  : Creating FRU and ORadio MOs
#
#     Date         : 30th Nov 2020
#
####################################################################################
#####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-25
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NSS-31981, NSS-31649, NSS-31957
#
#     Description  : Creating FRU and ORadio MOs
#
#     Date         : Sept 2020
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
#     Description  : Create DUl Interference
#
#     Date         : March 2019
#
####################################################################################
###################
# Env
###################
use FindBin qw($Bin);
use lib "$Bin/../../lib/cellconfig";
use Cwd;
use LTE_CellConfiguration;
use LTE_General;
use LTE_Relations;
use LTE_OSS13;
use LTE_OSS14;
use LTE_OSS15;
####################
# Vars
####################
local $SIMNAME=$ARGV[0],$ENV=$ARGV[1],$LTE=$ARGV[2];
#----------------------------------------------------------------
# start verify params and sim node type
local @helpinfo=qq(Usage  : ${0} <sim name> <env file> <sim num>
Example: $0 LTEMSRBS-V415Bv6x160-RVDG2-FDD-LTE01 CONFIG.env 1);
if (!( @ARGV==3)){
   print "@helpinfo\n";exit(1);}

# check if SIMNAME is of type PICO
if(&isSimDG2($SIMNAME)=~m/NO/){exit;}
# end verify params and sim node type
#----------------------------------------------------------------
local $date=`date`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS",$SIMNAME);
local $TOTALNETWORKNODES=$LTE*$NUMOFRBS;
local $NODEOFFSET=$NUMOFRBS-1;
local $ENBID=$TOTALNETWORKNODES-$NODEOFFSET;
local $MIMVERSION=&queryMIM($SIMNAME,$NODECOUNT);

####################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
    unlink "$NETSIMMOSCRIPT";}
if (($MIMVERSION eq "16A-V18") || ($MIMVERSION eq "16B-V13")) {
   print "The Feature is not supported in the mim $MIMVERSION\n";
   exit;}
################################
# MAIN
################################
print "...${0} started running at $date\n";
################################
# Make MO & MML Scripts
################################

while ($NODECOUNT<=$DG2NUMOFRBS){# start outer while

# get node name
  $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT,$SIMNAME);

	@MOCmds=();
	@MOCmds=qq^

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1"
    identity "1"
    moType RmeUlSpectrumAnalyzer:UlSpectrumAnalyzer
    exception none
    nrOfAttributes 1
    "ulSpectrumAnalyzerId" String "1"
    )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity "1"
    moType ReqFieldReplaceableUnit:FieldReplaceableUnit
    exception none
    nrOfAttributes 1
    "fieldReplaceableUnitId" String "1"
    )
CREATE
(    
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
) 
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "1"
    moType ReqEFuse:EFuse
    exception none
    nrOfAttributes 1
    "eFuseId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1,ReqEFuse:EFuse=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "1"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1,ReqSfpModule:SfpModule=1"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "2"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1,ReqSfpModule:SfpModule=2"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
         identity "AAS"
         moType ReqFieldReplaceableUnit:FieldReplaceableUnit
         exception none
         nrOfAttributes 3
         "fieldReplaceableUnitId" String "AAS"
         "operationalState" Integer 1
         "administrativeState" Integer 1
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS"
         identity "1"
         moType ReqTransceiver:Transceiver
         exception none
         nrOfAttributes 1
         "transceiverId" String "1"
     )
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS"
    identity "1"
    moType ReqEFuse:EFuse
    exception none
    nrOfAttributes 1
    "eFuseId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS,ReqEFuse:EFuse=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS"
    identity "1"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS,ReqSfpModule:SfpModule=1"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS"
    identity "2"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=AAS,ReqSfpModule:SfpModule=2"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "A"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 1
    "rfPortId" String "A"
    )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "B"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 1
    "rfPortId" String "B"
    )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "RXA_IO"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 1
    "rfPortId" String "RXA_IO"
    )
        ^;# end @MO
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    if($MIMVERSION ge "20-Q3-V3")
    {
        @MOCmds=qq^    
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
         identity "ORanRU1"
         moType ReqFieldReplaceableUnit:FieldReplaceableUnit
         exception none
         nrOfAttributes 4
         "fieldReplaceableUnitId" String "ORanRU1"
         "operationalState" Integer 1
         "administrativeState" Integer 1
     	"productData" Struct
             nrOfElements 5
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "serialNumber" String "ERISIM012345"
     )
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1"
    identity "1"
    moType ReqEFuse:EFuse
    exception none
    nrOfAttributes 1
    "eFuseId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqEFuse:EFuse=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1"
    identity "1"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqSfpModule:SfpModule=1"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1"
    identity "2"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqSfpModule:SfpModule=2"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
) 
    CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1"
         identity "1"
         moType ReqORadio:ORadio
         exception none
         nrOfAttributes 17
         "oRadioId" String "1"
         "operationalState" Integer 1
         "serialNumber" String "ERISIM012345"
         "availabilityStatus" Array Integer 0
         "defaultUserName" String "null"
         "defaultUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "sudoUserName" String "null"
         "sudoUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "commandResult" String "null"
         "notificationResult" String "null"
         "nmsUserName" String "null"
         "nmsUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "oamConnectionResult" String "close OK"
         "serialNumberValidation" Boolean true
         "nmsAddress" String "null"
         "subnet" String "null"
         "sshKeyValidation" Boolean true
     )
     DELETE
     (
       mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqORadio:ORadio=1,ReqORadioSwSlot:ORadioSwSlot=1"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqORadio:ORadio=1"
         identity "1"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "1"
         "name" String "default_slot"
         "buildName" String "default_slot_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 1
         "buildVersion" String "1.0"
         "buildId" String "1"
         "access" Integer 1
         "active" Boolean true
         "running" Boolean true
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqORadio:ORadio=1"
         identity "2"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "2"
         "name" String "slot1"
         "buildName" String "slot1_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 1
         "buildVersion" String "1.0"
         "buildId" String "2"
         "access" Integer 2
         "active" Boolean false
         "running" Boolean false
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU1,ReqORadio:ORadio=1"
         identity "3"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "3"
         "name" String "slot2"
         "buildName" String "slot2_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 2
         "buildVersion" String "1.0"
         "buildId" String "3"
         "access" Integer 2
         "active" Boolean false
         "running" Boolean false
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
         identity "ORanRU2"
         moType ReqFieldReplaceableUnit:FieldReplaceableUnit
         exception none
         nrOfAttributes 4
         "fieldReplaceableUnitId" String "ORanRU2"
         "operationalState" Integer 1
         "administrativeState" Integer 1
     	"productData" Struct
             nrOfElements 5
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "serialNumber" String "ERISIM012345"
     )
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2"
    identity "1"
    moType ReqEFuse:EFuse
    exception none
    nrOfAttributes 1
    "eFuseId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqEFuse:EFuse=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2"
    identity "1"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqSfpModule:SfpModule=1"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2"
    identity "2"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqSfpModule:SfpModule=2"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2"
         identity "2"
         moType ReqORadio:ORadio
         exception none
         nrOfAttributes 17
         "oRadioId" String "2"
         "operationalState" Integer 1
         "serialNumber" String "ERISIM012345"
         "availabilityStatus" Array Integer 0
         "defaultUserName" String "null"
         "defaultUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "sudoUserName" String "null"
         "sudoUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "commandResult" String "null"
         "notificationResult" String "null"
         "nmsUserName" String "null"
         "nmsUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "oamConnectionResult" String "close OK"
         "serialNumberValidation" Boolean true
         "nmsAddress" String "null"
         "subnet" String "null"
         "sshKeyValidation" Boolean true
     )
     DELETE
     (
       mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqORadio:ORadio=2,ReqORadioSwSlot:ORadioSwSlot=1"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqORadio:ORadio=2"
         identity "1"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "1"
         "name" String "default_slot"
         "buildName" String "default_slot_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 1
         "buildVersion" String "1.0"
         "buildId" String "1"
         "access" Integer 1
         "active" Boolean true
         "running" Boolean true
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqORadio:ORadio=2"
         identity "2"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "2"
         "name" String "slot1"
         "buildName" String "slot1_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 1
         "buildVersion" String "1.0"
         "buildId" String "2"
         "access" Integer 2
         "active" Boolean false
         "running" Boolean false
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU2,ReqORadio:ORadio=2"
         identity "3"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "3"
         "name" String "slot2"
         "buildName" String "slot2_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 2
         "buildVersion" String "1.0"
         "buildId" String "3"
         "access" Integer 2
         "active" Boolean false
         "running" Boolean false
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
         identity "ORanRU3"
         moType ReqFieldReplaceableUnit:FieldReplaceableUnit
         exception none
         nrOfAttributes 4
         "fieldReplaceableUnitId" String "ORanRU3"
         "operationalState" Integer 1
         "administrativeState" Integer 1
     	"productData" Struct
             nrOfElements 5
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "serialNumber" String "ERISIM012345"
     )
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3"
    identity "1"
    moType ReqEFuse:EFuse
    exception none
    nrOfAttributes 1
    "eFuseId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqEFuse:EFuse=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3"
    identity "1"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqSfpModule:SfpModule=1"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3"
    identity "2"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqSfpModule:SfpModule=2"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3"
         identity "3"
         moType ReqORadio:ORadio
         exception none
         nrOfAttributes 17
         "oRadioId" String "3"
         "operationalState" Integer 1
         "serialNumber" String "ERISIM012345"
         "availabilityStatus" Array Integer 0
         "defaultUserName" String "null"
         "defaultUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "sudoUserName" String "null"
         "sudoUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "commandResult" String "null"
         "notificationResult" String "null"
         "nmsUserName" String "null"
         "nmsUserPassword" Struct
             nrOfElements 2
             "cleartext" Boolean true
             "password" String ""
     
         "oamConnectionResult" String "close OK"
         "serialNumberValidation" Boolean true
         "nmsAddress" String "null"
         "subnet" String "null"
         "sshKeyValidation" Boolean true
     )
     DELETE
     (
       mo "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqORadio:ORadio=3,ReqORadioSwSlot:ORadioSwSlot=1"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqORadio:ORadio=3"
         identity "1"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "1"
         "name" String "default_slot"
         "buildName" String "default_slot_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 1
         "buildVersion" String "1.0"
         "buildId" String "1"
         "access" Integer 1
         "active" Boolean true
         "running" Boolean true
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqORadio:ORadio=3"
         identity "2"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "2"
         "name" String "slot1"
         "buildName" String "slot1_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 1
         "buildVersion" String "1.0"
         "buildId" String "2"
         "access" Integer 2
         "active" Boolean false
         "running" Boolean false
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=ORanRU3,ReqORadio:ORadio=3"
         identity "3"
         moType ReqORadioSwSlot:ORadioSwSlot
         exception none
         nrOfAttributes 11
         "oRadioSwSlotId" String "3"
         "name" String "slot2"
         "buildName" String "slot2_name"
         "productCode" String "28GLLSDU"
         "vendorCode" String "SS"
         "status" Integer 2
         "buildVersion" String "1.0"
         "buildId" String "3"
         "access" Integer 2
         "active" Boolean false
         "running" Boolean false
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
         identity "4"
         moType RcsHwIM:HwItem
         exception none
         nrOfAttributes 8
         "hwItemId" String "4"
         "equipmentMoRef" Array Ref 1
             ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=ORanRU1
         "vendorName" String "Ericsson"
         "serialNumber" String "ERISIM012345"
         "productData" Struct
             nrOfElements 6
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "description" String ""
             "type" String "FieldReplaceableUnit"
     
         "hwType" String "FieldReplaceableUnit"
         "hwModel" String "OPEN"
         "hwCapability" String "OPEN RADIO"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
         identity "5"
         moType RcsHwIM:HwItem
         exception none
         nrOfAttributes 8
         "hwItemId" String "5"
         "equipmentMoRef" Array Ref 1
     	ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=ORanRU1,SfpModule=1
         "vendorName" String "Ericsson"
         "serialNumber" String "ERISIM012345"
         "productData" Struct
             nrOfElements 6
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "description" String ""
             "type" String "FieldReplaceableUnit"
     
         "hwType" String "FieldReplaceableUnit"
         "hwModel" String "OPEN"
         "hwCapability" String "OPEN RADIO"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
         identity "6"
         moType RcsHwIM:HwItem
         exception none
         nrOfAttributes 8
         "hwItemId" String "6"
         "equipmentMoRef" Array Ref 1
             ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=ORanRU2
         "vendorName" String "Ericsson"
         "serialNumber" String "ERISIM012345"
         "productData" Struct
             nrOfElements 6
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "description" String ""
             "type" String "FieldReplaceableUnit"
     
         "hwType" String "FieldReplaceableUnit"
         "hwModel" String "OPEN"
         "hwCapability" String "OPEN RADIO"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
         identity "7"
         moType RcsHwIM:HwItem
         exception none
         nrOfAttributes 8
         "hwItemId" String "7"
         "equipmentMoRef" Array Ref 1
     	ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=ORanRU2,SfpModule=1
         "vendorName" String "Ericsson"
         "serialNumber" String "ERISIM012345"
         "productData" Struct
             nrOfElements 6
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "description" String ""
             "type" String "FieldReplaceableUnit"
     
         "hwType" String "FieldReplaceableUnit"
         "hwModel" String "OPEN"
         "hwCapability" String "OPEN RADIO"
     
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
         identity "8"
         moType RcsHwIM:HwItem
         exception none
         nrOfAttributes 8
         "hwItemId" String "8"
         "equipmentMoRef" Array Ref 1
             ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=ORanRU3
         "vendorName" String "Ericsson"
         "serialNumber" String "ERISIM012345"
         "productData" Struct
             nrOfElements 6
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "description" String ""
             "type" String "FieldReplaceableUnit"
     
         "hwType" String "FieldReplaceableUnit"
         "hwModel" String "OPEN"
         "hwCapability" String "OPEN RADIO"
     )
     CREATE
     (
         parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
         identity "9"
         moType RcsHwIM:HwItem
         exception none
         nrOfAttributes 8
         "hwItemId" String "9"
         "equipmentMoRef" Array Ref 1
     	ManagedElement=$LTENAME,Equipment=1,FieldReplaceableUnit=ORanRU3,SfpModule=1
         "vendorName" String "Ericsson"
         "serialNumber" String "ERISIM012345"
         "productData" Struct
             nrOfElements 6
             "productName" String "OPEN RADIO"
             "productNumber" String "FJ 28GLLSDU"
             "productRevision" String "1100"
             "productionDate" String "2019-05-02T00:00:00+00:00"
             "description" String ""
             "type" String "FieldReplaceableUnit"
     
         "hwType" String "FieldReplaceableUnit"
         "hwModel" String "OPEN"
         "hwCapability" String "OPEN RADIO"
     )
        ^;# end @MO
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
    if($MIMVERSION gt "18-Q1-V4")
    {
        @MOCmds=qq^
    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "C"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 1
    "rfPortId" String "C"
    )

    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=1"
    identity "D"
    moType ReqRfPort:RfPort
    exception none
    nrOfAttributes 1
    "rfPortId" String "D"
    ) ^;# end @MO

        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    }
$fieldreplaceableUnitNum=16;
    $fieldCount=2;
    while(($fieldCount<=$fieldreplaceableUnitNum)){
       @MOCmds=qq^
    CREATE
    (
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1"
    identity $fieldCount
    moType ReqFieldReplaceableUnit:FieldReplaceableUnit
    exception none
    nrOfAttributes 3
    "fieldReplaceableUnitId" String $fieldCount
    "administrativeState" Integer 1
    "operationalState" Integer 1
    )
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount"
    identity "1"
    moType ReqEFuse:EFuse
    exception none
    nrOfAttributes 1
    "eFuseId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount,ReqEFuse:EFuse=1"
    identity "1"
    moType ReqEnergyMeter:EnergyMeter
    exception none
    nrOfAttributes 1
    "energyMeterId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount"
    identity "1"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount,ReqSfpModule:SfpModule=1"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount"
    identity "2"
    moType ReqSfpModule:SfpModule
    exception none
    nrOfAttributes 2
    "administrativeState" Integer 1
    "sfpModuleId" String "2"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ReqEquipment:Equipment=1,ReqFieldReplaceableUnit:FieldReplaceableUnit=$fieldCount,ReqSfpModule:SfpModule=2"
    identity "1"
    moType ReqSfpChannel:SfpChannel
    exception none
    nrOfAttributes 1
    "sfpChannelId" String "1"
)
        ^;# end @MO
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    $fieldCount++;
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
}# end outer while

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
