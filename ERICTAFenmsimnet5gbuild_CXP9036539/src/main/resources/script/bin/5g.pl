#!/usr/bin/perl


### VERSION HISTORY
#####################################################################################
#     Version     : 2.1
#
#     Revision    : CXP 903 6539-1-2
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-26474
#
#     Description : Create log files for 5G network.
#
#     Date        : 30th May 2019
#
####################################################################################
#####################################################################################
#     Version     : 2.0
#
#     Revision    : CXP 903 6539-1-1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24906
#
#     Description : Updating outputDirectory attribute value for 5GRadioNodes.
#
#     Date        : 27th May 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.9
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24526
#
#     Description : setting userLabel attribute in SysM MO for 5GRadioNodes.
#
#     Date        : 23rd April 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.8
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-23789
#
#     Description : Updating GNodeBRpFunction mos for 5GRadioNodes.
#
#     Date        : 07th Mar 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.7
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-23062
#
#     Description : Updating GNodeBFunction mos for 5GRadioNodes.
#
#     Date        : 21st Jan 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.6
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-21601
#
#     Description : Updating GNBDU mos for 5GRadioNodes.
#
#     Date        : 2nd Nov 2018
#
####################################################################################
#####################################################################################
#     Version     : 1.5
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-21586,NSS-21137
#
#     Description : 5g Radio node with GNBCUCPFunction and configured relationships
#
#     Date        : 30th Oct 2018
#
####################################################################################
#####################################################################################
#     Version     : 1.4
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-19573,NSS-21316,NSS-21586,NSS-21057
#
#     Description : New MOs created GNBCUCPFunction, EventJob etc for 5GRadioNode
#
#     Date        : 25th Oct 2018
#
####################################################################################
#####################################################################################
#     Version: 1.3
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-18853
#
#     Description :Health Check log type required for 5GRadioNode
#
#     Date : 18th May 2018
#
####################################################################################
#####################################################################################
#     Version: 1.2
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-14644
#
#     Description :Support for Backuphousekeeping for 5G Radionodes.
#
#     Date : 26th Sep 2017
#
####################################################################################
#####################################################################################
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-13911
#
#     Description :Require features for 5G Radionodes.
#
#     Date : September 2017
#
####################################################################################
####################
# Env
####################
use FindBin qw($Bin);
use Cwd;
use POSIX;
#use System;
#####################################
##################################
local $SIMNAME=$ARGV[0];
local $NETSIMDIR="/netsim/netsimdir/";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local @netsim_output=();
local $dir=cwd;
local $currentdir=$dir."/";
local $scriptpath="$currentdir";
local $MOSCRIPT="$scriptpath".$SIMNAME.".mo";
local $MMLSCRIPT="$scriptpath".$SIMNAME.".mml";
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT;
local $LOGFILE=$scriptpath."../log/";

local @sim1= split /x/, $SIMNAME;
local @sim2= split /-/, $sim1[1];
local @sim3= split /LTE/, $sim1[0];
local @sim4= split /LTE/, $sim2[3];
local $MIMVERSION="$sim3[1]";
local $NUMOFNODES="$sim2[0]";
local $NODETYPE="$sim2[2]";
local $SIMNUM="$sim4[1]";
local $NETYPE="${sim2[2]} ${sim3[1]}";
local $nodeStartNumber="00001",$counter="0";
local $NODENAME="LTE${SIMNUM}${NODETYPE}";
local $node="${NODENAME}00001";

local $NODECOUNT=1;
local $productNumber=$ARGV[1],$productRevision=$ARGV[2];
local $pdkdate=`date '+%FT%T'`;chomp $pdkdate;
local $ExternalNodeBaseName="LTE01dg2ERBS0000",$temp=3;
$LOGFILE=$LOGFILE."${SIMNAME}.log";
print "$scriptpath  ------------ $LOGFILE \n";
#############################################################
####################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
   unlink "$NETSIMMOSCRIPT";}
if (-e "$NETSIMMMLSCRIPT"){
   unlink "$NETSIMMMLSCRIPT";}
#if (-e "$LOGFILE"){
#   unlink "$LOGFILE";}

open LOG, ">>$LOGFILE" or die $!;
print "... ${0} started running at $date\n";
print LOG "... ${0} started running at $date\n";

#-----------------------------------------
################################################################

#############################
# feature loading
#############################

while ($NODECOUNT<=$NUMOFNODES) {

	if($NODECOUNT<10){$nodezeros="0000";}
	elsif($NODECOUNT<100){$nodezeros="000";}
	else{$nodezeros="00";}
	$nodeName=$NODENAME.$nodezeros.$NODECOUNT;

	# build mml script
	@MOCmds=();
	@MOCmds=qq^

  SET
  (
      mo "ManagedElement=$nodeName,SystemFunctions=1,SwInventory=1,SwVersion=1"
      exception none
      nrOfAttributes 1
      "administrativeData" Struct
          nrOfElements 6
          "productName" String "$nodeName"
          "productNumber" String "$productNumber"
          "productRevision" String "$productRevision"
          "productionDate" String "$pdkdate"
          "description" String "RadioNode"
          "type" String "RadioNode"
  
  )
  
  SET
  (
      mo "ManagedElement=$nodeName,SystemFunctions=1,SwInventory=1,SwItem=1"
      exception none
      nrOfAttributes 1
      "administrativeData" Struct
          nrOfElements 6
          "productName" String "$nodeName"
          "productNumber" String "$productNumber"
          "productRevision" String "$productRevision"
          "productionDate" String "$pdkdate"
          "description" String "RadioNode"
          "type" String "RadioNode"
  
  )

  SET
  (
      mo "ManagedElement=$nodeName,SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1"
      exception none
      nrOfAttributes 1
      "fileLocation" String "/rop"
  )
  CREATE
  (
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsBrM:BrM=1"
    identity "1"
    moType RcsBrM:BrmBackupManager
    exception none
    nrOfAttributes 3
   
    "backupDomain" String "System"
    "backupType" String "Systemdata"
    "brmBackupManagerId" String "1"
  )


SET
(
    mo "ManagedElement=$nodeName,SystemFunctions=1,BrM=1,BrmBackupManager=1,BrmBackup=1"
    exception none
    nrOfAttributes 2
    "creationType" Integer 3
    "backupName" String "1"
)

SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsSecM:SecM=1,RcsCertM:CertM=1,RcsCertM:CertMCapabilities=1"
    exception none
    nrOfAttributes 1
    "enrollmentSupport" Array Integer 3
         0
         1
         3
)

  CREATE
  (
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
    identity "1"
    moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 18
    "hwType" String "Card"
    "hwUnitLocation" String "slot:1"
    "productData" Struct
        nrOfElements 6
        "productName" String "$nodeName"
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productionDate" String ""
        "description" String ""
        "type" String ""

    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productDesignation" String ""

    "serialNumber" String "D821781334"
   )
CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity AiLog
 exception none
 nrOfAttributes 1
 "logId" String "AiLog"
 )

 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity AlarmLog
 exception none
 nrOfAttributes 1
 "logId" String "AlarmLog"
 )

 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity AuditTrailLog
 exception none
 nrOfAttributes 1
 "logId" String "AuditTrailLog"
  )

 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity SecurityLog
 exception none
 nrOfAttributes 1
 "logId" String "SecurityLog"
 )

 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity SwmLog
 exception none
 nrOfAttributes 1
 "logId" String "SwmLog"
 )
 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity TnApplicationLog
 exception none
 nrOfAttributes 1
 "logId" String "TnApplicationLog"
 )

 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity TnNetworkLog
 exception none
 nrOfAttributes 1
 "logId" String "TnNetworkLog"
 )

 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity HealthCheckLog
 exception none
 nrOfAttributes 1
 "logId" String "HealthCheckLog"
 )
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsSysM:SysM=1"
    exception none
    nrOfAttributes 1
    "userLabel" String "value"
)

   ^;# end @MO


   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
if($MIMVERSION ge "18-Q4-V3")
{
@MOCmds=();
@MOCmds=qq^ CREATE
(
    parent "ComTop:ManagedElement=$nodeName"
    identity "1"
    moType GNBCUCP:GNBCUCPFunction
    exception none
    nrOfAttributes 9
    "f1SctpEndPointRef" Ref "null"
    "gNBCUCPFunctionId" String "1"
    "gNBCUName" String "null"
    "gNBId" Int64 0
    "gNBIdLength" Int32 22
    "ngcSctpEndPointRef" Ref "null"
    "pLMNIdList" Array String 0
    "x2SctpEndPointRef" Ref "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:EUtraNetwork
    exception none
    nrOfAttributes 2
    "eUtraNetworkId" String "1"
    "userLabel" String "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "1"
    moType GNBCUCP:ExternalENodeBFunction
    exception none
    nrOfAttributes 4
    "eNBPlmnId" String "125:46"
    "eNodeBId" Int32 1
    "externalENodeBFunctionId" String "1"
    "userLabel" String "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName"
    identity "1"
    moType GNBDU:GNBDUFunction
    exception none
    nrOfAttributes 8
    "f1SctpEndPointRef" Ref "null"
    "gNBDUFunctionId" String "1"
    "gNBDUId" Int64 1
    "gNBDUName" String "null"
    "gNBId" Int64 1
    "gNBIdLength" Int32 22
    "release" String "null"
    "userLabel" String "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:Rrc
    exception none
    nrOfAttributes 8
    "n310" Int32 20
    "n311" Int32 1
    "rrcId" String "1"
    "t300" Int32 1000
    "t301" Int32 400
    "t304" Int32 1000
    "t310" Int32 2000
    "t311" Int32 3000
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:RpUserPlaneTermination
    exception none
    nrOfAttributes 1
    "rpUserPlaneTerminationId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1,GNBDU:RpUserPlaneTermination=1"
    identity "1"
    moType GNBDU:RpUserPlaneLink
    exception none
    nrOfAttributes 3
    "localEndPoint" String "null"
    "remoteEndPoint" String "null"
    "rpUserPlaneLinkId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:RadioBearerTable
    exception none
    nrOfAttributes 1
    "radioBearerTableId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1,GNBDU:RadioBearerTable=1"
    identity "1"
    moType GNBDU:DataRadioBearer
    exception none
    nrOfAttributes 9
    "dataRadioBearerId" String "1"
    "dlMaxRetxThreshold" Int32 16
    "dlPollPdu" Int32 32
    "tPollRetransmitDl" Int32 40
    "tPollRetransmitUl" Int32 40
    "tStatusProhibitDl" Int32 10
    "tStatusProhibitUl" Int32 10
    "ulMaxRetxThreshold" Int32 32
    "ulPollPdu" Int32 16
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:QciProfileEndcConfig
    exception none
    nrOfAttributes 3
    "qciProfileEndcConfigId" String "1"
    "tReassemblyDl" Int32 20
    "tReassemblyUl" Int32 20
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:NRCellDU
    exception none
    nrOfAttributes 28
    "administrativeState" Integer 0
    "availabilityStatus" Array Integer 0
    "csiRsPeriodicity" Int32 40
    "endcDlNrLowQualThresh" Int32 -8
    "endcDlNrQualHyst" Int32 8
    "gNodeBSectorCarrierRef" Array Ref 0
    "nCGI" Int64 "null"
    "nCI" Int64 1
    "nRCellDUId" String "1"
    "nRPCI" Int32 1
    "nRTAC" Int32 1
    "ofdmNumerology" Int32 3
    "operationalState" Integer 0
    "pLMNIdList" Array Struct 3
        nrOfElements 2
        "mCC" String "128"
        "mNC" String "49"

        nrOfElements 2
        "mCC" String "129"
        "mNC" String "50"

        nrOfElements 2
        "mCC" String "130"
        "mNC" String "51"
    "pointAArfcnDlFdd" Int32 "null"
    "pointAArfcnTdd" Int32 "null"
    "pointAArfcnUlFdd" Int32 "null"
    "pointAFrequencyDlFdd" Int32 "null"
    "pointAFrequencyTdd" Int32 "null"
    "pointAFrequencyUlFdd" Int32 "null"
    "pZeroNomPucch" Int32 -114
    "pZeroNomPuschGrant" Int32 -100
    "qRxLevMin" Int32 -140
    "transmitSib1" Boolean false
    "trsPeriodicity" Int32 20
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1,GNBDU:NRCellDU=1"
    identity "1"
    moType GNBDU:SyncSignal
    exception none
    nrOfAttributes 10
    "arfcn" Int32 "null"
    "arfcnAutoSelected" Int32 "null"
    "blockPerBurstSet" Int32 12
    "frequency" Int32 "null"
    "gscn" Int32 "null"
    "ofdmNumerology" Int32 "null"
    "ssbFirstSymbolIndex" Integer 3
    "ssbPeriodicity" Int32 20
    "ssbPosition" Integer 0
    "syncSignalId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1,GNBDU:NRCellDU=1"
    identity "1"
    moType GNBDU:RandomAccess
    exception none
    nrOfAttributes 4
    "preambleRecTargetPower" Int32 -110
    "preambleTransMax" Int32 10
    "rachRootSequence" Int32 1
    "randomAccessId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:NRCellCU
    exception none
    nrOfAttributes 17
    "cellLocalId" Int32 0
    "cellState" Integer "null"
    "nCGI" Int64 "null"
    "nCI" Int64 "null"
    "nRCellCUId" String "1"
    "nRPCI" Int32 "null"
    "pLMNIdList" Array Struct 0
    "qHyst" Int32 4
    "qQualMinOffsetCell" Int32 "null"
    "qRxLevMinOffsetCell" Int32 "null"
    "reservedBy" Array Ref 0
    "serviceStatus" Integer "null"
    "sNonIntraSearchP" Int32 0
    "sNonIntraSearchQ" Int32 "null"
    "termPointToGNBDURef" Ref "null"
    "threshServingLowP" Int32 0
    "threshServingLowQ" Int32 "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,GNBCUCP:GNBCUCPFunction=1"
    exception none
    nrOfAttributes 2
    "pLMNIdList" Array String 3
        125:46
        126:47
        127:48
    "gNBId" Int64 10001
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:NRCellCU=1"
    exception none
    nrOfAttributes 2
    "pLMNIdList" Array Struct 3
        nrOfElements 2
        "mCC" String "125"
        "mNC" String "46"

        nrOfElements 2
        "mCC" String "126"
        "mNC" String "47"

        nrOfElements 2
        "mCC" String "127"
        "mNC" String "48"
    "nCGI" Int64 89898
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1,GNBDU:NRCellDU=1"
    exception none
    nrOfAttributes 2
    "nRTAC" Int32 999
    "nCGI" Int64 8989876
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,GNBDU:GNBDUFunction=1"
    exception none
    nrOfAttributes 1
    "f1SctpEndPointRef" Ref ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1"
    identity "1"
    moType RcsPMEventM:EventProducer
    exception none
    nrOfAttributes 1
    "eventProducerId" String "1"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=1,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/rcs/sftp"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName"
    identity "1"
    moType NratGNodeBFunction:GNodeBFunction
    exception none
    nrOfAttributes 11
    "active" Boolean true
    "gNBId" Int64 1
    "gNBIdLength" Int32 22
    "gNBPlmnId" String "125:46"
    "gNodeBFunctionId" String "1"
    "maxN2DedProcTime" Int32 5
    "ngcSctpEndPointRef" Ref "null"
    "tDcOverall" Int32 7
    "x2SctpEndPointRef" Ref "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1"
    identity "1"
    moType NratGNodeBFunction:SecurityHandling
    exception none
    nrOfAttributes 2
    "cipheringAlgoPrio" Array Integer 3
         1
         2
         0
    "securityHandlingId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1"
    identity "1"
    moType NratGNodeBFunction:QciProfileEndcConfigExt
    exception none
    nrOfAttributes 6
    "initialUplinkConf" Integer 0
    "qciProfileEndcConfigExtId" String "1"
    "rlcModeQciUM" Array Int32 0
    "tReorderingDlPdcp" Int32 200
    "tReorderingUlDiscardPdcp" Int32 200
    "tReorderingUlPdcp" Int32 10
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1"
    identity "1"
    moType NratGNodeBFunction:EUtraNetwork
    exception none
    nrOfAttributes 2
    "eUtraNetworkId" String "1"
    "userLabel" String "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1,NratGNodeBFunction:EUtraNetwork=1"
    identity "1"
    moType NratGNodeBFunction:ExternalENodeBFunction
    exception none
    nrOfAttributes 4
    "eNBPlmnId" String "125:46"
    "eNodeBId" Int32 0
    "externalENodeBFunctionId" String "1"
    "userLabel" String "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1"
    exception none
    nrOfAttributes 1
    "gNBPlmnId" String "262:49"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1"
    identity "1"
    moType NratGNodeBFunction:GUtranCell
    exception none
    nrOfAttributes 8
    "additionalPlmnList" Array String 1
        125:46
    "administrativeState" Integer 0
    "availabilityStatus" Array Integer 0
    "cellId" Int32 0
    "cgi" Int64 "null"
    "gUtranCellId" String "1"
    "operationalState" Integer 0
    "tempTac" Int32 0
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,NratGNodeBFunction:GNodeBFunction=1,NratGNodeBFunction:GUtranCell=1"
    exception none
    nrOfAttributes 3
    "cgi" Int64 1
    "cellId" Int32 1
    "additionalPlmnList" Array String 3
        263:49
        264:49
        265:49
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName"
    identity "1"
    moType NratGNodeBRpFunction:GNodeBRpFunction
    exception none
    nrOfAttributes 8
    "active" Boolean true
    "activeCurr" Boolean "null"
    "dlBbCapacityMaxLimit" Int32 "null"
    "dlBbCapacityNet" Int32 "null"
    "gNodeBRpFunctionId" String "1"
    "rpUpIpAddressRef" Ref "null"
    "ulBbCapacityMaxLimit" Int32 "null"
    "ulBbCapacityNet" Int32 "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1"
	identity "1"
    moType NratGNodeBRpFunction:Rrc
    exception none
    nrOfAttributes 8
    "n310" Int32 20
    "n311" Int32 1
    "rrcId" String "1"
    "t300" Int32 1000
    "t301" Int32 400
    "t304" Int32 1000
    "t310" Int32 2000
    "t311" Int32 3000
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1"
    identity "1"
    moType NratGNodeBRpFunction:RpUserPlaneTermination
    exception none
    nrOfAttributes 1
    "rpUserPlaneTerminationId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1,NratGNodeBRpFunction:RpUserPlaneTermination=1"
    identity "1"
    moType NratGNodeBRpFunction:RpUserPlaneLink
    exception none
    nrOfAttributes 3
    "localEndPoint" String "null"
    "remoteEndPoint" String "null"
    "rpUserPlaneLinkId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1"
    identity "1"
    moType NratGNodeBRpFunction:RadioBearerTable
    exception none
    nrOfAttributes 1
    "radioBearerTableId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1,NratGNodeBRpFunction:RadioBearerTable=1"
    identity "1"
    moType NratGNodeBRpFunction:SignalingRadioBearer
    exception none
    nrOfAttributes 7
    "dlMaxRetxThreshold" Int32 8
    "signalingRadioBearerId" String "1"
    "tPollRetransmitDl" Int32 45
    "tPollRetransmitUl" Int32 45
    "tReassemblyDl" Int32 35
    "tReassemblyUl" Int32 35
    "ulMaxRetxThreshold" Int32 8
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1,NratGNodeBRpFunction:RadioBearerTable=1"
    identity "1"
    moType NratGNodeBRpFunction:DataRadioBearer
    exception none
    nrOfAttributes 9
    "dataRadioBearerId" String "1"
    "dlMaxRetxThreshold" Int32 16
    "dlPollPdu" Int32 32
    "tPollRetransmitDl" Int32 40
    "tPollRetransmitUl" Int32 40
    "tStatusProhibitDl" Int32 10
    "tStatusProhibitUl" Int32 10
    "ulMaxRetxThreshold" Int32 32
    "ulPollPdu" Int32 16
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1"
    identity "1"
    moType NratGNodeBRpFunction:QciProfileEndcConfig
    exception none
    nrOfAttributes 3
    "qciProfileEndcConfigId" String "1"
    "tReassemblyDl" Int32 20
    "tReassemblyUl" Int32 20
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1"
    identity "1"
    moType NratGNodeBRpFunction:GUtranDUCell
    exception none
    nrOfAttributes 39
    "additionalPlmnList" Array String 1

    "administrativeState" Integer 0
    "availabilityStatus" Array Integer 0
    "bandList" Array Int32 0
    "bandListManual" Array Int32 0
    "cellReservedForOperator" Boolean false
    "cgi" Int64 1
    "csiAperRptNoDataTmr" Int32 160
    "csiAperRptTmr" Int32 40
    "csiReportFormat" Integer 0
    "csiReportFormatInitial" Integer 0
    "csiRsConfig16P" Struct
        nrOfElements 3
        "csiRsControl16Ports" Integer 0
        "i11Restriction" String ""
        "i12Restriction" String ""

    "csiRsConfig32P" Struct
        nrOfElements 3
        "csiRsControl32Ports" Integer 0
        "i11Restriction" String ""
        "i12Restriction" String ""

    "csiRsConfig8P" Struct
        nrOfElements 3
        "csiRsControl8Ports" Integer 1
        "i11Restriction" String "FFFF"
        "i12Restriction" String ""

    "csiRsPeriodicity" Int32 40
    "dl256QamEnabled" Boolean true
    "endcUlLegSwitchEnabled" Boolean false
    "endcUlNrLowQualThresh" Int32 -8
    "endcUlNrQualHyst" Int32 8
    "gNodeBSectorCarrierRef" Array Ref 0
    "gUtranDUCellId" String "1"
    "ofdmNumerology" Int32 3
    "operationalState" Integer 0
    "physicalLayerCellIdGroup" Int32 0
    "physicalLayerSubCellId" Int32 0
    "pointAArfcnDlFdd" Int32 "null"
    "pointAArfcnTdd" Int32 "null"
    "pointAArfcnUlFdd" Int32 "null"
    "pointAFrequencyDlFdd" Int32 "null"
    "pointAFrequencyTdd" Int32 "null"
    "pointAFrequencyUlFdd" Int32 "null"
    "pZeroNomPucch" Int32 -114
    "pZeroNomPuschGrant" Int32 -100
    "qRxLevMin" Int32 -140
    "tempTac" Int32 0
    "transmitSib1" Boolean false
    "trsPeriodicity" Int32 20
    "trsPowerBoosting" Int32 0
    "ulMaxMuMimoLayers" Int32 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1,NratGNodeBRpFunction:GUtranDUCell=1"
    identity "1"
    moType NratGNodeBRpFunction:SyncSignalDU
	exception none
    nrOfAttributes 10
    "arfcn" Int32 "null"
    "arfcnAutoSelected" Int32 "null"
    "blockPerBurstSet" Int32 12
    "frequency" Int32 "null"
    "gscn" Int32 "null"
    "ofdmNumerology" Int32 "null"
    "ssbFirstSymbolIndex" Integer 3
    "ssbPeriodicity" Int32 20
    "ssbPosition" Integer 0
    "syncSignalDUId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1,NratGNodeBRpFunction:GUtranDUCell=1"
    identity "1"
    moType NratGNodeBRpFunction:RandomAccess
    exception none
    nrOfAttributes 4
    "preambleRecTargetPower" Int32 -110
    "preambleTransMax" Int32 10
    "rachRootSequence" Int32 1
    "randomAccessId" String "1"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,NratGNodeBRpFunction:GNodeBRpFunction=1,NratGNodeBRpFunction:GUtranDUCell=1"
    exception none
    nrOfAttributes 1
    "additionalPlmnList" Array String 3
        266:49
        267:49
        268:49
)



    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
if($MIMVERSION eq "18-Q4-V3")
{
@MOCmds=();
@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1"
    identity "CUCP"
    moType RcsPMEventM:EventProducer
    exception none
    nrOfAttributes 1
    "eventProducerId" String "CUCP"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "1"
    moType RcsPMEventM:StreamingCapabilities
    exception none
    nrOfAttributes 2
    "streamCapabilitiesId" String "1"
    "supportedCompressionTypes" Array Integer 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "1"
    moType RcsPMEventM:FilePullCapabilities
    exception none
    nrOfAttributes 6
    "filePullCapabilitiesId" String "1"
    "supportedReportingPeriods" Array Integer 0
    "outputDirectory" String "/tmp/OMS_LOGS/ebs/ready"
    "alignedReportingPeriod" Boolean true
    "supportedCompressionTypes" Array Integer 0
    "finalROP" Boolean false
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/tmp/OMS_LOGS/ebs/ready"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "1"
    moType RcsPMEventM:EventGroup
    exception none
    nrOfAttributes 5
    "eventGroupId" String "1"
    "description" String ""
    "moClass" Struct
        nrOfElements 2
        "moClassName" String ""
        "mimName" String ""

    "eventGroupVersion" String ""
    "validFilters" Array Ref 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventGroup=1"
    identity "1"
    moType RcsPMEventM:EventType
    exception none
    nrOfAttributes 2
    "eventTypeId" String "1"
    "triggerDescription" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "1"
    moType RcsPMEventM:EventFilterType
    exception none
    nrOfAttributes 5
    "eventFilterTypeId" String "1"
    "description" String ""
    "filterMethod" Integer 0
    "valueSpec" String ""
    "defaultValue" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "1"
    moType RcsPMEventM:EventCapabilities
    exception none
    nrOfAttributes 2
    "eventCapabilitiesId" String "1"
    "maxNoOfJobs" Uint16 "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "10000"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10000"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10000"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "10001"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10001"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10001"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "10002"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10002"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10002"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "10003"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10003"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10003"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "10004"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10004"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10004"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "10005"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10005"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
if($MIMVERSION ge "18-Q4-V4")
{
@MOCmds=();
@MOCmds=qq^
 DELETE
(
  mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:FilePullCapabilities=2"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP"
    identity "1"
    moType RcsPMEventM:FilePullCapabilities
    exception none
    nrOfAttributes 1
    "filePullCapabilitiesId" String "1"
)
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
if($MIMVERSION ge "19-Q1-V1")
{
@MOCmds=();
@MOCmds=qq^
DELETE
(
  mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:FilePullCapabilities=2"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "1"
    moType RcsPMEventM:FilePullCapabilities
    exception none
    nrOfAttributes 1
    "filePullCapabilitiesId" String "1"
)
DELETE
(
  mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:FilePullCapabilities=2"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "1"
    moType RcsPMEventM:FilePullCapabilities
    exception none
    nrOfAttributes 1
    "filePullCapabilitiesId" String "1"
)
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
}
if( ($MIMVERSION eq "18-Q4-V4") || ($MIMVERSION eq "18-Q4-V3") )
{
@MOCmds=();
@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1"
    identity "CUUP"
    moType RcsPMEventM:EventProducer
    exception none
    nrOfAttributes 1
    "eventProducerId" String "CUUP"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "1"
    moType RcsPMEventM:StreamingCapabilities
    exception none
    nrOfAttributes 2
    "streamCapabilitiesId" String "1"
    "supportedCompressionTypes" Array Integer 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "1"
    moType RcsPMEventM:FilePullCapabilities
    exception none
    nrOfAttributes 6
    "filePullCapabilitiesId" String "1"
    "supportedReportingPeriods" Array Integer 0
    "outputDirectory" String "/tmp/OMS_LOGS/ebs/ready"
    "alignedReportingPeriod" Boolean true
    "supportedCompressionTypes" Array Integer 0
    "finalROP" Boolean false
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/tmp/OMS_LOGS/ebs/ready"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "1"
    moType RcsPMEventM:EventGroup
    exception none
    nrOfAttributes 5
    "eventGroupId" String "1"
    "description" String ""
    "moClass" Struct
        nrOfElements 2
        "moClassName" String ""
        "mimName" String ""

    "eventGroupVersion" String ""
    "validFilters" Array Ref 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventGroup=1"
    identity "1"
    moType RcsPMEventM:EventType
    exception none
    nrOfAttributes 2
    "eventTypeId" String "1"
    "triggerDescription" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "1"
    moType RcsPMEventM:EventFilterType
    exception none
    nrOfAttributes 5
    "eventFilterTypeId" String "1"
    "description" String ""
    "filterMethod" Integer 0
    "valueSpec" String ""
    "defaultValue" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "1"
    moType RcsPMEventM:EventCapabilities
    exception none
    nrOfAttributes 2
    "eventCapabilitiesId" String "1"
    "maxNoOfJobs" Uint16 "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "10000"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10000"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10000"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "10001"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10001"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10001"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "10002"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10002"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10002"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "10003"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10003"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10003"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "10004"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10004"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10004"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "10005"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10005"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1"
    identity "DU"
    moType RcsPMEventM:EventProducer
    exception none
    nrOfAttributes 1
    "eventProducerId" String "DU"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "1"
    moType RcsPMEventM:StreamingCapabilities
    exception none
    nrOfAttributes 2
    "streamCapabilitiesId" String "1"
    "supportedCompressionTypes" Array Integer 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "1"
    moType RcsPMEventM:FilePullCapabilities
    exception none
    nrOfAttributes 6
    "filePullCapabilitiesId" String "1"
    "supportedReportingPeriods" Array Integer 0
    "outputDirectory" String "/tmp/OMS_LOGS/ebs/ready"
    "alignedReportingPeriod" Boolean true
    "supportedCompressionTypes" Array Integer 0
    "finalROP" Boolean false
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/tmp/OMS_LOGS/ebs/ready"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "1"
    moType RcsPMEventM:EventGroup
    exception none
    nrOfAttributes 5
    "eventGroupId" String "1"
    "description" String ""
    "moClass" Struct
        nrOfElements 2
        "moClassName" String ""
        "mimName" String ""

    "eventGroupVersion" String ""
    "validFilters" Array Ref 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventGroup=1"
    identity "1"
    moType RcsPMEventM:EventType
    exception none
    nrOfAttributes 2
    "eventTypeId" String "1"
    "triggerDescription" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "1"
    moType RcsPMEventM:EventFilterType
    exception none
    nrOfAttributes 5
    "eventFilterTypeId" String "1"
    "description" String ""
    "filterMethod" Integer 0
    "valueSpec" String ""
    "defaultValue" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "1"
    moType RcsPMEventM:EventCapabilities
    exception none
    nrOfAttributes 2
    "eventCapabilitiesId" String "1"
    "maxNoOfJobs" Uint16 "null"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "10000"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10000"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10000"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "10001"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10001"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10001"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "10002"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10002"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10002"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "10003"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10003"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10003"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "10004"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10004"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10004"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "10005"
    moType RcsPMEventM:EventJob
    exception none
    nrOfAttributes 15
    "eventJobId" String "10005"
    "description" String "null"
    "eventFilter" Array Struct 0
    "requestedJobState" Integer 1
    "currentJobState" Integer 1
    "fileOutputEnabled" Boolean true
    "streamDestinationIpAddress" String "null"
    "streamDestinationPort" Uint16 "null"
    "reportingPeriod" Integer "null"
    "streamOutputEnabled" Boolean true
    "jobControl" Integer 0
    "eventGroupRef" Array Ref 0
    "eventTypeRef" Array Ref 0
    "fileCompressionType" Integer "null"
    "streamCompressionType" Integer "null"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 2
    "requestedJobState" Integer 2
    "currentJobState" Integer 2
)
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
if($MIMVERSION eq "18-Q4-V4")
{
@MOCmds=();
@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP"
    identity "CCTR"
    moType RcsPMEventM:EventGroup
    exception none
    nrOfAttributes 5
    "eventGroupId" String "CCTR"
    "description" String ""
    "moClass" Struct
        nrOfElements 2
        "moClassName" String ""
        "mimName" String ""

    "eventGroupVersion" String ""
    "validFilters" Array Ref 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventGroup=CCTR"
    identity "1"
    moType RcsPMEventM:EventType
    exception none
    nrOfAttributes 2
    "eventTypeId" String "1"
    "triggerDescription" String ""
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU"
    identity "CCTR"
    moType RcsPMEventM:EventGroup
    exception none
    nrOfAttributes 5
    "eventGroupId" String "CCTR"
    "description" String ""
    "moClass" Struct
        nrOfElements 2
        "moClassName" String ""
        "mimName" String ""

    "eventGroupVersion" String ""
    "validFilters" Array Ref 0
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventGroup=CCTR"
    identity "1"
    moType RcsPMEventM:EventType
    exception none
    nrOfAttributes 2
    "eventTypeId" String "1"
    "triggerDescription" String ""
)

    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
}
if($MIMVERSION ge "18-Q4-V4")
{
@MOCmds=();
@MOCmds=qq^
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$nodeName,SystemFunctions=1,PmEventM=1,EventProducer=CUCP,EventGroup=CCTR
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$nodeName,SystemFunctions=1,PmEventM=1,EventProducer=CUUP,EventGroup=CCTR
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$nodeName,SystemFunctions=1,PmEventM=1,EventProducer=DU,EventGroup=CCTR
)
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
@MOCmds=();
@MOCmds=qq^
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/c/pm_data/pm_data_CUCP/"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/c/pm_data/pm_data_CUUP/"
)
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:FilePullCapabilities=1"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/c/pm_data/pm_data_DU/"
)
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
}
#if($MIMVERSION ge "18-Q4-V3")
#{
#        if ( $temp == 0 )
#        {
#             $temp=3;
#        }
#        for (my $x=$temp,my $y=$NODECOUNT;($x>0) && ($y!=10);$x--,$y++)
#        {
#        $ENBID="${ExternalNodeBaseName}$y";
#       @MOCmds=();
#        @MOCmds=qq^
#        CREATE
#        (
#            parent "ComTop:ManagedElement=$nodeName,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
#            identity "$ENBID"
#            moType GNBCUCP:ExternalENodeBFunction
#            exception none
#            nrOfAttributes 4
#            "eNBPlmnId" String "353:57"
#            "eNodeBId" Int32 $y
#            "externalENodeBFunctionId" String "$ENBID"
#            "userLabel" String "null"
#        )
#        ^;# end @MO
#        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
#		}
#        $temp=$temp-1;
#}


push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

  @MMLCmds=(".open ".$SIMNAME,
            ".select ".$nodeName,
            ".start ",
            "useattributecharacteristics:switch=\"off\"; ",
            "kertayle:file=\"$NETSIMMOSCRIPT\";"
       );# end @MMLCmds


$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
$NODECOUNT++;


}# end outer while NUMOFNODES

  # execute mml script
  #  @netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
  system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
  # output mml script execution
#     print "@netsim_output\n";
     #print LOG "@netsim_output\n";
# remove mo script
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";

#############################
# END features loading
#############################




#################################################
################################
# Subs
################################
sub makeMOscript{
    local ($fileaction,$moscriptname,@cmds)=@_;
    $moscriptname=~s/\.\///;
    print "";
    if($fileaction eq "write"){
      if(-e "$moscriptname"){
        unlink "$moscriptname";
      }#end if
   print "moscriptname : $moscriptname\n";
      open FH1, ">$moscriptname" or die $!;
    }# end write
    if($fileaction eq "append"){
       open FH1, ">>$moscriptname" or die $!;
    }# end append
    foreach $_(@cmds){print FH1 "$_\n";}
    close(FH1);
    system("chmod 744 $moscriptname");
    return($moscriptname);
}# end makeMOscript
sub makeMMLscript{
        local ($fileaction,$mmlscriptname,@cmds)=@_;

        $mmlscriptname=~s/\.\///;
        if($fileaction eq "write"){
                if(-e "$mmlscriptname"){
                        unlink "$mmlscriptname";
                }#end if
                open FH, ">$mmlscriptname" or die $!;
        }# end write

        if($fileaction eq "append"){
                open FH, ">>$mmlscriptname" or die $!;
        }# end append

        print FH "#!/bin/sh\n";
        foreach $_(@cmds){
                print FH "$_\n";
        }
        close(FH);
        system("chmod 744 $mmlscriptname");

        return($mmlscriptname);
}# end makeMMLscript
