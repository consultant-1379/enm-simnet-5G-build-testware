#!/usr/bin/perl


### VERSION HISTORY
#####################################################################################
#     Version     : 1.2
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
#     Version     : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24351
#
#     Description : Adding features for UDM-AUSF nodes.
#
#     Date        : 24th April 2019
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

#print "I am VRC from different script\n";

##################################
local $SIMNAME=$ARGV[0];
local $NETSIMDIR="/netsim/netsimdir/";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local @netsim_output=();
local $dir=cwd;
local $currentdir=$dir."/";
local $scriptpath="$currentdir";
local $MOSCRIPT="$scriptpath".$SIMNAME.".mo";
print "MOSCRIPT= $MOSCRIPT\n";
local $MMLSCRIPT="$scriptpath".$SIMNAME.".mml";
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT;
local $LOGFILE=$scriptpath."../log/";

local @sim1,@sim2,@sim3,@sim4,$MIMVERSION,$NUMOFNODES,$PROTOCOL,$NODETYPE,$SIMNUM,$NETYPE,$NODENAME,$node;

 @sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /LTE/, $sim1[0];
 @sim4= split /LTE/, $sim2[4];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="$sim2[2]$sim2[3]";
 $SIMNUM="$sim4[1]";
 $NETYPE="${sim2[2]}-${sim2[3]} ${sim3[1]}";
 $nodeStartNumber="00001",$counter="0";
 $NODENAME="LTE${SIMNUM}${NODETYPE}";
 $node="${NODENAME}00001";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
print "SIMNUM is $SIMNUM\n";
print "NETYPE is $NETYPE\n";
print "NODENAME is $NODENAME\n";


local $NODECOUNT=1;
local $productNumber=$ARGV[1],$productRevision=$ARGV[2];
local $pdkdate=`date '+%FT%T'`;chomp $pdkdate;
$LOGFILE=$LOGFILE."${SIMNAME}.log";
print "$scriptpath  ------------ $LOGFILE \n";
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
#################################################################
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
      mo "ComTop:ManagedElement=$nodeName"
      exception none
      nrOfAttributes 3
      "productIdentity" Array Struct 1
      nrOfElements 3
      "productNumber" String "$productNumber"
      "productRevision" String "$productRevision"
      "productDesignation" String "$nodeName"

      "dnPrefix" String "SubNetwork=$nodeName,MeContext=$nodeName"
      "dateTimeOffset" String "+01:00"
  )

  SET
  (
      mo "ManagedElement=$nodeName,SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1"
      exception none
      nrOfAttributes 1
      "fileLocation" String "/flash/pm"
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
   # @netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
    system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
  # output mml script execution
     #print "@netsim_output\n";
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
