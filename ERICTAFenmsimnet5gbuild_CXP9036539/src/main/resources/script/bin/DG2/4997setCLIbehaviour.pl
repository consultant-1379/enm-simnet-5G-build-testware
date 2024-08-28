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
#     Description  : Set CLI Behaviour
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
if (&isSimPICO($SIMNAME)=~m/NO/ && &isSimDG2($SIMNAME)=~m/NO/)
{exit;}
# end verify params and sim node type
#----------------------------------------------------------------
local $date=`date`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $setCLI="setnodecomversion:version=\"COM5.1\";";

print "... ${0} started running at $date\n";

# build mml script
@MMLCmds=(".open ".${SIMNAME},
          ".select network",
          ".start ",
           $setCLI

);# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

# output mml script execution
print "@netsim_output\n";

################################
# CLEANUP
################################
$date=`date`;
# remove mo script
unlink "$NETSIMMMLSCRIPT";
#------------------------------------------
print "... ${0} ended running at $date\n";
################################
# END
################################
