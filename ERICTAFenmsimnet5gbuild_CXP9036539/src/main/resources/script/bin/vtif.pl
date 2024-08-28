#!/usr/bin/perl


### VERSION HISTORY
#####################################################################################
##     Version     : 1.5
##
##     Revision    : CXP 903 6539-1-17
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-29323
##
##     Description : Adding ciphers support and Ldap=1 MO for VTIF node.
##
##     Date        : 26th Feb 2020
##
#####################################################################################
#####################################################################################
##     Version     : 1.4
##
##     Revision    : CXP 903 6539-1-16
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-28970
##
##     Description : Setting vnfIdentity attribute for VTIF node.
##
##     Date        : 05th Feb 2020
##
#####################################################################################
#####################################################################################
#     Version     : 1.3
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
#     Version     : 1.2
#
#     Revision    : CXP 903 6539-1-1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-22720
#
#     Description : Adding Netlog Support(EsiLog & AvailabilityLog) for vTIF nodes.
#
#     Date        : 1st Jan 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-21827
#
#     Description : Required features for vTIF nodes.
#
#     Date        : 15th Nov 2018
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
$LOGFILE=$LOGFILE."${SIMNAME}.log";
print "$scriptpath  ------------ $LOGFILE \n";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
print "SIMNUM is $SIMNUM\n";
print "NETYPE is $NETYPE\n";
print "NODENAME is $NODENAME\n";
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
  CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity EsiLog
 exception none
 nrOfAttributes 1
 "logId" String "EsiLog"
 )
 CREATE
 (
 parent "ManagedElement=$nodeName,SystemFunctions=1,LogM=1"
 moType RcsLogM:Log
 identity AvailabilityLog
 exception none
 nrOfAttributes 1
 "logId" String "AvailabilityLog"
 )
 SET
 (
 mo "ComTop:ManagedElement=$nodeName,RmeSupport:NodeSupport=1,RmeExeR:ExecutionResource=1"
 exception none
 nrOfAttributes 1
 "vnfIdentity" String "49282996-ffff-11e6-a47e-fa163e1fee7c"
 )
 CREATE
 (
    parent "ManagedElement=$nodeName,SystemFunctions=1,SecM=1,UserManagement=1,LdapAuthenticationMethod=1"
    identity "1"
    moType Ldap
    exception none
    nrOfAttributes 1
    "ldapId" String "1"
 )
 SET
 (
    mo "ManagedElement=$nodeName,SystemFunctions=1,SecM=1,Tls=1"
    exception none
    nrOfAttributes 2
    "supportedCiphers" Array Struct 49
        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-RSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDHE-RSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-RSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-DSS-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-RSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-RSA-AES256-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-DSS-AES256-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-RSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-DSS-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-RSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-ECDSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDH-RSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDH-ECDSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-RSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-ECDSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "AES256-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-RSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDHE-RSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-RSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-DSS-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-RSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-RSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-DSS-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-RSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-DSS-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-RSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-ECDSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDH-RSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDH-ECDSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-RSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-ECDSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-RSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-ECDSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "EDH-RSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "EDH-DSS-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-RSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-ECDSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DES-CBC3-SHA"

    "enabledCiphers" Array Struct 49
        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-RSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDHE-RSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-RSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-DSS-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-RSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-RSA-AES256-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-DSS-AES256-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-RSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-DSS-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-RSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-ECDSA-AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDH-RSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA384"
        "export" String ""
        "name" String "ECDH-ECDSA-AES256-SHA384"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-RSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-ECDSA-AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "AES256-GCM-SHA384"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "AES256-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "AES256-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-RSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-ECDSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "EDH-RSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "EDH-DSS-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-RSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-ECDSA-DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "3DES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DES-CBC3-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-RSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDHE-RSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-RSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH"
        "authentication" String "aECDSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDHE-ECDSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-DSS-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "DHE-RSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-RSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "DHE-DSS-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-RSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kDH"
        "authentication" String "aDSS"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "DHE-DSS-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-RSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "ECDH-ECDSA-AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDH-RSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "ECDH-ECDSA-AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/RSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-RSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kECDH/ECDSA"
        "authentication" String "aECDH"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "ECDH-ECDSA-AES128-SHA"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AESGCM"
        "mac" String "AEAD"
        "export" String ""
        "name" String "AES128-GCM-SHA256"

        nrOfElements 7
        "protocolVersion" String "TLSv1.2"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA256"
        "export" String ""
        "name" String "AES128-SHA256"

        nrOfElements 7
        "protocolVersion" String "SSLv3"
        "keyExchange" String "kRSA"
        "authentication" String "aRSA"
        "encryption" String "AES"
        "mac" String "SHA1"
        "export" String ""
        "name" String "AES128-SHA"

 )
 SET
 (
    mo "ManagedElement=$nodeName,SystemFunctions=1,SecM=1,Ssh=1"
    exception none
    nrOfAttributes 6
    "supportedKeyExchanges" Array String 10
        ecdh-sha2-nistp384
        ecdh-sha2-nistp521
        ecdh-sha2-nistp256
        diffie-hellman-group-exchange-sha256
        diffie-hellman-group16-sha512
        diffie-hellman-group18-sha512
        diffie-hellman-group14-sha256
        diffie-hellman-group14-sha1
        diffie-hellman-group-exchange-sha1
        diffie-hellman-group1-sha1
    "supportedCiphers" Array String 9
        aes256-gcm\@openssh.com
        aes256-ctr
        aes192-ctr
        aes128-gcm\@openssh.com
        aes128-ctr
        AEAD_AES_256_GCM
        AEAD_AES_128_GCM
        aes128-cbc
        3des-cbc
    "supportedMacs" Array String 5
        hmac-sha2-256
        hmac-sha2-512
        hmac-sha1
        AEAD_AES_128_GCM
        AEAD_AES_256_GCM
    "selectedKeyExchanges" Array String 10
        ecdh-sha2-nistp384
        ecdh-sha2-nistp521
        ecdh-sha2-nistp256
        diffie-hellman-group-exchange-sha256
        diffie-hellman-group16-sha512
        diffie-hellman-group18-sha512
        diffie-hellman-group14-sha256
        diffie-hellman-group14-sha1
        diffie-hellman-group-exchange-sha1
        diffie-hellman-group1-sha1
    "selectedCiphers" Array String 9
        aes256-gcm\@openssh.com
        aes256-ctr
        aes192-ctr
        aes128-gcm\@openssh.com
        aes128-ctr
        AEAD_AES_256_GCM
        AEAD_AES_128_GCM
        aes128-cbc
        3des-cbc
    "selectedMacs" Array String 5
        hmac-sha2-256
        hmac-sha2-512
        hmac-sha1
        AEAD_AES_128_GCM
        AEAD_AES_256_GCM
  )
   ^;# end @MO


   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);


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
