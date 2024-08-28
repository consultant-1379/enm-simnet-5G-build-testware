#!/usr/bin/perl
#####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-24
#
#     Author       : Yamuna Kanchireddygari
#
#     JIRA         : NO-JIRA
#
#     Description  : Correcting Product Data code
#
#     Date         : 23rd Jul 2020
#
#####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Set HW Inventory
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
# start verify params
local @helpinfo=qq(Usage  : ${0} <sim name> <env file> <sim num>
Example: $0 LTEMSRBS-V415Bv6x160-RVDG2-FDD-LTE01 CONFIG.env 1);
if (!( @ARGV==3)){
   print "@helpinfo\n";exit(1);}
# end verify params
local $SIMNAME=$ARGV[0],$ENV=$ARGV[1],$LTE=$ARGV[2];
local $date=`date`,$LTENAME;
chomp $date;
local $time=`date '+%FT04-04-04.666%:z'`;
chomp $time;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $ProductDatafile="ProductData.env";
####################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
   unlink "$NETSIMMOSCRIPT";}
# check if SIMNAME is of type DG2
if(&isSimDG2($SIMNAME)=~m/NO/){exit;}
################################
# MAIN
################################
print "...${0} started running at $date\n";
################################
# Make MO & MML Scripts
################################
while ($NODECOUNT<=$DG2NUMOFRBS){

        $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
        $MIMVERSION=&queryMIM($SIMNAME,$NODECOUNT);
        $MIMVERSION = "MSRBS-V2-".$MIMVERSION;
        $ProductData=&getENVfilevalue($ProductDatafile,"$MIMVERSION");
        @productData = split( /:/, $ProductData );
        $productNumber=$productData[0];
        $productRevision=$productData[1];
        chomp $pdkdate;
        #Check for Product Data information
        if (($productNumber eq "ERROR")||($productRevision eq "")) {#start if
              print "ERROR : Product data information missing, the script will exit\n\n";
              exit;
        }#end if

	# build mml script
	@MOCmds=();
	@MOCmds=qq^
CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
	identity "1"
	moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 8
    "hwItemId" String "1"
    "vendorName" String "Ericsson"
    "hwModel" String "RadioNode"
    "hwType" String "Blade"
    "hwName" String "GEP3-24GB"
    "serialNumber" String "A064681011"
    "dateOfManufacture" String "$time"
    "hwUnitLocation" String "$LTENAME"
    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productDesignation" String "RadioNode"
     "productData" Struct
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productionDate" String "$date"
        "description" String "$LTENAME"
        "type" String "$LTENAME"
)

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1,RcsHwIM:HwItem=1"
	identity "1"
	moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 8
    "hwItemId" String "1"
    "vendorName" String "Ericsson"
    "hwModel" String "RadioNode"
    "hwType" String "Blade"
    "hwName" String "GEP3-24GB"
    "serialNumber" String "A064681011"
    "dateOfManufacture" String "$time"
    "hwUnitLocation" String "$LTENAME"
    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productDesignation" String "RadioNode"
    "productData" Struct
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productionDate" String "$date"
        "description" String "$LTENAME"
        "type" String "$LTENAME"

)

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
	identity "2"
	moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 8
    "hwItemId" String "2"
    "vendorName" String "Ericsson"
    "hwModel" String "RadioNode"
    "hwType" String "Blade"
    "hwName" String "GEP3-HD300"
    "serialNumber" String "A064688920"
    "dateOfManufacture" String "$time"
    "hwUnitLocation" String "$LTENAME"
    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productDesignation" String "RadioNode"
     "productData" Struct
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productionDate" String "$date"
        "description" String "$LTENAME"
        "type" String "$LTENAME"
)

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1,RcsHwIM:HwItem=2"
	identity "2"
	moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 8
    "hwItemId" String "2"
    "vendorName" String "Ericsson"
    "hwModel" String "RadioNode"
    "hwType" String "Blade"
    "hwName" String "GEP3-HD300"
    "serialNumber" String "A064688920"
    "dateOfManufacture" String "$time"
    "hwUnitLocation" String "$LTENAME"
    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productDesignation" String "RadioNode"
    "productData" Struct
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productionDate" String "$date"
        "description" String "$LTENAME"
        "type" String "$LTENAME"
)

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1"
	identity "3"
	moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 8
    "hwItemId" String "3"
    "vendorName" String "Ericsson"
    "hwModel" String "RadioNode"
    "hwType" String "Blade"
    "hwName" String "SCXB2"
    "serialNumber" String "A064688935"
    "dateOfManufacture" String "$time"
    "hwUnitLocation" String "$LTENAME"
    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productDesignation" String "RadioNode"
     "productData" Struct
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productionDate" String "$date"
        "description" String "$LTENAME"
        "type" String "$LTENAME"
)

CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsHwIM:HwInventory=1,RcsHwIM:HwItem=3"
	identity "3"
	moType RcsHwIM:HwItem
    exception none
    nrOfAttributes 8
    "hwItemId" String "3"
    "vendorName" String "Ericsson"
    "hwModel" String "RadioNode"
    "hwType" String "Blade"
    "hwName" String "SCXB2"
    "serialNumber" String "A064688935"
    "dateOfManufacture" String "$time"
    "hwUnitLocation" String "$LTENAME"
    "productIdentity" Struct
        nrOfElements 3
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productDesignation" String "RadioNode"
    "productData" Struct
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String $productNumber
        "productRevision" String $productRevision
        "productionDate" String "$date"
        "description" String "$LTENAME"
        "type" String "$LTENAME"

)
		^;# end @MO
   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT);

################################################
# build mml script
################################################
  @MMLCmds=(".open ".$SIMNAME,
            ".select ".$LTENAME,
            ".start ",
            "useattributecharacteristics:switch=\"off\"; ",
            "kertayle:file=\"$NETSIMMOSCRIPT\";"
  	   );# end @MMLCmds
$NETSIMMMLSCRIPT=&makeMMLscript("append",$MMLSCRIPT,@MMLCmds);
	$NODECOUNT++;
}# end outer while DG2NUMOFRBS

# execute mml script
@netsim_output=`$NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;
# output mml script execution
print "@netsim_output\n";
################################
# CLEANUP
################################
$date=`date`;
#remove mo script
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
print "... ${0} ended running at $date\n";
################################
# END
################################
