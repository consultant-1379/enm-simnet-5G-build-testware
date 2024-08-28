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
#     Description  : Set Brm BackupManager
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
local $time=`date '+%FT04:04:04.666%:z'`;
local $pdkdate=`date '+%FT%T'`;
chomp $time;
chomp $pdkdate;
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
        $ProductData=&getENVfilevalue($ProductDatafile,"$MIMVERSION");
        @productData = split( /:/, $ProductData );
        $productNumber=$productData[0];
        $productRevision=$productData[1];
        chomp $pdkdate;

	# build mml script
	@MOCmds=();
	@MOCmds=qq^
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsBrM:BrM=1,RcsBrM:BrmBackupManager=1"
    exception none
    nrOfAttributes 2
    "backupType" String "Systemdata"
    "backupDomain" String "System"
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsBrM:BrM=1,RcsBrM:BrmBackupManager=1,RcsBrM:BrmBackupLabelStore=1"
    exception none
    nrOfAttributes 4
    "lastRestoredBackup" String "${LTENAME}_Restored"
    "lastImportedBackup" String "${LTENAME}_Imported"
    "lastExportedBackup" String "${LTENAME}_Exported"
    "lastCreatedBackup" String "${LTENAME}_Created"
)
SET
(
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsBrM:BrM=1,RcsBrM:BrmBackupManager=1,RcsBrM:BrmBackup=1"
    exception none
    nrOfAttributes 3
    "backupName" String "1"
    "creationType" Integer 3
    "creationTime" String "$time"
    "swVersion" Array Struct 1
        nrOfElements 6
        "productName" String "$LTENAME"
        "productNumber" String "$productNumber"
        "productRevision" String "$productRevision"
        "productionDate" String "2017-11-29T09:32:56"
        "description" String "RadioNode"
        "type" String "RadioNode"

)	^;# end @MO
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
# remove mo script
unlink @NETSIMMOSCRIPTS;
unlink "$NETSIMMMLSCRIPT";
print "... ${0} ended running at $date\n";
################################
# END
################################

