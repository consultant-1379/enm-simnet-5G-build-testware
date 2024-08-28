#!/usr/bin/perl


### VERSION HISTORY
#####################################################################################
##     Version     : 1.7
##
##     Revision    : CXP 903 6539-1-25
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-32549
##
##     Description : Creating Ikev2PolicyProfile=1 under Transport MO
##
##     Date        : 28th Sep 2020
##
#####################################################################################
#####################################################################################
#     Version     : 1.6
#
#     Revision    : CXP 903 6539-1-9
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-26879
#
#     Description : Create VTFrat:ENodeBFunction on VTFRadioNodes
#
#     Date        : 31st Oct 2019
#
####################################################################################
#####################################################################################
#     Version     : 1.5
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
#     Version     : 1.4
#
#     Revision    : CXP 903 6539-1-1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24526
#
#     Description : Setting userLabel attribute in SysM MO for VTFRadioNodes.
#
#     Date        : 23rd April 2019
#
####################################################################################
#####################################################################################
#     Version: 1.3
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-15812
#
#     Description : Genstats file output location needs to be synched with real node values
#
#     Date : 7th Nov 2017
#
####################################################################################
#####################################################################################
#     Version: 1.2
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-14967
#
#     Description : New CertMCapabilities values required for VTF nodes.
#
#     Date : 26th Sept 2017
#
####################################################################################
#####################################################################################
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-14088
#
#     Description :Require features for VTF nodes.
#
#     Date : September 2017
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

local @sim1,@sim2,@sim3,@sim4,$MIMVERSION,$NUMOFNODES,$PROTOCOL,$NODETYPE,$SIMNUM,$NETYPE,$NODENAME,$node;

if (index($SIMNAME, TLS) != -1){
 @sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /LTE/, $sim1[0];
 @sim4= split /LTE/, $sim2[4];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $PROTOCOL="$sim2[2]";
 $NODETYPE="$sim2[3]";
 $SIMNUM="$sim4[1]";
 $NETYPE="${sim2[3]} ${sim3[1]}";
 $nodeStartNumber="00001",$counter="0";
 $NODENAME="LTE${SIMNUM}${NODETYPE}";
 $node="${NODENAME}00001";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
print "PROTOCOL is $PROTOCOL\n";
print "SIMNUM is $SIMNUM\n";
print "NETYPE is $NETYPE\n";
print "NODENAME is $NODENAME\n\n";
}
else {
 @sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /LTE/, $sim1[0];
 @sim4= split /LTE/, $sim2[3];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="$sim2[2]";
 $SIMNUM="$sim4[1]";
 $NETYPE="${sim2[2]} ${sim3[1]}";
 $nodeStartNumber="00001",$counter="0";
 $NODENAME="LTE${SIMNUM}${NODETYPE}";
 $node="${NODENAME}00001";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
print "SIMNUM is $SIMNUM\n";
print "NETYPE is $NETYPE\n";
print "NODENAME is $NODENAME\n\n";
}

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

while ($NODECOUNT<=$NUMOFNODES){

	if($NODECOUNT<10){	$nodezeros="0000";}
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


SET
(
    mo "ManagedElement=$nodeName,SystemFunctions=1,PmEventM=1,EventProducer=VTFrat,FilePullCapabilities=2"
    exception none
    nrOfAttributes 1
    "outputDirectory" String "/pm_data"
)

SET
(
    mo "ManagedElement=$nodeName,SystemFunctions=1,SecM=1,CertM=1,CertMCapabilities=1"
    exception none
    nrOfAttributes 1
    "enrollmentSupport" Array Integer 3
         0
         1
         3
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

CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
    identity "1"
    moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 18
	"hwType" String "Card"
    "hwUnitLocation" String "slot:0"
    "productData" Struct
        nrOfElements 6
        "productName" String "$nodeName"
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productionDate" String ""
        "description" String ""
        "type" String ""

    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productDesignation" String ""

    "serialNumber" String "D821781392"
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
SET
(
    mo "ComTop:ManagedElement=$nodeName,ComTop:SystemFunctions=1,RcsSysM:SysM=1"
    exception none
    nrOfAttributes 1
    "userLabel" String "value"
)
CREATE
(
    parent "ComTop:ManagedElement=$nodeName,ComTop:Transport=1"
    identity "1"
    moType RtnIkev2PolicyProfile:Ikev2PolicyProfile
    exception none
    nrOfAttributes 1
    "ikev2PolicyProfileId" String "1"
)


   ^;# end @MO

print "hello 1 \n";
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
print "Hello 2\n ";

push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

@MMLCmds=(".open ".$SIMNAME,
          ".select ".$nodeName,
          ".start ",
          "useattributecharacteristics:switch=\"off\"; ",
            
	  ".genreffilecpp lte Fileset.STATS stats default",
          "createscanner2:id=1,measurement_name=\"PREDEF.10000.CELLTRACE\";",
	  "createscanner2:id=2,measurement_name=\"PREDEF.10001.CELLTRACE\";",
	  "createscanner2:id=3,measurement_name=\"PREDEF.10002.CELLTRACE\";",
	  "createscanner2:id=4,measurement_name=\"PREDEF.10003.CELLTRACE\";",
	  "createscanner2:id=5,measurement_name=\"PREDEF.10004.CELLTRACE\";",
	  "createscanner2:id=6,measurement_name=\"PREDEF.10005.CELLTRACE\";",
	  "createscanner2:id=100,measurement_name=\"PREDEF.STATS\",state=\"SUSPENDED\",file=\"Fileset.STATS\";",
	  "pmdata:disable;",

          "kertayle:file=\"$NETSIMMOSCRIPT\";"
     );# end @MMLCmds


$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
$NODECOUNT++;


}# end outer while NUMOFNODES

  # execute mml script
#    @netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
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
