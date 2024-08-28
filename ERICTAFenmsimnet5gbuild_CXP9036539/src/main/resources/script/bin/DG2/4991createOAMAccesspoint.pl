#!/usr/bin/perl
#VERSION HISTORY
####################################################################
####################################################################
# Version1    : LTE 19.17
# Revision    : CXP 903 6539-1-10
# Purpose     : creates OAMAccesspoint MO in 5G LTE nodes
# Description : creates IPV4Address MO and IPV6Address MO on
#               the 90:10 of the network
#               80:20 of the network in RV
# Jira        : NSS-27634
# Date        : OCT 31st 2019
# Who         : zyamkan
####################################################################
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
local $SIMNAME=$ARGV[0],$ENV=$ARGV[1],$LTE=$ARGV[2];
# start verify params and sim node type
local @helpinfo=qq(Usage  : ${0} <sim name> <env file> <sim num>
Example: $0  LTEE119-V2x160-RV-FDD-LTE10 CONFIG.env 10);
if (!( @ARGV==3)){
   print "@helpinfo\n";exit(1);}
# check if SIMNAME is of type DG2
if(&isSimDG2($SIMNAME)=~m/NO/){exit;}
# end verify params and sim node type
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
local @NETSIMMOSCRIPTS=();
local $SwitchToRV=&getENVfilevalue($ENV,"SWITCHTORV");
print "***$SwitchToRV****\n";
local $DG2RBSCOUNT;
if($SwitchToRV=~m/NO/){
if($DG2NUMOFRBS%2==0){
$DG2RBSCOUNT=($DG2NUMOFRBS*90)/100;
}
else{
$DG2RBSCOUNT=(($DG2NUMOFRBS*90)/100)-0.5;
}
}
else{
$DG2RBSCOUNT=($DG2NUMOFRBS*80)/100;
}
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
print "MAKING MML SCRIPT\n";

while ($NODECOUNT<=$DG2RBSCOUNT){
  # get node name
  $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
 
    @MOCmds=();
    @MOCmds=qq( CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:Transport=1"
    identity "OAM"
    moType RtnL3Router:Router
    exception none
    nrOfAttributes 1
    "routerId" String "OAM"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:Transport=1,RtnL3Router:Router=OAM"
    identity "1"
    moType RtnL3InterfaceIPv4:InterfaceIPv4
    exception none
    nrOfAttributes 1
    "interfaceIPv4Id" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:Transport=1,RtnL3Router:Router=OAM,RtnL3InterfaceIPv4:InterfaceIPv4=1"
    identity "1"
    moType RtnL3InterfaceIPv4:AddressIPv4
    exception none
    nrOfAttributes 1
    "addressIPv4Id" String "1"
));#end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

   # build mml script
  @MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds

  $NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

  $NODECOUNT++;
}# end first while condition
$DG2RBSCOUNT++;
while ($DG2RBSCOUNT<=$DG2NUMOFRBS) {
  # get node name
  $LTENAME=&getLTESimStringNodeName($LTE,$DG2RBSCOUNT);
 
    @MOCmds=();
    @MOCmds=qq( CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:Transport=1"
    identity "OAM"
    moType RtnL3Router:Router
    exception none
    nrOfAttributes 1
    "routerId" String "OAM"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:Transport=1,RtnL3Router:Router=OAM"
    identity "1"
    moType RtnL3InterfaceIPv6:InterfaceIPv6
    exception none
    nrOfAttributes 1
    "interfaceIPv6Id" String "1"
)
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:Transport=1,RtnL3Router:Router=OAM,RtnL3InterfaceIPv6:InterfaceIPv6=1"
    identity "1"
    moType RtnL3InterfaceIPv6:AddressIPv6
    exception none
    nrOfAttributes 1
    "addressIPv6Id" String "1"
));#end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$DG2RBSCOUNT,@MOCmds);
    push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

   # build mml script
  @MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds

  $NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

  $DG2RBSCOUNT++;
}# end second while condition
#execute mml script
  @netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

  # output mml script execution
  print "@netsim_output\n";

################################
# CLEANUP
################################
$date=`date`;
# remove mo scripts
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
print "... ${0} ended running at $date\n";
################################
# END
################################
