#!/usr/bin/perl
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Create Log
#
#     Date         : March 2019
#
####################################################################################

####################
use FindBin qw($Bin);
use lib "$Bin/../../lib/cellconfig";
use Cwd;
use LTE_General;
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
local $date=`date`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
###################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
    unlink "$NETSIMMOSCRIPT";}
################################
# MAIN
################################
print "... ${0} started running at $date\n";
################################
# Make MO & MML Scripts
################################

while ($NODECOUNT<=$DG2NUMOFRBS){
# get node name
$LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);

@MOCmds=qq^

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity AiLog
exception none
nrOfAttributes 1
"logId" String "AiLog"
)

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity HcLog
exception none
nrOfAttributes 1
"logId" String "HcLog"
)
CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity HealthCheckLog
exception none
nrOfAttributes 1
"logId" String "HealthCheckLog"
)
CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity AlarmLog
exception none
nrOfAttributes 1
"logId" String "AlarmLog"
)

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity AuditTrailLog
exception none
nrOfAttributes 1
"logId" String "AuditTrailLog"
 )

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity SecurityLog
exception none
nrOfAttributes 1
"logId" String "SecurityLog"
)

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity SwmLog
exception none
nrOfAttributes 1
"logId" String "SwmLog"
)

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity TnApplicationLog
exception none
nrOfAttributes 1
"logId" String "TnApplicationLog"
)

CREATE
(
parent "ManagedElement=$LTENAME,SystemFunctions=1,LogM=1"
moType RcsLogM:Log
identity TnNetworkLog
exception none
nrOfAttributes 1
"logId" String "TnNetworkLog"
)

^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

################################
# build MML script
################################
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
