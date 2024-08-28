#!/usr/bin/perl
#####################################################################################
#     Version      : 1.1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Set DG2 Cipher
#
#     Date         : March 2019
#
####################################################################################
#####################################################################################
#     Version      : 1.2
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NSS-24646
#
#     Description  : Adding new DG2 Ciphers
#
#     Date         : 03rd May, 2019
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
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
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

while ($NODECOUNT<=$DG2NUMOFRBS){

    $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
    $MIMVERSION=&queryMIM($SIMNAME,$NODECOUNT);

# build mml script
        @MOCmds=();
        @MOCmds=qq^ SET
(
    mo "ManagedElement=$LTENAME,SystemFunctions=1,SecM=1,Tls=1"
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
    mo "ManagedElement=$LTENAME,SystemFunctions=1,SecM=1,Ssh=1"
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


################################################
# build mml script
################################################
  @MMLCmds=(".open ".$SIMNAME,
            ".select ".$LTENAME,
            ".start ",
            "useattributecharacteristics:switch=\"off\"; ",
            "kertayle:file=\"$NETSIMMOSCRIPT\";",
            ".sleep 7"
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


