#!/usr/bin/perl
#####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-10
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NSS-27634
#
#     Description  : Rectifying Script for odd number of nodes while building
#
#     Date         : Oct 30th 2019
#
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Create optional Features
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
local $DG2RBSCOUNT;
if($DG2NUMOFRBS%2==0){
$DG2RBSCOUNT=$DG2NUMOFRBS/2;
}
else
{
$DG2RBSCOUNT=($DG2NUMOFRBS+1)/2;
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
    parent "ManagedElement=$LTENAME,SystemFunctions=1,Lm=1"
    identity CXC4011378_2
    moType FeatureKey
    exception none
    nrOfAttributes 1
    "keyId" String "CXC4011378"
));#end @MO FeatureKey
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
    push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

   # build mml script
  @MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds

    @MOCmds=qq( CREATE
(
      parent "ManagedElement=$LTENAME,SystemFunctions=1,Lm=1"
    identity CellSoftLock
    moType RcsLM:FeatureState
    exception none
    nrOfAttributes 7
    "featureStateId" String "CXC4011378"
    "featureState" Integer 1
    "licenseState" Integer 1
    "serviceState" Integer 1
    "description" String ""
    "featureKey" Array Ref "ManagedElement=$LTENAME,SystemFunctions=1,Lm=1,FeatureKey=CXC4011378_2"
    "keyId" String "CXC4011378"
)
);# end @MO

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
    parent "ManagedElement=$LTENAME,SystemFunctions=1,Lm=1"
    identity CXC
    moType FeatureKey
    exception none
    nrOfAttributes 1
    "keyId" String "CXC"
));#end @MO FeatureKey
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$DG2RBSCOUNT,@MOCmds);
    push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

   # build mml script
  @MMLCmds=(".open ".$SIMNAME,
          ".select ".$LTENAME,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
          "kertayle:file=\"$NETSIMMOSCRIPT\";"
  );# end @MMLCmds

    @MOCmds=qq( CREATE
(
    parent "ManagedElement=$LTENAME,SystemFunctions=1,Lm=1" 
    identity NonCellSoftLock
    moType RcsLM:FeatureState
    exception none
    nrOfAttributes 7
    "featureStateId" String "CXC"
    "featureState" Integer 0
    "licenseState" Integer 0
    "serviceState" Integer 0
    "description" String ""
    "featureKey" Array Ref "ManagedElement=$LTENAME,SystemFunctions=1,Lm=1,FeatureKey=CXC" 
    "keyId" String "CXC"
));# end @MO
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

