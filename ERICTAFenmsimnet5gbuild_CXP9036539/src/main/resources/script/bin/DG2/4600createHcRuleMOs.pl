#!/usr/bin/perl
#####################################################################################
#     Version      :1.3
#
#     Revision     : CXP 903 6539-1-45
#
#     Author       : J Saivikas 
#
#     JIRA         : NSS-38167
#
#     Description  : Removing HcRules for HcRule and HcRuleSuccess count matching 
#
#     Date         : 4th Jan 2022
#
#####################################################################################
#####################################################################################     
#     Version      : 1.2
#
#     Revision    : CXP 903 6539-1-38
#
#     Author       : Vinay Baratam
#
#     JIRA         : NSS-37474
#
#     Description  : Set some attributes on HcRules
#
#     Date         : 12th Nov 2021
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
#     Description  : Set HcRules
#
#     Date         : March 2019
#
####################################################################################

####################
use FindBin qw($Bin);
use lib "$Bin/../../lib/cellconfig";
use Cwd;
use LTE_CellConfiguration;
use LTE_General;
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
# Make MO & MML Scripts
################################

while ($NODECOUNT<=$DG2NUMOFRBS){# start outer while

# get node name
  $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT,$SIMNAME);

	@MOCmds=();
	@MOCmds=qq^
CREATE
(	
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHcm:HealthCheckM=1"
    identity "GNBCUCPFunction_CheckX2LinkStatus"
    moType RcsHcm:HcRule
    exception none
    nrOfAttributes 9
    "severity" Integer 1
    "ruleType" Struct
        nrOfElements 3
        "subTypeDescription" String ""
        "typeName" String ""
        "subTypeName" String "Transport Status"

    "recommendedAction" String "Check availabilityStatus attribute for more details and observe Alarms for failure indication. Resolve the problem that caused the resource to be inoperable. Remote actions: 1.Check the configuration of the TermPointToENodeB MO instance. For information on configuration, see Manage Radio Network and X2 Configuration. 2.Perform a ping command towards affected eNodeB. Check for available MO Router and MO NextHop (address) on NearEnd and MO AddressIPv4 (address) or MO AddressIPv6 (address) on FarEnd. Based on it create a ping command to next hop, then to FarEnd. Example: mcc router=traffic ping --count 3 --packetsize 1000 x.x.x.x. In case of unsuccessful ping, check if the node configuration matches the required IP design. Contact the transmission department to check the availability of IP network. 3.Lock and unlock the TermPointToENodeB MO instance. 4.Check status of the connection in the related eNodeB or gNodeB node. On-site actions: 1.Validate cabling and port connectivity for X2 transport connection."
    "name" String "Check X2 Link Status in GNodeB"
    "inputParameters" Array Struct 2
        nrOfElements 3
        "name" String "inclusion"
        "value" String "INCLUDED"
        "description" String ""

        nrOfElements 3
        "name" String "severity"
        "value" String "WARNING"
        "description" String ""

    "hcRuleId" String "GNBCUCPFunction_CheckX2LinkStatus"
    "description" String "Check the status of termination point to eNodeB"
    "categoryList" Array Struct 6
        nrOfElements 2
        "category" String "SITE_ACCEPTANCE"
        "description" String "Indicates that the rule should be executed for site acceptance."

        nrOfElements 2
        "category" String "PREUPGRADE"
        "description" String "Indicates that the rule should be executed before an upgrade."

        nrOfElements 2
        "category" String "PREINSTALL"
        "description" String "Indicates that the rule should be executed before an installation."

        nrOfElements 2
        "category" String "POSTUPGRADE"
        "description" String "Indicates that the rule should be executed after an upgrade."

        nrOfElements 2
        "category" String "EXPANSION"
        "description" String "Indicates that the rule should be executed for expansion"

        nrOfElements 2
        "category" String "ALL"
        "description" String "Includes all the rules provided by the node."

    "categories" Array Integer 4
         4
         7
         5
         10
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHcm:HealthCheckM=1"
    identity "GNBCUCPFunction_CheckNrTraffic"
    moType RcsHcm:HcRule
    exception none
    nrOfAttributes 9
    "severity" Integer 1
    "ruleType" Struct
        nrOfElements 3
        "subTypeDescription" String ""
        "typeName" String ""
        "subTypeName" String "Cell Traffic"

    "recommendedAction" String "Remote actions: 1.Observe Alarms for failure indication, resolve the problem according to remedy action for specific alarm. 2.Observe cell performance. If there are no connected users, it can indicate a sleeping cell. 3.Check the configuration of the cells. For information on configuration, see Manage Radio Network. 4.Lock and unlock cells. On-site actions: 1.If possible, make a NR test call."
    "name" String "Check NR traffic"
    "inputParameters" Array Struct 2
        nrOfElements 3
        "name" String "inclusion"
        "value" String "INCLUDED"
        "description" String ""

        nrOfElements 3
        "name" String "severity"
        "value" String "WARNING"
        "description" String ""

    "hcRuleId" String "GNBCUCPFunction_CheckNrTraffic"
    "description" String "Check for the users connected to the sectors (or cells) and the bearers that are up"
    "categoryList" Array Struct 6
        nrOfElements 2
        "category" String "SITE_ACCEPTANCE"
        "description" String "Indicates that the rule should be executed for site acceptance."

        nrOfElements 2
        "category" String "PREUPGRADE"
        "description" String "Indicates that the rule should be executed before an upgrade."

        nrOfElements 2
        "category" String "PREINSTALL"
        "description" String "Indicates that the rule should be executed before an installation."

        nrOfElements 2
        "category" String "POSTUPGRADE"
        "description" String "Indicates that the rule should be executed after an upgrade."

        nrOfElements 2
        "category" String "EXPANSION"
        "description" String "Indicates that the rule should be executed for expansion"

        nrOfElements 2
        "category" String "ALL"
        "description" String "Includes all the rules provided by the node."

    "categories" Array Integer 4
         4
         7
         5
         10
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHcm:HealthCheckM=1"
    identity "GNBCUCPFunction_CheckNgLinkStatus"
    moType RcsHcm:HcRule
    exception none
    nrOfAttributes 9
    "severity" Integer 1
    "ruleType" Struct
        nrOfElements 3
        "subTypeDescription" String ""
        "typeName" String ""
        "subTypeName" String "Transport Status"

    "recommendedAction" String "Check availabilityStatus attribute for more details and observe Alarms for failure indication. Resolve the problem that caused the resource to be inoperable. Remote actions: 1.Check the configuration of the TermPointToAmf MO instance. For information on configuration, see Manage Radio Network. 2.Perform a ping command towards affected AMF. Check for available MO Router and MO NextHop (address) and MO TermPointToAmf (ipv4Address1 or ipv4Address2 and ipv6Address1 or ipv6Address2). Based on it create a ping command to next hop, then to AMF. Example: mcc router=traffic ping --count 3 --packetsize 1000 x.x.x.x. In case of unsuccessful ping, check if the node configuration matches the required IP design. Contact the transmission department to check the availability of IP network. 3.Lock and unlock the TermPointToAmf MO instance. On-site actions: 1.Validate cabling and port connectivity for AMF transport connection."
    "name" String "Check Ng Link Status"
    "inputParameters" Array Struct 2
        nrOfElements 3
        "name" String "inclusion"
        "value" String "INCLUDED"
        "description" String ""

        nrOfElements 3
        "name" String "severity"
        "value" String "WARNING"
        "description" String ""

    "hcRuleId" String "GNBCUCPFunction_CheckNgLinkStatus"
    "description" String "Check the status of termination point to AMF"
    "categoryList" Array Struct 6
        nrOfElements 2
        "category" String "SITE_ACCEPTANCE"
        "description" String "Indicates that the rule should be executed for site acceptance."

        nrOfElements 2
        "category" String "PREUPGRADE"
        "description" String "Indicates that the rule should be executed before an upgrade."

        nrOfElements 2
        "category" String "PREINSTALL"
        "description" String "Indicates that the rule should be executed before an installation."

        nrOfElements 2
        "category" String "POSTUPGRADE"
        "description" String "Indicates that the rule should be executed after an upgrade."

        nrOfElements 2
        "category" String "EXPANSION"
        "description" String "Indicates that the rule should be executed for expansion"

        nrOfElements 2
        "category" String "ALL"
        "description" String "Includes all the rules provided by the node."

    "categories" Array Integer 4
         4
         7
         5
         10
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHcm:HealthCheckM=1"
    identity "GNBCUCPFunction_CheckXnLinkStatus"
    moType RcsHcm:HcRule
    exception none
    nrOfAttributes 9
    "severity" Integer 1
    "ruleType" Struct
        nrOfElements 3
        "subTypeDescription" String ""
        "typeName" String ""
        "subTypeName" String "Transport Status"

    "recommendedAction" String "Check availabilityStatus attribute for more details and observe Alarms for failure indication. Resolve the problem that caused the resource to be inoperable. Remote actions: 1.Check the configuration of the TermPointToGNodeB MO instance. For information on configuration, see Manage Radio Network and Xn Configuration. 2.Perform a ping command towards affected gNodeB. Check for available MO Router and MO NextHop (address) on NearEnd and MO AddressIPv4 (address) or MO AddressIPv6 (address) on FarEnd. Based on it create a ping command to next hop, then to FarEnd. Example: mcc router=traffic ping --count 3 --packetsize 1000 x.x.x.x. In case of unsuccessful ping, check if the node configuration matches the required IP design. Contact the transmission department to check the availability of IP network. 3.Lock and unlock the TermPointToGNodeB MO instance. On-site actions: 1.Validate cabling and port connectivity for Xn transport connection."
    "name" String "Check Xn Link Status"	
    "inputParameters" Array Struct 2
        nrOfElements 3
        "name" String "inclusion"
        "value" String "INCLUDED"
        "description" String ""

        nrOfElements 3
        "name" String "severity"
        "value" String "WARNING"
        "description" String ""

    "hcRuleId" String "GNBCUCPFunction_CheckXnLinkStatus"
    "description" String "Check the status of termination point to GNodeB"
    "categoryList" Array Struct 6
        nrOfElements 2
        "category" String "SITE_ACCEPTANCE"
        "description" String "Indicates that the rule should be executed for site acceptance."

        nrOfElements 2
        "category" String "PREUPGRADE"
        "description" String "Indicates that the rule should be executed before an upgrade."

        nrOfElements 2
        "category" String "PREINSTALL"
        "description" String "Indicates that the rule should be executed before an installation."

        nrOfElements 2
        "category" String "POSTUPGRADE"
        "description" String "Indicates that the rule should be executed after an upgrade."

        nrOfElements 2
        "category" String "EXPANSION"
        "description" String "Indicates that the rule should be executed for expansion"

        nrOfElements 2
        "category" String "ALL"
        "description" String "Includes all the rules provided by the node."

    "categories" Array Integer 4
         4
         7
         5
         10
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHcm:HealthCheckM=1"
    identity "GNBCUCPFunction_CheckNRCllCUStatus"
    moType RcsHcm:HcRule
    exception none
    nrOfAttributes 9
    "severity" Integer 1
    "ruleType" Struct
        nrOfElements 3
        "subTypeDescription" String ""
        "typeName" String ""
        "subTypeName" String "Cell Status"

    "recommendedAction" String "Check availabilityStatus attribute of the related NRCellDU MO instance and observe Alarms for failure indication. Resolve the problem that caused the resource to be inoperable. Remote actions: 1.Check the configuration of the NRCellCU MO instance and related NRCellDU MO instance. For information on configuration, see Manage Radio Network. 2.Lock and unlock the related NRCellDU MO instance."
    "name" String "Check NRCellCU Status"
    "inputParameters" Array Struct 2
        nrOfElements 3
        "name" String "inclusion"
        "value" String "INCLUDED"
        "description" String ""

        nrOfElements 3
        "name" String "severity"
        "value" String "WARNING"
        "description" String ""

    "hcRuleId" String "GNBCUCPFunction_CheckNRCllCUStatus"
    "description" String "Check the status of the NR cell represented in CUCP"
    "categoryList" Array Struct 6
        nrOfElements 2
        "category" String "SITE_ACCEPTANCE"
        "description" String "Indicates that the rule should be executed for site acceptance."

        nrOfElements 2
        "category" String "PREUPGRADE"
        "description" String "Indicates that the rule should be executed before an upgrade."

        nrOfElements 2
        "category" String "PREINSTALL"
        "description" String "Indicates that the rule should be executed before an installation."

        nrOfElements 2
        "category" String "POSTUPGRADE"
        "description" String "Indicates that the rule should be executed after an upgrade."

        nrOfElements 2
        "category" String "EXPANSION"
        "description" String "Indicates that the rule should be executed for expansion"

        nrOfElements 2
        "category" String "ALL"
        "description" String "Includes all the rules provided by the node."

    "categories" Array Integer 4
         4
         7
         5
         10
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHcm:HealthCheckM=1"
    identity "GNBDUFunction_CheckNRCllDUStatus"
    moType RcsHcm:HcRule
    exception none
    nrOfAttributes 9
    "severity" Integer 1
    "ruleType" Struct
        nrOfElements 3
        "subTypeDescription" String ""
        "typeName" String ""
        "subTypeName" String "Cell Status"

    "recommendedAction" String "Check availabilityStatus attribute for more details and observe Alarms for failure indication. Resolve the problem that caused the resource to be inoperable. Remote actions: 1.Check the configuration of the NRCellDU MO instance. For information on configuration, see Manage Radio Network. 2.Lock and unlock the NRCellDU MO instance."
    "name" String "Check NRCellDU Status"
    "inputParameters" Array Struct 2
        nrOfElements 3
        "name" String "inclusion"
        "value" String "INCLUDED"
        "description" String ""

        nrOfElements 3
        "name" String "severity"
        "value" String "WARNING"
        "description" String ""

    "hcRuleId" String "GNBDUFunction_CheckNRCllDUStatus"
    "description" String "Check the status of NR cell represented in DU"
    "categoryList" Array Struct 6
        nrOfElements 2
        "category" String "SITE_ACCEPTANCE"
        "description" String "Indicates that the rule should be executed for site acceptance."

        nrOfElements 2
        "category" String "PREUPGRADE"
        "description" String "Indicates that the rule should be executed before an upgrade."

        nrOfElements 2
        "category" String "PREINSTALL"
        "description" String "Indicates that the rule should be executed before an installation."

        nrOfElements 2
        "category" String "POSTUPGRADE"
        "description" String "Indicates that the rule should be executed after an upgrade."

        nrOfElements 2
        "category" String "EXPANSION"
        "description" String "Indicates that the rule should be executed for expansion"

        nrOfElements 2
        "category" String "ALL"
        "description" String "Includes all the rules provided by the node."

    "categories" Array Integer 4
         4
         7
         5
         10
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
