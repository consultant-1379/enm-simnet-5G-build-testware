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
#     Description  : Create PM Event Job Mos
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
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
local $PRESETPMJOBCOUNT=6;
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
	
	local $pmJobCounter=1;
	while ($pmJobCounter<=$PRESETPMJOBCOUNT){
		local $eventJobId=9999+$pmJobCounter;
		local $description="normal priority cell trace event job";
		local $jobControl=0;
		local $eventGroupRef="";
		if ($pmJobCounter==5){
			$description="high priority cell trace event job";
		}
		if ($pmJobCounter==6){
			$description="continuous cell trace event job";
			$jobControl=1;
			$eventGroupRef="ManagedElement=$LTENAME,SystemFunctions=1,PmEventM=1,EventProducer=Lrat,EventGroup=CCTR";
		}
		# build mml script 
		@MOCmds=();
		@MOCmds=qq( CREATE
		(
			parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=Lrat"
			identity "$eventJobId"
			moType RcsPMEventM:EventJob
			exception none
			nrOfAttributes 15
			"eventJobId" String "$eventJobId"
			"description" String "$description"
			"eventFilter" Array Struct 1
				nrOfElements 2
				"filterName" String ""
				"filterValue" String ""

			"requestedJobState" Integer 2
			"currentJobState" Integer 2
			"fileOutputEnabled" Boolean true
			"reportingPeriod" Integer 5
			"streamOutputEnabled" Boolean false
			"jobControl" Integer 0
			"eventTypeRef" Array Ref 0
			"fileCompressionType" Integer 0
		);
		);# end @MO   
   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	   
   

  if ($pmJobCounter==6){  
  @MOCmds=qq ( SET
	     (
    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=Lrat,RcsPMEventM:EventJob=10005"
    exception none
    nrOfAttributes 1
    "eventGroupRef" Array Ref 1
        ManagedElement=$LTENAME,SystemFunctions=1,PmEventM=1,EventProducer=Lrat,EventGroup=CCTR
	     );
	     );# end @MO 
$NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
	   
   
  }
push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT); 	
	$pmJobCounter++;
	} # end PM Job Count loop
	  
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

