#!/usr/bin/perl
####################################################################################
#      Version     : 1.13
#
#      Revision    : CXP 903 6539-1-70
#
#      Author      : Vinay baratam
#
#      JIRA        : NSS-48796
#
#      Description : Making GNBDU:RpUserPlaneTermination support for below 24.Q2 versions.
#
#      Date        : 16th May 2024
####################################################################################
#      Version     : 1.12
#
#      Revision    : CXP 903 6539-1-67
#
#      Author      : Vinay baratam
#
#      JIRA        : NSS-46327
#
#      Description : Updating attributes to support with versions. 
#
#      Date        : 27th Nov 2023
####################################################################################
#      Version     : 1.11
#
#      Revision    : CXP 903 6539-1-59
#
#      Author      : Vinay baratam
#
#      JIRA        : NSS-42322
#
#      Description : Updating code base to support the attributes for both older and newer versions. 
#
#      Date        : 21st Feb 2023
#####################################################################################
#####################################################################################
#      Version     : 1.10
#
#      Revision    : CXP 903 6539-1-45
#
#      Author      : J Saivikas 
#
#      JIRA        : NSS-38167
#
#      Description : Deleting RcsHcm:HcRule=CheckCPRILinkStatus MO
#
#      Date        : 4th Jan 2022
####################################################################################
####################################################################################     
##     Version     : 1.9
##
##     Revision    : CXP 903 6539-1-25
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-32261
##
##     Description : Deleting GNBDU:QciProfileEndcConfig MO
##
##     Date        : 8th Sep 2020
##
#####################################################################################
#####################################################################################
#####################################################################################
#     Version      : 1.8
#
#     Revision     : CXP 903 6539-1-24
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NO-JIRA
#
#     Description  : Correcting Product Data code
#
#     Date         : 23rd Jul 2020
#
######################################################################################
#####################################################################################
#     Version     : 1.7
#
#     Revision    : CXP 903 6539-1-8
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-27262
#
#     Description : Adding GNBCUUPFunction
#
#     Date        : 18 October 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.6
#
#     Revision    : CXP 903 6539-1-7
#
#     Author      : Harish Dunga
#
#     JIRA        : NSS-25837
#
#     Description : Setting gNBId to a dynamic unique value
#
#     Date        : 1st October 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.5
#
#     Revision    : CXP 903 6539-1-6
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-26875
#
#     Description : Setting euft,swltid attribute in instantaneousLicensing MO for RadioNodes in 5G.
#
#     Date        : 05th Sept 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.4
#
#     Revision    : CXP 903 6539-1-4
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-26787
#
#     Description : Setting availabilityStatus attribute in instantaneousLicensing MO for RadioNodes in 5G.
#
#     Date        : 22nd Aug 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24906
#
#     Description : Updating outputDirectory attribute MO for RadioNodes in 5G.
#
#     Date        : 27th May 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.2
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24526
#
#     Description : Setting userLabel attribute in SysM MO for 5GRadioNodes.
#
#     Date        : 23rd April 2019
#
####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Set ProductData
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
local $date=`date`,$pdkdate=`date '+%FT%T'`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$NODENUM=0,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
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
# Make MO & MML Scripts
################################
while ($NODECOUNT<=$DG2NUMOFRBS){

    $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
    $MIMVERSION=&queryMIM($SIMNAME,$NODECOUNT);
    $MIMVERSION = "MSRBS-V2-".$MIMVERSION;
    $ProductDatafile="ProductData.env";
    $ProductData=&getENVfilevalue($ProductDatafile,"$MIMVERSION");
    @productData = split( /:/, $ProductData );
    $productNumber=$productData[0];
    $productRevision=$productData[1];
    chomp $pdkdate;
    $NODENUM=((($LTE - 1) * $DG2NUMOFRBS) + $NODECOUNT);
    #Check for Product Data information
    if (($productNumber eq "ERROR")||($productRevision eq "")) {#start if
       print "ERROR : Product data information missing, the script will exit\n\n";
       exit;
       }#end if

	# build mml script
	@MOCmds=();
	@MOCmds=qq^ SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSwIM:SwInventory=1,RcsSwIM:SwItem=1"
    exception none
    nrOfAttributes 1
    "administrativeData" Struct
        nrOfElements 6
        "productName" String "$productNumber\_$productRevision"
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productionDate" String "2017-11-29T09:32:56"
        "description" String "RadioNode"
        "type" String "RadioNode"

)

SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSwIM:SwInventory=1,RcsSwIM:SwVersion=1"
    exception none
    nrOfAttributes 1
    "administrativeData" Struct
        nrOfElements 6
        "productName" String "$productNumber\_$productRevision"
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productionDate" String "2017-11-29T09:32:56"
        "description" String "RadioNode"
        "type" String "RadioNode"

)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSwM:SwM=1,RcsSwM:UpgradePackage=1"
    exception none
    nrOfAttributes 1
    "administrativeData" Array Struct 1
        nrOfElements 6
        "productName" String "$productNumber\_$productRevision"
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productionDate" String "2017-11-29T09:32:56"
        "description" String "RadioNode"
        "type" String "RadioNode"

)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1"
    exception none
    nrOfAttributes 1
    "userLabel" String "value"
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,RmeSupport:NodeSupport=1,RmeLicenseSupport:LicenseSupport=1,RmeLicenseSupport:InstantaneousLicensing=1"
    exception none
    nrOfAttributes 3
    "swltId" String "19DZ725311F4595D22D12666"
    "euft" String "949525"
    "availabilityStatus" Array Integer 1
         3
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:SecurityHandling
    exception none
    nrOfAttributes 3
    "cipheringAlgoPrio" Array Integer 3
         1
         2
         0
    "integrityProtectAlgoPrio" Array Integer 2
         2
         1
    "securityHandlingId" String "1"
)
^;
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	if ($nodeVersion < 2244) {
	@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:QciProfileEndcConfigExt
    exception none
    nrOfAttributes 6
    "initialUplinkConf" Integer 0
    "qciProfileEndcConfigExtId" String "1"
    "rlcModeQciUM" Array Int32 0
    "tReorderingDlPdcp" Int32 200
    "tReorderingUlDiscardPdcp" Int32 200
    "tReorderingUlPdcp" Int32 10
)
^;
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	}
	else {
	@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:QciProfileEndcConfigExt
    exception none
    nrOfAttributes 5
    "initialUplinkConf" Integer 0
    "qciProfileEndcConfigExtId" String "1"
)
^;
	$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	}
	@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME"
    identity "1"
    moType GNBCUUP:GNBCUUPFunction
    exception none
    nrOfAttributes 1
    "gNBCUUPFunctionId" String "1"
    "pLMNIdList" Array Struct 3
        nrOfElements 2
        "mcc" String "128"
        "mnc" String "49"

        nrOfElements 2
        "mcc" String "129"
        "mnc" String "50"

        nrOfElements 2
        "mcc" String "130"
        "mnc" String "51"
    "gNBCUUPFunctionId" String "1"
    "gNBId" Int64 $NODENUM
    "gNBIdLength" Int32 22


)

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
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
^;# end @MO
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        if( $nodeVersion < 2422 ) {          
        @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:RpUserPlaneTermination
    exception none
    nrOfAttributes 1
    "rpUserPlaneTerminationId" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:RpUserPlaneTermination=1"
    identity "1"
    moType GNBDU:RpUserPlaneLink
    exception none
    nrOfAttributes 3
    "localEndPoint" String "null"
    "remoteEndPoint" String "null"
    "rpUserPlaneLinkId" String "1"
)
^;# end @MO
       $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
       }
       @MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:RadioBearerTable
    exception none
    nrOfAttributes 1
    "radioBearerTableId" String "1"
)
^;
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        if ($nodeVersion < 2244) {
        @MOCmds=qq^

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1,GNBDU:RadioBearerTable=1"
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
^;
        $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
        }
        @MOCmds=qq^

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBDU:GNBDUFunction=1"
    identity "1"
    moType GNBDU:Paging
    exception none
    nrOfAttributes 4
    "defaultPagingCycle" Int32 128
    "n" Integer 0
    "nS" Int32 1
    "pagingId" String "1"
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$LTENAME,SystemFunctions=1,PmEventM=1,EventProducer=CUCP,EventGroup=CCTR
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$LTENAME,SystemFunctions=1,PmEventM=1,EventProducer=CUUP,EventGroup=CCTR
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$LTENAME,SystemFunctions=1,PmEventM=1,EventProducer=DU,EventGroup=CCTR
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUCP,RcsPMEventM:FilePullCapabilities=2"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/pm_data_CUCP/"
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=CUUP,RcsPMEventM:FilePullCapabilities=2"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/pm_data_CUUP/"
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=DU,RcsPMEventM:FilePullCapabilities=2"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/pm_data_DU/"
)
   ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

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
