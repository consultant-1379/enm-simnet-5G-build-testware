#!/usr/bin/perl

###########################################################################################################################
# Created by  : Vinay Baratam
# Created on  : 06-04-2021
# Purpose     : Checks Product Data for VNF-LCM nodes
###########################################################################################################################
# Created by  : Yamuna Kanchireddygari
# Created on  : 02.07.2019
# Purpose     : Checks Product Data on 5G NR sims
###########################################################################################################################
##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 25.07.2018
# Purpose     : Checks Product Data on 5G sims
###########################################################################################################################

####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Cwd;
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
##############
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
local @SimSplit1=split /x/,$SimName;
local @SimSplit2=split /-/,$SimSplit1[1];
local @SimSplit3= split /LTE/, $SimSplit1[0];
local @SimSplit4= split /LTE/, $SimSplit2[2];
local $NUMOFNODES="$SimSplit2[0]";
local $MIMVERSION="$SimSplit2[1]";
local $NODETYPE;
if($SimName=~ m/vPP/ || $SimName=~ m/vRC/ || $SimName=~ m/VNFM/){
$NODETYPE="$SimSplit2[3]";
}
elsif($SimName=~ m/VNF-LCM/){
$NODETYPE="$SimSplit2[2]-$SimSplit2[3]";
}
elsif($SimName=~ m/gNodeBRadio/){
$NODETYPE="$SimSplit2[1]";
}
else{
$NODETYPE="$SimSplit2[2]";
}
local $NODECOUNT=1;
local @MMLCmds=();
local $node;
local $NETSIMMMLSCRIPT;

print "NODETYPE=$NODETYPE";

####################
# Integrity Check
####################

#-----------------------------------------
# ensure script being executed by root
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

################################
# MAIN
################################

print "\n############### Checking $SimName ##############\n";
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
$ProductDatafile="productData.env";
@MIM=split( /x/, $SimName );
if($SimName=~ m/gNodeBRadio/){
@MIMVERSION=split( /R/, $MIM[0] );
}
else{
@MIMVERSION=split( /E/, $MIM[0] );
}
$MIMVERSION=$MIMVERSION[1];
$ProductData=&getENVfilevalue($ProductDatafile,"${MIMVERSION}:${NODETYPE}");
@productData = split( /:/, $ProductData );
$productNumber=$productData[0];
$productRevision=$productData[1];

#print "\n MIMVERSION=$MIMVERSION  ;; ProductData=$ProductData  ;; NODETYPE=$NODETYPE";

#############################
# Print Product Data
#############################
@MMLCmds=(".open ".$SimName,
            ".select ".$node,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$node\",\"ComTop:SystemFunctions=1\",\"RcsSwIM:SwInventory=1\",\"RcsSwIM:SwItem=1\"]).",
            "e csmo:get_attribute_value(null,X,administrativeData)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
@productNumberFromNode=split( /"/, $netsim_output[10] );
@productRevisionFromNode=split( /"/, $netsim_output[11] );
$productNumberFromNode=$productNumberFromNode[1];
$productRevisionFromNode=$productRevisionFromNode[1];

if ($productNumberFromNode eq $productNumber) {
	print "\nPASSED: Product Number on $node is $productNumberFromNode\n";
}
else {
	print "\nFAILED: Product Number on $node is $productNumberFromNode ; It should be $productNumber\n";
}

if ($productRevisionFromNode eq $productRevision) {
	print "\nPASSED: Product Revision on $node is $productRevisionFromNode\n";
}
else {
	print "\nFAILED: Product Revision on $node is $productRevisionFromNode ; It should be $productRevision\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#Counter Variable
$NODECOUNT++;
}

print "\n########### End checking for $SimName ##########\n";
print "\n";
