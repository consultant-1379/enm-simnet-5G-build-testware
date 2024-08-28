#!/usr/bin/perl

########################################################################################
## Version1    : 20.08
## Revision    : CXP 903 6539-1-20
## Purpose     : clone the base node instead of creating
## Description : Adding Pm Unit Test before continue to the entire build
## JIRA        : NSS-29548
## Date        : 23rd Apr 2020
## Author      : zyamkan
########################################################################################
####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Cwd;
use v5.10;
use General;
################################
# Usage
################################
local @helpinfo=qq(
ERROR : need to pass 1 parameter to ${0}

Usage : ${0} <simulation name>

Example1 : ${0} LTE17B-V1x2-FT-vSD-SNMP-LTE01

Example2 : ${0} LTE17B-V1x5-FT-vSD-TLS-LTE01

); # end helpinfo

################################
# Vars
################################
local $netsimserver=`hostname`;
local $username=`/usr/bin/whoami`;
$username=~s/^\s+//;$username=~s/\s+$//;
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local @netsim_output=();
local $dir=cwd;
local $currentdir=$dir."/";
local $scriptpath="$currentdir";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local $SIMNAME=$ARGV[0];
local $SIMNUMBER=substr($SIMNAME, -2);
local $NODECOUNT=1;
local @MMLCmds=();
local $NODENAME;
local $NETSIMMMLSCRIPT;
local @netsim_output=();
local $Path=`pwd`;
local $setPath=`pwd`;
chomp ($setPath);
chomp ($Path);
local $PmLogs=$Path."/../log/Pmlogs.txt";
local $Result=$Path."/Result.txt";
local $msrbslog=$Path."/../log/msrbsip.log";
################################
if ( -e $PmLogs){
    print "...removing old Pm Logs\n";
    unlink "$PmLogs";}
################################
################################
if ( -e $Result){
    print "...removing old Result Txt\n";
    unlink "$Result";}
################################
################################
if ( -e $msrbslog){
    print "...removing old msrbsip logs\n";
    unlink "$msrbslog";}
################################

my $filename = 'Result.txt';

################################
# MAIN
################################
print "$Path";
print "\n############### Checking $SIMNAME ##############\n";
###Storing node details of simulation###

my $shell_out = <<`SHELL`;
echo netsim | sudo -S -H -u netsim bash -c 'printf ".open '$SIMNAME' \n .show simnes" | /netsim/inst/netsim_shell | grep -v ">>" | grep -v "OK" | grep -v "NE"' >  NodeData.txt
SHELL

###Storing the nodes in an array###
system ("cut -f1 -d ' ' NodeData.txt > NodeData1.txt");
open(FILE, "<", "NodeData1.txt") or die("Can't open file");
@Nodes = <FILE>;
close(FILE);

##################################################
# Finding number of PMGroups from the MIB file
##################################################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$Nodes[1],
            ".start ",
            "e installation:get_neinfo(pm_mib) ."
  );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);
# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
$netsim_output[7] =~ s/"|{|}|ok|,//g;
chomp ($netsim_output[7]);
my $MibFile= "/netsim/inst/zzzuserinstallation/ecim_pm_mibs/$netsim_output[7]";
open FILE, $MibFile or die "can't open $file: $!\n";
while(<FILE>)
{
    next unless /slot name=\"pmGroupId\"/;

    $NumOfPmGroup++;
}
close FILE;
open FILE1, $MibFile or die "can't open $file: $!\n";
while(<FILE1>)
{
    next unless /hasClass name=\"EventGroup\"/;

    $NumOfEventGroup++;
}
close FILE1;
open FILE2, $MibFile or die "can't open $file: $!\n";
while(<FILE2>)
{
    next unless /hasClass name=\"MeasurementType\"/;

    $NumOfMeasurementType++;
}
close FILE2;
open FILE3, $MibFile or die "can't open $file: $!\n";
while(<FILE3>)
{
    next unless /hasClass name=\"EventType\"/;

    $NumOfEventType++;
}

close FILE3;

open(LOG, ">", $PmLogs) or die "can't ############ open $PmLogs: $!\n";

if ( $NumOfPmGroup == "" )
{
     $NumOfPmGroup=0;
}
if ( $NumOfEventGroup == "" )
{
     $NumOfEventGroup=0;
}
if ( $NumOfMeasurementType == "" )
{
     $NumOfMeasurementType=0;
}
if ( $NumOfEventType == "" )
{
      $NumOfEventType=0;
}

print LOG "\nNumOfPmGroup=$NumOfPmGroup\n";
print LOG "\nNumOfEventGroup=$NumOfEventGroup\n";
print LOG "\nNumOfMeasurementType=$NumOfMeasurementType\n";
print LOG "\nNumOfEventType=$NumOfEventType\n";

if ( $NumOfPmGroup != 0 || $NumOfEventGroup != 0 || $NumOfMeasurementType != 0 || $NumOfEventType != 0 )
{
    open (LOG , '>>' ,$PmLogs) or die "Could not open file '$PmLogs' $! \n";	
}
else
{ 
     open (LOG , '>>' ,$PmLogs) or die "Could not open file '$PmLogs' $! \n";
     print LOG "***********************************************************\n";
     print LOG "This Node version does not have PM support in mib file\n";
     print LOG "So, we are exiting from Pm unit test checking\n";
     print LOG "***********************************************************\n";
     system (" cat $PmLogs ");
     system (" cat $PmLogs >> $Path/Result.txt ");
     close LOG;
     exit 1;
}
chomp ($NumOfEventGroup);
unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();
##################################################
$NameSpacefile="RcsPm";

##################################################
 # ############################################## #
# verify PMGroup
##################################################

foreach $node (@Nodes)
{
    chomp($node);
	@MMLCmds=(".open ".$SIMNAME,
            ".select ".$node,
            ".start ",
            "e length(csmo:get_mo_ids_by_type(null, \"$NameSpacefile:PmGroup\"))."
             );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

open(MAINLOG, ">>", "$setPath/../log/msrbsip.log") or die "can't ############ open LogsFile $setPath/../log/msrbsip.log: $!\n";
print MAINLOG "\n@netsim_output\n";
close (MAINLOG);

open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";

#print "@netsim_output\n";
     if ( $NumOfPmGroup == 0 ) {
        print "\nINFO: PmGroup does not exist for this MIM\n";
     }
     elsif (int($netsim_output[-1]) == $NumOfPmGroup) {
        say $fh "\nINFO :PASSED on $node PMGroup MO count is $netsim_output[-1]\n";
        }
     else {
        say $fh "INFO :FAILED on $node, Check if all the PMGroups are loaded or not, MO count is $netsim_output[-1], It should be $NumOfPmGroup";
        }

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();
	

#####################################################
# verify EventGroup
##########################################################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$node,
            "e length(csmo:get_mo_ids_by_type(null, \"RcsPMEventM:EventGroup\"))."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

open(MAINLOG, ">>", "$setPath/../log/msrbsip.log") or die "can't ############ open LogsFile $setPath/../log/msrbsip.log: $!\n";
print MAINLOG "\n@netsim_output\n";
close (MAINLOG);
if ( $NumOfEventGroup == 0 ) {
        print "\nINFO: EventGroup does not exist for this MIM\n";
}
elsif (int($netsim_output[-1]) == $NumOfEventGroup ) {
        say $fh "\nINFO: PASSED, $node EventGroup MO count is $netsim_output[-1]\n";
}
else {
        say $fh "\nFAILED: Check if all the EventGroups are loaded or not on $node, Count is $netsim_output[-1]\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

###########################################################
#####################################################
# verify MeasurementType
##########################################################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$node,
            "e length(csmo:get_mo_ids_by_type(null, \"RcsPm:MeasurementType\"))."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

open(MAINLOG, ">>", "$setPath/../log/msrbsip.log") or die "can't ############ open LogsFile $setPath/../log/msrbsip.log: $!\n";
print MAINLOG "\n@netsim_output\n";
close (MAINLOG);
if ( $NumOfMeasurementType == 0 ) {
        print "\nINFO: MeasurementType does not exist for this MIM\n";
}
elsif (int($netsim_output[-1]) == $NumOfMeasurementType ) {
        say $fh "\nINFO: PASSED, $node Measurement type MO count is $netsim_output[-1]\n";
}
else {
        say $fh "\nFAILED: Check if all the Measurement type are loaded or not on $node, Count is $netsim_output[-1]\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();


#####################################################
# verify EventType
##########################################################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$node,
            "e length(csmo:get_mo_ids_by_type(null, \"RcsPMEventM:EventType\"))."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

open(MAINLOG, ">>", "$setPath/../log/msrbsip.log") or die "can't ############ open LogsFile $setPath/../log/msrbsip.log: $!\n";
print MAINLOG "\n@netsim_output\n";
close (MAINLOG);
if ( $NumOfEventType == 0 ) {
        print "\nINFO: EventType does not exist for this MIM\n";
}
elsif (int($netsim_output[-1]) == $NumOfEventType ) {
        say $fh "\nINFO: PASSED, $node EventType MO count is $netsim_output[-1]\n";
}
else {
        say $fh "\nFAILED: Check if all the EventTYpe are loaded or not on $node, Count is $netsim_output[-1]\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$node,
            ".stop ",
           );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

}

#functions#
#---------------------------------------------------------------
sub isSimDG2{
    local ($simname)=@_;
    local $returnvalue="ERROR";
    local $simserachvalue="MSRBS";

    # check param is valid
    if (length($simname)<1){return $returnvalue;}

    # check for DG2 simnam
    if($simname=~m/MSRBS/){
       $returnvalue="YES"}# end if
    else{$returnvalue="NO";}# end else
    return($returnvalue);
} # end isSimDG2
#-----------------------------------------

system (" cat $Path/Result.txt >> $PmLogs");
system (" cat $PmLogs");

open(FILE,"$Path/Result.txt");
if (grep{/FAILED/} <FILE>){
   print "\n---------There are FAILURES-----------\n";
   exit 9;
}else{
   print "\n---------PASSED----------------------\n";
}
close FILE;
##########################################################
print "####################END OF SCRIPT######################################";
