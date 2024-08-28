#!/usr/bin/perl

##########################################################################################################################
# Created by  : Yamuna Kanchireddygari
# Created on  : 02.07.2019
# Purpose     : Check Backup Type and Domain on 5G Nodes.
###########################################################################################################################

####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Cwd;
use General;
use v5.10;
################################
# Usage
################################
local @helpinfo=qq(
ERROR : need to pass 1 parameter to ${0}

Usage : ${0} <simulation name>

Example1 : ${0} LTE18-Q4-V1x160-15K-DG2-FDD-LTE18

Example2 : ${0} LTE18-Q4-V1x160-15K-DG2-FDD-LTE18

); # end helpinfo

################################
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
local $SimName=$ARGV[0];
local $SIMNUMBER=substr($SIMNAME, -2);
local $NODECOUNT=1;
local @MMLCmds=();
local $NODENAME;
local $NETSIMMMLSCRIPT;
local @netsim_output=();

####################
# Integrity Check
####################

#-----------------------------------------
# ensure script being executed by netsim
#-----------------------------------------
if ($username ne "root"){
        print "FATAL ERROR : ${0} needs to be executed as user : root\n It is executed with user : $username\n";exit(1);
}# end if
#-----------------------------------------
# ensure netsim inst in place
#-----------------------------------------
if (!(-e "$NETSIM_INSTALL_PIPE")){# ensure netsim installed
       print "FATAL ERROR : $NETSIM_INSTALL_PIPE does not exist on $netsimserver\n";exit(1);
}# end if
#############################
# verify script params
#############################
if (!( @ARGV==1)){
      print "@helpinfo\n";exit(1);
}# end if
#if(&isSimDG2($SimName)=~m/NO/){ print "The Script runs only for RADIONODES\n"; exit;}
################################
# MAIN
################################

###Storing node details of simulation###

my $shell_out = <<`SHELL`;
echo netsim | sudo -S -H -u netsim bash -c 'printf ".open $SimName \n .show simnes" | /netsim/inst/netsim_shell | grep -v ">>" | grep -v "OK" | grep -v "NE"' >  NodeData.txt
#cat NodeData.txt | awk '{print $1}' > NodeData.txt
SHELL
#sed -r 's/([^ ]*) (.*) (.*$)/\1/' NodeData.txt > NodeData.txt

###Storing the nodes in an array###
system ("cut -f1 -d ' ' NodeData.txt > NodeData1.txt");
open(FILE, "<", "NodeData1.txt") or die("Can't open file");
@Nodes = <FILE>;
close(FILE);
foreach $node (@Nodes)
{
   chomp($node);

####################
#ComTop:ManagedElement=LTE18dg2ERBS00001,ComTop:SystemFunctions=1,RcsBrM:BrM=1,RcsBrM:BrmBackupManager=1,RcsBrM:BrmBackup=1

#############################
# verify BackupType and Domain
#############################
@MMLCmds=(".open ".$SimName,
            ".select ".$node,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$node\",\"ComTop:SystemFunctions=1\",\"RcsBrM:BrM=1\",\"RcsBrM:BrmBackupManager=1\"]).",
            "e csmo:get_attribute_value(null,X,backupType).",
            "e csmo:get_attribute_value(null,X,backupDomain).",
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

foreach $test (@netsim_output)
{ print "$_";}

my $filename = 'Result.txt';
open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";

if ("$netsim_output[9]" =~ "Systemdata") {
        say $fh "\n Info:PASSED on $node backupType is $netsim_output[9]";
}
else {
        say $fh " \n Info:FAILED on $node backupType is not set to Systemdata";
}

if ("$netsim_output[11]" =~ "System") {
        say $fh "Info:PASSED on $node backupDomain is $netsim_output[11]";
}
else {
        say $fh "Info:FAILED on $node backupDomain is not set to System";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

###
#############################
#Counter Variable
$NODECOUNT++;
} # foreach close

#functions#
#---------------------------------------------------------------
sub isSimDG2{
    local ($simname)=@_;
    local $returnvalue="ERROR";
    local $simserachvalue="DG2";

    # check param is valid
    if (length($simname)<1){return $returnvalue;}

    # check for DG2 simnam
    if($simname=~m/DG2/){
       $returnvalue="YES"}# end if
    else{$returnvalue="NO";}# end else
    return($returnvalue);
} # end isSimDG2
#-----------------------------------------


system (" cat /var/simnet/enm-simnet-5G/script/UnitTests/bin/Result.txt");

open(FILE,"/var/simnet/enm-simnet-5G/script/UnitTests/bin/Result.txt");
if (grep{/FAILED/} <FILE>){
   print "\n---------There are FAILURES-----------\n";
   exit 9;
}else{
   print "\n---------PASSED----------------------\n";
}
close FILE;

print "\n########### End checking for $SIMNAME ##########\n";
print "\n";
