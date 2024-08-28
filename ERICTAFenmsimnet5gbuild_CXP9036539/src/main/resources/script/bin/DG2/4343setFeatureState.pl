#!/usr/bin/perl
#####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-42
#
#     Author       : Nainesha Chilakala
#
#     JIRA         : NSS-38085
#
#     Description  : Support for Multi Cell Types
#
#     Date         : Dec 2021
#
####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Set FeatureState
#
#     Date         : March 2019
#
####################################################################################

####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../../lib/cellconfig";
use Cwd;
use LTE_CellConfiguration;
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
#---------------------------------------------------------------
sub getCellType{
    my ($simNum,$nodeNum)=@_;
    my $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
    my $cellDistributionFile=$currentdir."../../customdata/cellDistribution.csv";
    my $nodeNumInNetwork=((($simNum - 1)*$DG2NUMOFRBS) + $nodeNum);
    my $cellType = `cat $cellDistributionFile | grep -w "NODE=$nodeNumInNetwork" | head -1 | cut -d ';' -f2 | cut -d '=' -f2`;
    return($cellType);
}
#----------------------------------------------------------------
local $date=`date`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $whilecounter;
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $NETWORKCELLSIZE=&getENVfilevalue($ENV,"NETWORKCELLSIZE");
local $STATICCELLNUM=&getCellType($LTE,$NODECOUNT),$CELLCOUNT;
local $CELLNUM;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $nodecountinteger,$tempcellnum;
local $nodecountfornodestringname;
local $element,$secequipnum;
local $nodenum,$sharingcabinetid,$ismanaged,$mixedmoderadio,$licensestatemixedmode;
local @RBS6KDATA=&createRBS6Kdata($NETWORKCELLSIZE,$STATICCELLNUM);
# get cell configuration ex: 6,3,3,1 etc.....
local $CELLPATTERN=&getENVfilevalue($ENV,"CELLPATTERN");
local @CELLPATTERN=split(/\,/,$CELLPATTERN);
local (@PRIMARY_NODECELLS)=&buildNodeCells(@CELLPATTERN,$NETWORKCELLSIZE);

###################
# Integrity Check
####################
if (-e "$NETSIMMOSCRIPT"){
    unlink "$NETSIMMOSCRIPT";}
#if (@RBS6KDATA<2){
#    print "ERROR : there is no RBS6K data generated\n";exit; 
#}# end if
  
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

$nodecountinteger=&getLTESimIntegerNodeNum($LTE,$NODECOUNT,$DG2NUMOFRBS);
# nasty workaround for error in &getLTESimStringNodeName
if($nodecountinteger>$DG2NUMOFRBS){
     $nodecountfornodestringname=(($LTE-1)*$DG2NUMOFRBS)+$NODECOUNT;
}# end if
else{$nodecountfornodestringname=$nodecountinteger;}# end workaround
################################
################################
# set Feature state for Pci
################################
@MOCmds=();
@MOCmds=qq^ SET
      (
      mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsLM:Lm=1,RcsLM:FeatureState=1"
       exception none
       nrOfAttributes 3
		"featureState" Integer 1
		"licenseState" Integer 1
		"serviceState" Integer 1
      )
    ^;# end @MO
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
################################

$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
################################
# end Feature state for Pci
################################


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

