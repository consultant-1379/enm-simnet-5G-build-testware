#!/usr/bin/perl

### VERSION HISTORY
#####################################################################################
##     Version     : 3.3
##     
##     Revision    : CXP 903 6539-1-65
##
##     Author      : Saivikas Jaini
##
##     JIRA        : NSS-33166
##
##     Description : This changes are included to remove netsim,netsim as username and password for MT sims
##
##     Date        : 06th Oct 2023
######################################################################################
#
##     Version     : 3.2
##
##     Revision    : CXP 903 6539-1-57
##
##     Author      : Saikrishna Tulluri
##
##     JIRA        : NSS-41458
##
##     Description : Passing template parameter to WriteSimData.sh
##
##     Date        : 23rd Nov 2022
#####################################################################################
##     Version     : 3.1
##
##     Revision    : CXP 903 6539-1-40
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : No-JIRA
##
##     Description : Removing code for setting managedElementId
##
##     Date        : 14th Dec 2021
#####################################################################################
##     Version     : 3.0
##
##     Revision    : CXP 903 6539-1-39
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : No-JIRA
##
##     Description : Code changes node start issue in Centos VMs
##
##     Date        : 06th Dec 2021
##
####################################################################################
####################################################################################
##     Version     : 2.9
##
##     Revision    : CXP 903 6539-1-32
##
##     Author      : Saivikas Jaini
##
##     JIRA        : NSS-35147
##
##     Description : Adding node support for EVNFM
##
##     Date        : 06th Apr 2021
##
######################################################################################
#####################################################################################
##     Version     : 2.8
##
##     Revision    : CXP 903 6539-1-31
##
##     Author      : Vinay Baratam
##
##     JIRA        : NSS-35146
##
##     Description : Adding node support for VNF-LCM
##
##     Date        : 06th Apr 2021
##
######################################################################################
####################################################################################
##     Version     : 2.7
##
##     Revision    : CXP 903 6539-1-26
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-33178
##
##     Description : Craeting Ciphers for VTFRadioNode,vRC,vPP,RVNFM,vSD nodes
##
##     Date        : 05th Nov 2020
##
#####################################################################################
####################################################################################
##     Version     : 2.6
##
##     Revision    : CXP 903 6539-1-25
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-32261
##
##     Description : Removing unwanted curr files present in fss and dbs folder
##
##     Date        : 22nd Sept 2020
##
#####################################################################################
####################################################################################
##     Version     : 2.5
##
##     Revision    : CXP 903 6539-1-24
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-31649
##
##     Description : Supporting for MULTIRAT NR simulation
##
##     Date        : 27th Jul 2020
##
#####################################################################################
####################################################################################
##     Version     : 2.4
##
##     Revision    : CXP 903 6539-1-20
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-29548
##
##     Description : Implementing Cloning the nodes
##
##     Date        : 23rd Apr 2020
##
#####################################################################################
#####################################################################################
##     Version     : 2.3
##
##     Revision    : CXP 903 6539-1-19
##
##     Author      : Sujan Madhur
##
##     JIRA        : NSS-28747
##
##     Description : Adding support for nssSingleSimulationBuild Job and installation of 
##                   node template.
##
##     Date        : 22nd Apr 2020
##
######################################################################################
#####################################################################################
##     Version     : 2.2
##
##     Revision    : CXP 903 6539-1-14
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-28372,NSS-28446
##
##     Description : Adding support for CCDM nodes(CCES,VDU)
##
##     Date        : 18th Nec 2019
##
######################################################################################
#####################################################################################
#     Version     : 2.1
#
#     Revision    : CXP 903 6539-1-11
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-27484
#
#     Description : Adding support for CCDM nodes(CCSM,CCDM,CCRC,CCPC,SC,EDA).
#     
#     Date        : 04th Nov 2019
#
#####################################################################################
#     Version     : 2.0
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
#
#     Author : Kathak Mridha
#
#     JIRA : NSS-11701
#
#     Description : creates a 5G simulation as specified in parameter
#
#     Syntax : buildSims5G.pl $SIMNAME $productNumber $productRevision
#
#     Date : April 2017
#
####################################################################################
#####################################################################################
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-13911
#
#     Description : Upload different features to 5G nodes.
#
#     Syntax : buildSims5G.pl $SIMNAME $productNumber $productRevision
#
#     Date : September 2017
#
####################################################################################
#####################################################################################
#
#     Author : Mitali Sinha
#
#     JIRA : NSS-15733
#
#     Description : NetLog feature support for vPP nodes.
#
#     Date : November 2017
#
####################################################################################
#####################################################################################
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-16270
#
#     Description : Support for NNI the virtual UE Handler CAT-M (SP-tbd)
#
#     Date        : December 2017
#
####################################################################################
#####################################################################################
#
#     Author      : Mitali Sinha
#
#     JIRA        : NSS-18232/18233
#
#     Description : NetLog feature support for RVNFM + vSD Node
#
#     Date        : April 2018
####################################################################################

#####################################################################################
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-18443
#
#     Description : Support for VRSM node LTE VRAN
#
#     Date        : April 2018
#
####################################################################################
#####################################################################################
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-21827
#
#     Description : Support for VTIF node
#
#     Date        : Nov 2018
#
####################################################################################
#####################################################################################
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Support RadioNode GNODE-B
#
#     Date         : March 2019
#
####################################################################################
####################################################################################
#     Version     : 1.9
#
#     Revision    : CXP 903 6539-1-1
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-24351
#
#     Description : Adding support for CMMC Nodes(ie., NRF, UDR, UDM-AUSF, PCC & PCG)
#
#     Date        : 24th APR 2019
#
####################################################################################
####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../lib/cellconfig";
use Cwd;
use POSIX;
use LTE_CellConfiguration;
use LTE_General;
use LTE_OSS12;
use LTE_OSS13;
use LTE_Relations;
use LTE_OSS14;
use LTE_OSS15;
#use System;
################################
# Usage
################################
local @helpinfo=qq(
ERROR : need to pass 1 parameter to ${0}

Usage : ${0} <simulation name>

Example1 : ${0} LTE17B-V1x2-FT-vSD-SNMP-LTE01

Example2 : ${0} LTE17B-V1x2-FT-vSD-TLS-LTE01

); # end helpinfo
################################
system "chmod -R 777 /var/simnet/enm-simnet-5G/";
#################################
################################
# Vars
################################
local $date=`date`;
local $START_DATE =`date`;
local $startDate=`date +%s`;
local $netsimserver=`hostname`;
local $username=`/usr/bin/whoami`;
$username=~s/^\s+//;$username=~s/\s+$//;
$netsimserver=~s/^\s+//;$netsimserver=~s/\s+$//;
local $NETSIMDIR="/netsim/netsimdir/";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local @netsim_output=();
local $dir=cwd;
local $currentdir=$dir."/";
local $scriptpath="$currentdir";
local $SCRIPTROOTDIR="$scriptpath";
local $SCRIPTDIR="$scriptpath";
local $NETSIMDIRPATH="/netsim/netsimdir/";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT;
local $LOGFILE=$scriptpath."../log/";
local $SIMNAME=$ARGV[0];
local $PORT="NETCONF_PROT";
local $DESTPORT="NETCONF_PROT";
local $NODECOUNT=1;
#local $productNumber=$ARGV[1],$productRevision=$ARGV[2];
local $pdkdate=`date '+%FT%T'`;chomp $pdkdate;
$LOGFILE=$LOGFILE."${SIMNAME}.log";
local @sim1,@sim2,@sim3,@sim4,$MIMVERSION,$NUMOFNODES,$PROTOCOL,$NODETYPE,$SIMNUM,$NETYPE,$NODENAME,$node;
local $ENV="../dat/CONFIG.env";
local $SwitchToRV=&getENVfilevalue($ENV,"SWITCHTORV");
print "SwitchToRV=$SwitchToRV";
####################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
   unlink "$NETSIMMOSCRIPT";}
if (-e "$NETSIMMMLSCRIPT"){
   unlink "$NETSIMMMLSCRIPT";}
if (-e "$LOGFILE"){
   unlink "$LOGFILE";}

open LOG, ">>$LOGFILE" or die $!;
print "... ${0} started running at $date\n";
print LOG "... ${0} started running at $date\n";

#-----------------------------------------
# ensure script being executed by netsim
#-----------------------------------------
#if ($username ne "netsim"){
#print "FATAL ERROR : ${0} needs to be executed as user : netsim and NOT user : $username\n";exit(1);
#print LOG "FATAL ERROR : ${0} needs to be executed as user : netsim and NOT user : $username\n";exit(1);
#}# end if

#-----------------------------------------
# ensure netsim inst in place
#-----------------------------------------
if (!(-e "$NETSIM_INSTALL_PIPE")){# ensure netsim installed
       print "FATAL ERROR : $NETSIM_INSTALL_PIPE does not exist on $netsimserver\n";exit(1);
       print LOG "FATAL ERROR : $NETSIM_INSTALL_PIPE does not exist on $netsimserver\n";exit(1);
}# end if

#############################
# verify script params
#############################
if (!( @ARGV==1)){
      print "@helpinfo\n";exit(1);
      print LOG "@helpinfo\n";exit(1);
}# end if

# check  appears in simname
#if (!($SIMNAME=~m/LTE/)){
#    print "FATAL ERROR : $SIMNAME should have naming format eg. LTE17B-V1x2-FT-vSD-TLS-LTE01 . '' is missing.\n";
#    print LOG "FATAL ERROR : $SIMNAME should have naming format eg. LTE17B-V1x2-FT-vSD-TLS-LTE01 . '' is missing.\n";   exit(1);
#}# end if

#############################
# verify if sim exists
#############################
# check if sim already exists
if (-d "$NETSIMDIR$SIMNAME"){$counter++;}
if (-e "$NETSIMDIR$SIMNAME.zip"){$counter++;}

if($counter==1){# sim exists
    print "INFO : $NETSIMDIR$SIMNAME already exists and is being deleted\n";
    print LOG "INFO : $NETSIMDIR$SIMNAME already exists and is being deleted\n";
    # build mml script
    @MMLCmds=(
            ".open ".$SIMNAME,
                ".selectnocallback network",
                ".stop -parallel",
                ".deletesimulation ".$SIMNAME
        );# end @MMLCmds
}

if($counter==2){# sim and zip exists
    print "INFO $NETSIMDIR$SIMNAME already exists and is being deleted\n";
    print LOG "INFO $NETSIMDIR$SIMNAME already exists and is being deleted\n";
    print "INFO $NETSIMDIR$SIMNAME.zip already exists and is being deleted\n";
    print LOG "INFO $NETSIMDIR$SIMNAME.zip already exists and is being deleted\n";
    # build mml script
    @MMLCmds=(
            ".open ".$SIMNAME,
                ".selectnocallback network",
                ".stop -parallel",
                ".deletesimulation $SIMNAME",
                ".deletesimulation $SIMNAME.zip"
        );# end @MMLCmds
}
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

#############################
# NETSim call
#############################
# execute mml script
# @netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
# output mml script execution
# print "@netsim_output\n";
 #print LOG "@netsim_output\n";
# remove mml script
unlink "$NETSIMMMLSCRIPT";

#------------------------------
# start create 5G comms port
#------------------------------

local $keyword="secondary";
local $local_ips="^127\\\.0\\\.0";
# Build a list of invalid ips to use in ip query string
local $invalid_ips='\.0$\|\.251$\|\.252$\|\.253$\|\.254$\|\.255$';

# Build the ip command query to list available IP addresses
local $ip_query_01="ip -4 addr show | grep -i \"$keyword\" | awk '{ print \$2}' | awk -F \"/\" '{ print \$1 }' | grep -v \"$local_ips\\\|$invalid_ips\" | grep -v \"\$\(hostname -i \)\" | sort -t \"\.\" -k 1n,1 -k 2n,2 -k 3n,3 -k 4n,4 -u";
# Assign the list of valid available ips to an array by running the created ip command query
@tempvirtualips=qx($ip_query_01);

$element2="",$counter=0;
$createLTEcommsport=0;
$pointer=0;

foreach $element2 (@tempvirtualips){
     if ($element2 !~ /([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)/) {
         next;
     }# end if
     $element2=~s/\s.*//;
     $element2=~ s/^\s+//;$element2=~s/\s+$//;
     $virtualips[$counter]=$element2;
     $counter++;
}# end for each
$element2="";
@sortedvirtualips =sort{$a <=> $b} @virtualips;
$createLTEcommsport++;

# get free IPs
if($createLTEcommsport==1){
  foreach $element2(@sortedvirtualips ){
        ($ip1,$ip2,$ip3,$ip4)=$element2=~m/(\d+)\.(\d+)\.(\d+)\.(\d+)/;
        if(($ip4>1)||($ip2==0)||($ip3==0)){next;}# end next if
        if($ip4==1){
           $ipadd[$counter2]="$ip1.$ip2.$ip3.0";
        }# end inner if
  $counter2++;
  }# end foreach
}# end if get free IPs
#------------------------------
# end create 5G comms port
#------------------------------

$DYNAMICPORT=$PORT;
$DYNAMICPORT=~s/^.*=//;
$DYNAMICPORT=~s/\n//;

 #~~~~~~~~~~~~~~~~~~~~~~
 # NETCONF Comms Port
 #~~~~~~~~~~~~~~~~~~~~~~
if ( $SIMNAME =~ m/VNFM/i || $SIMNAME =~ m/NRAT/i || $SIMNAME =~ m/MULTIRAT/i || $SIMNAME =~ m/VNF-LCM/i ) {

 @MMLCmds=();
 @MMLCmds=(
          ".select configuration",
	  ".config deleteport ".$DYNAMICPORT,
	  ".config save",
	  ".select configuration",
          ".config add port ".$DYNAMICPORT." netconf_https_http_prot ".$netsimserver,
          ".config port address ".$DYNAMICPORT." ".$ipadd[$pointer]." 161 public 2 %unique 2 %simname_%nename authpass privpass 2 2",
          ".config save"
  );# end @MMLCmds
 $NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# NETCONF Destination Port
#~~~~~~~~~~~~~~~~~~~~~~~~~~
$DESTPORT=~s/^.*=//;
$DESTPORT=~s/\n//;

@MMLCmds=();
@MMLCmds=(
       ".config deleteexternal ".$DESTPORT,
       ".config add external ".$DESTPORT." netconf_https_http_prot",
       ".config external servers ".$DESTPORT." ".$netsimserver,
       ".config external address ".$DESTPORT." 0.0.0.0 162 1",
       ".config save"
      );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
}
else {
 @MMLCmds=();
 @MMLCmds=(
          ".select configuration",
          ".config add port ".$DYNAMICPORT." netconf_prot ".$netsimserver,
          ".config port address ".$DYNAMICPORT." ".$ipadd[$pointer]." 161 public 2 %unique 2 %simname_%nename authpass privpass 2 2",
          ".config save"
  );# end @MMLCmds
 $NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# NETCONF Destination Port
#~~~~~~~~~~~~~~~~~~~~~~~~~~
$DESTPORT=~s/^.*=//;
$DESTPORT=~s/\n//;

@MMLCmds=();
@MMLCmds=(
       ".config add external ".$DESTPORT." netconf_prot",
       ".config external servers ".$DESTPORT." ".$netsimserver,
       ".config external address ".$DESTPORT." 0.0.0.0 162 1",
       ".config save"
      );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

}

# execute mml script
#@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
#print "@netsim_output\n";
#print LOG "@netsim_output\n";

# remove mo script
unlink "$NETSIMMMLSCRIPT";
$pointer++;

################################
# MAIN
################################

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
elsif(index($SIMNAME, NRAT) != -1) {
@sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /NR/, $sim1[0];
 @sim4= split /NR/, $sim1[1];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="gNodeBRadio";
 $SIMNUM="$sim4[2]";
 $NETYPE="MSRBS-V2 ${sim3[1]}";
 $nodeStartNumber="00001",$counter="0";
 $NODENAME="NR${SIMNUM}${NODETYPE}";
 $node="${NODENAME}00001";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
print "SIMNUM is $SIMNUM\n";
print "NETYPE is $NETYPE\n";
print "NODENAME is $NODENAME\n";

}
elsif(index($SIMNAME, MULTIRAT) != -1) {
@sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /NR/, $sim1[0];
 @sim4= split /NR/, $sim1[1];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="gNodeBRadio";
 $SIMNUM="$sim4[1]";
 $NETYPE="MSRBS-V2 ${sim3[1]}";
 $nodeStartNumber="00001",$counter="0";
 $NODENAME="NR${SIMNUM}${NODETYPE}";
 $node="${NODENAME}00001";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
print "SIMNUM is $SIMNUM\n";
print "NETYPE is $NETYPE\n";
print "NODENAME is $NODENAME\n";

}
elsif(index($SIMNAME,EVNFM) != -1) {
 @sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /LTE/, $sim1[0];
 @sim4= split /LTE/, $sim2[3];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="$sim2[2]0";
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
 print "NODENAME is $NODENAME\n";
}
elsif(index($SIMNAME, VNFM) != -1) {
@sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /LTE/, $sim1[0];
 @sim4= split /LTE/, $sim2[4];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="$sim2[2]$sim2[3]0";
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

}
elsif(index($SIMNAME, VNF-LCM) != -1) {
 @sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /LTE/, $sim1[0];
 @sim4= split /LTE/, $sim2[4];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="$sim2[2]$sim2[3]0";
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
}
elsif(index($SIMNAME, AUSF) != -1) {
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

}
elsif(index($SIMNAME, "5GRadioNode") != -1) {
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
elsif(index($SIMNAME, "5G") != -1) {
 @sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /5G/, $sim1[0];
 @sim4= split /5G/, $sim2[3];
 $MIMVERSION="$sim3[1]";
 $NUMOFNODES="$sim2[0]";
 $NODETYPE="$sim2[2]";
 $SIMNUM="$sim4[1]";
 $NETYPE="${sim2[2]} ${sim3[1]}";
 $nodeStartNumber="00001",$counter="0";
 $NODENAME="5G${SIMNUM}${NODETYPE}";
 $node="${NODENAME}00001";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NUMOFNODES is $NUMOFNODES\n";
print "NODETYPE is $NODETYPE\n";
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

$CLONEDNODES = `expr $NUMOFNODES - 1`;
chomp($CLONEDNODES);
$nodeNumber="00002";

#system "cp /var/nssSingleSimulationBuild/* ../dat";

my @str = split /[ -]/, $NETYPE;
my $prefix = "/";
my $str = $prefix.join( ".*", @str);
print "Search pattern is --> $str\n";

my $template = "No Node Template link found";
if ($SIMNAME =~ m/RUI/) {
    $template = `cat /netsim/simdepContents/nodeTemplate.content | grep -i $str  | sed 's/"//g' | head -c -1`;
}
else {
    $template = `cat /netsim/simdepContents/nodeTemplate.content | grep -i $str | grep -v "RUI"  | sed 's/"//g' | head -c -1`;
}

print "$template\n";
my $templateNode = (split '/', $template)[-1];
my $templateWithoutZip = (split '.zip', $templateNode)[0];

print "Node Template Link:\n";
print "$template\n";
print "Node Template file is\n";
print "$templateNode\n";
print "Node Template name Without Zip is \n";
print "$templateWithoutZip \n \n";

if (-e "$NETSIMDIR$templateNode"){
       system("echo netsim | sudo -S -H -u netsim bash -c 'echo \".deletesimulation $templateNode\" | /netsim/inst/netsim_shell' | tee -a ../log/$SIMNAME.log");
}
if (-d "$NETSIMDIR$templateWithoutZip"){
       system("echo netsim | sudo -S -H -u netsim bash -c 'echo \".deletesimulation $templateWithoutZip\" | /netsim/inst/netsim_shell' | tee -a ../log/$SIMNAME.log");
}

system "wget -P /netsim/netsimdir $template";
system("echo netsim | sudo -S -H -u netsim bash -c 'echo \".uncompressandopen clear_lock\" | /netsim/inst/netsim_shell' | tee -a ../log/$SIMNAME.log");
system("echo netsim | sudo -S -H -u netsim bash -c 'echo \".uncompressandopen $templateNode force\" | /netsim/inst/netsim_shell' | tee -a ../log/$SIMNAME.log");

my $Node = join( "-", @str);
my $line = qx(grep $Node ../dat/ProductData.env);
my $productdata = (split '=', $line)[-1];

my $productNumber = (split ':', $productdata)[0];
my $productRevision = (split ':', $productdata)[-1];

print "Product Number : ";
print "$productNumber\n";
print "Product Revision : ";
print "$productRevision\n";

print "INFO : $SIMNAME creation is started\n";
print LOG "INFO : $SIMNAME creation is started\n";

@MMLCmds=();
@MMLCmds=(
            ".open ".$templateWithoutZip,
            ".saveasimul ".$SIMNAME,
            ".open ".$SIMNAME,
            ".setactivity START",
            ".initialguistatus",
            ".createne checkport ".$PORT,
            ".set preference positions 5",
);# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

@MMLCmds=();
@MMLCmds=(
            ".selectnocallback NE01",
            ".rename -auto ".$NODENAME." ".$nodeStartNumber,
            ".set save",
            ".clone ".$CLONEDNODES." ".$NODENAME." ".$nodeNumber,
            ".selectnetype ".$NETYPE,
            ".set port ".$PORT,
            ".createne subaddr ".$nodeStartNumber." subaddr no_value",
            ".set taggedaddr subaddr ".$nodeStartNumber." 1",
            ".createne dosetext external ".$DESTPORT,
            ".set external ".$DESTPORT,
            ".set ssliop no no_value",
            ".set save",
);# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

# execute mml script
 #@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
 system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
# output mml script execution
 #print "@netsim_output\n";
 #print LOG "@netsim_output\n";

$date=`date`;
# remove mml script
unlink "$NETSIMMMLSCRIPT";

system ("echo netsim | sudo -S -H -u netsim bash -c '$scriptpath/nodeStart.sh $SIMNAME'");

#############################
# Checking for PM MOs
#############################
system "./PmUnitTest.pl $SIMNAME";
system "cat $scriptpath/../log/Pmlogs.txt >> $scriptpath/../log/$SIMNAME.log";
my $cmdResult = `cat $scriptpath/../log/Pmlogs.txt | grep -i "failed" | wc -l`;
open(MAINLOG, '>>', "$scriptpath/../log/$SIMNAME.log") or die "Could not open file $scriptpath/../log/$SIMNAME.log $!";
if ($cmdResult == 0) {
    print "\n***********************************************************\n";
    print MAINLOG "\n***********************************************************\n";
    print "\nPm Data is proper on these nodes present in $SIMNAME \n";
    print MAINLOG "\nPm Data is proper on these nodes present in $SIMNAME \n";
    print "\n***********************************************************\n";
    print MAINLOG "\n***********************************************************\n";
}
else {
    print "\n***********************************************************\n";
    print MAINLOG "\n***********************************************************\n";
    print "\nPm Data is not proper on these nodes present in $SIMNAME \n";
    print MAINLOG "\nPm Data is not proper on these nodes present in $SIMNAME \n";
    print "\nPlease check the Pm Data on the nodes with the respective MIB file \n";
    print MAINLOG "\nPlease check the Pm Data on the nodes with the respective MIB file \n";
    print "\nWe are exiting from the build\n";
    print MAINLOG "\nWe are exiting from the build\n";
    print "\n***********************************************************\n";
    print MAINLOG "\n***********************************************************\n";
    exit 1;
}
print "\n******** ENd of PM script Execution **********\n";
print MAINLOG "\n******** ENd of PM script Execution **********\n";
close(MAINLOG);


#############################
# END Checking for PM MOs
#############################

#############################
if ($SIMNAME =~ m/vPP/i ) {
system "$scriptpath/vpp.pl $SIMNAME $productNumber $productRevision ";
}
elsif ($SIMNAME =~ m/vRC/i) {
system "$scriptpath/vrc.pl $SIMNAME $productNumber $productRevision ";
}
elsif($SIMNAME =~ m/vSD/i) {
system "$scriptpath/vsd.pl $SIMNAME $productNumber $productRevision ";
}
elsif($SIMNAME =~ m/VTF/i) {

system "$scriptpath/vtf.pl $SIMNAME $productNumber $productRevision ";
}
elsif($SIMNAME =~ m/CCDM/i || $SIMNAME =~ m/CCPC/i || $SIMNAME =~ m/CCRC/i || $SIMNAME =~ m/CCSM/i || $SIMNAME =~ m/SC/i || $SIMNAME =~ m/EDA/i || $SIMNAME =~ m/CCES/i || $SIMNAME =~ m/vDU/i){
system "$scriptpath/udm.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/5GRadioNode/i){

system "$scriptpath/5g.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/EVNFM/i){

    system "$scriptpath/evnfm.pl $SIMNAME $productNumber $productRevision";
}

elsif($SIMNAME =~ m/VNFM/i){

system "$scriptpath/rnn_vnfm.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/VNF-LCM/i){

    system "$scriptpath/vnf_lcm.pl $SIMNAME $productNumber $productRevision";
}
elsif ($SIMNAME =~ m/RNN/i){

system "$scriptpath/rnnode.pl $SIMNAME $productNumber $productRevision";
}

elsif($SIMNAME =~ m/vRM/i || $SIMNAME =~ m/vRSM/i ){

system "$scriptpath/vrm.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/VTIF/i) {

system "$scriptpath/vtif.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/NRF/i) {

system "$scriptpath/nrf.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/UDM-AUSF/i) {

system "$scriptpath/udm_ausf.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/PCC/i) {

system "$scriptpath/pcc.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/PCG/i) {

system "$scriptpath/pcg.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ m/UDR/i) {

system "$scriptpath/udr.pl $SIMNAME $productNumber $productRevision";
}
elsif($SIMNAME =~ /^NR/i) {

system("echo netsim | sudo -S -H -u netsim bash -c '$scriptpath/DG2/runDg2Scripts.sh $SIMNAME CONFIG.env' | tee -a $LOGFILE");
#system "$scriptpath/DG2/runDg2Scripts.sh $SIMNAME CONFIG.env | tee -a $LOGFILE";
}

#############################
# Create Ciphers
#############################

if($SIMNAME =~ m/VTFRadioNode/i || $SIMNAME =~ m/vRC/i || $SIMNAME =~ m/vPP/i || $SIMNAME =~ m/vSD/i || $SIMNAME =~ m/RAN-VNFM/i || $SIMNAME =~ m/VNF-LCM/i || $SIMNAME =~ m/EVNFM/i) {
system("echo netsim | sudo -S -H -u netsim bash -c '$scriptpath/createCiphers.sh $SIMNAME' | tee -a $LOGFILE");
}

#############################
# Setting netsim user
#############################

# build mml script
@MOCmds=();
print "SwitchToRV=$SwitchToRV";
if($SwitchToRV=~m/NO/){
@MMLCmds=(".open ".${SIMNAME},
          ".select network",
          ".stop -parallel"
);# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
}
else{
@MMLCmds=(".open ".${SIMNAME},
          ".select network",
          ".setuser netsim netsim",
          ".stop -parallel"
);# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
}

#@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
# output mml script execution
   #print "@netsim_output\n";
  # print LOG "@netsim_output\n";

# remove mo script
unlink "$NETSIMMMLSCRIPT";

#############################
# END Setting netsim user
#############################

system "rm -rf /netsim/netsimdir/${SIMNAME}/allsaved/fss/*";
system "rm -rf /netsim/netsimdir/${SIMNAME}/allsaved/old-fss/*";
system "rm -rf /netsim/netsimdir/${SIMNAME}/saved/dbs/*";
system "rm -rf /netsim/netsimdir/${SIMNAME}/saved/fss/*";
system "rm -rf /netsim/netsim_dbdir/simdir/netsim/netsimdir/*/*/fs/*";

#############################
# save&compress
#############################

@MMLCmds=();
@MMLCmds=(
        ".open ".$SIMNAME,
        ".select network",
        ".stop -parallel",
        ".saveandcompress force nopmdata"
         );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);

# execute mml script
 #@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
 system("echo netsim | sudo -S -H -u netsim bash -c '/netsim/inst/netsim_pipe < $NETSIMMMLSCRIPT' | tee -a ../log/$SIMNAME.log");
# output mml script execution
# print "@netsim_output\n";
 print LOG "@netsim_output\n";

# remove mml script
unlink "$NETSIMMMLSCRIPT";

#############################
# END save&compress
#############################
local $endDate = `date +%s`;
local $END_DATE=`date`;
local $runtimeInHours = int(($endDate - $startDate) / 3600);
local $runtimeInMinutes = int(($endDate - $startDate) / 60);
local $runtimeInSeconds = int(($endDate - $startDate) % 60);
print "... ${0} ended running at $date\n";
print LOG "... ${0} ended running at $date\n";

print LOG "***** Total Build time is $runtimeInHours Hrs $runtimeInMinutes Min ******\n";
print "***** Total Build time is $runtimeInHours Hrs $runtimeInMinutes Min $runtimeInSeconds ******\n";
print "Started at $START_DATE -------- Ended at $END_DATE \n";
print LOG "Started at $START_DATE -------- Ended at $END_DATE \n";
close(LOG);

#############################
#copying files to Simnet revision folder
#############################
#system "$scriptpath/WriteSimData.sh $SIMNAME";
system("echo netsim | sudo -S -H -u netsim bash -c '$scriptpath/WriteSimData.sh $SIMNAME $templateWithoutZip' | tee -a ../log/$SIMNAME.log");
#############################
#copying files to Simnet revision folder ended
#############################

################################
# Subs
################################
sub makeMOscript{
    local ($fileaction,$moscriptname,@cmds)=@_;
    $moscriptname=~s/\.\///;
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

##########################################################
#UPDATING IPS COUNT
#########################################################################

#This will update IPs count in sims

print "Calling a shell script Script_to_UpdateIp.sh from this script :\n ";

system("sh", "Script_to_UpdateIp.sh","$SIMNAME");

print "Completed...IP Details are updated in the Simulation folder....\n";

#-------------------------------------------------
#        #COMPLETED
#------------------------------------------------
