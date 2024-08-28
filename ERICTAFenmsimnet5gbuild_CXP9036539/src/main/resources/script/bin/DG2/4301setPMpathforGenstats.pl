#!/usr/bin/perl
####################################################################################
#     Version     : 1.4
#
#     Revision 	  : CXP 903 6539-1-57
#
#     Author 	  : SaiKrishna Tulluri
#
#     JIRA	  : NSS-41458
#
#     Description : Updating the NrEtcm ,NrFtem , NrPm Events mo's
#
#     Date 	  : Nov 2022
####################################################################################
#     Version     : 1.3
#
#     Revision 	  : CXP 903 6539-1-53
#
#     Author 	  : Tarun Sai Sivapuram
#
#     JIRA	  : NSS-39689
#
#     Description : Creating and Adding the NrEtcm ,NrFtem , NrPm Events mo's
#
#     Date 	  : May 2022
#####################################################################################
#     Version     : 1.2
#
#     Revision    : CXP 903 6539-1-49
#
#     Author      : Tarun Sai Sivapuram
#
#     JIRA        : NSS-39294
#
#     Description : Added the Nr Pm Events,Lte Pm Events mo's 
#
#     Date        : April 2021
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Set PM File Location for Genstats
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

if(index($SIMNAME, NRAT) != -1) {
@sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /NR/, $sim1[0];
 @sim4= split /NR/, $sim1[1];
 $MIMVERSION="$sim3[1]";
 $NODETYPE="gNodeBRadio";
 $NETYPE="MSRBS-V2 ${sim3[1]}";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NODETYPE is $NODETYPE\n";
print "NETYPE is $NETYPE\n";
}
elsif(index($SIMNAME, MULTIRAT) != -1) {
@sim1= split /x/, $SIMNAME;
 @sim2= split /-/, $sim1[1];
 @sim3= split /NR/, $sim1[0];
 @sim4= split /NR/, $sim1[1];
 $MIMVERSION="$sim3[1]";
 $NODETYPE="gNodeBRadio";
 $NETYPE="MSRBS-V2 ${sim3[1]}";
print "Simname is $SIMNAME\n";
print "MIMVERSION is $MIMVERSION\n";
print "NODETYPE is $NODETYPE\n";
print "NETYPE is $NETYPE\n";
}

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
chomp($templateWithoutZip);

print "Node Template Link:\n";
print "$template\n";
print "Node Template file is\n";
print "$templateNode\n";
print "Node Template name Without Zip is \n";
print "$templateWithoutZip \n \n";

my $etcmcucp=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "etcm_cucp" | awk -F "cucp_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $etcmcuup=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "etcm_cuup" | awk -F "cuup_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $etcmdu=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "etcm_du" | awk -F "du_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $ftemcucp=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "ftem_cucp" | awk -F "cucp_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $ftemcuup=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "ftem_cuup" | awk -F "cuup_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $ftemdu=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "ftem_du" | awk -F "du_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $pmcucp=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "pm_event_package_cucp" | awk -F "cucp_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $pmcuup=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "pm_event_package_cuup" | awk -F "cuup_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;
my $pmdu=`ls /netsim/netsimdir/$templateWithoutZip/Events/ | grep "pm_event_package_du" | awk -F "du_" '{print \$2}' | cut -d "." -f1 | sed -e "s/_/./g"`;

chomp($etcmcucp);
chomp($etcmcuup);
chomp($etcmdu);
chomp($ftemcucp);
chomp($ftemcuup);
chomp($ftemdu);
chomp($pmcucp);
chomp($pmcuup);
chomp($pmdu);

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

	# build mml script 
	@MOCmds=();
	@MOCmds=qq( SET
	(                          
	    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPm:Pm=1,RcsPm:PmMeasurementCapabilities=1"
	    exception none
	    nrOfAttributes 1
	    "fileLocation" String "/c/pm_data/"
	)
	SET
	(
	    mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsPMEventM:PmEventM=1,RcsPMEventM:EventProducer=Lrat,RcsPMEventM:FilePullCapabilities=2"
	    exception none
	    nrOfAttributes 1
	    "outputDirectory" String "/c/pm_data/"		
	)
        CREATE
        (
        parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:PmEventSpecification=1"
        identity "1"
        moType RcsRem:LtePmEvents
        exception none
        nrOfAttributes 1
        "ltePmEventsId" String "1"
        )

        CREATE
        (
        parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:PmEventSpecification=1"
        identity "1"
        moType RcsRem:NrPmEvents
        exception none
        nrOfAttributes 1
        "nrPmEventsId" String "1"
        )
         CREATE
        (
           parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:PmEventSpecification=1"
           identity "3"
           moType RcsRem:NrPmEvents
           exception none
           nrOfAttributes 3
           "nrPmEventsId" String "3"
           "managedFunction" String "DU"
           "version" String "$pmdu"
        )
        CREATE
        (
           parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:EbsCounterSpecification=1"
           identity "3"
           moType RcsRem:NrEtcm
           exception none
           nrOfAttributes 3
           "nrEtcmId" String "3"
           "version" String "$etcmdu"
           "managedFunction" String "DU"
        )
        CREATE
        (
          parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:EbsCounterSpecification=1"
          identity "2"
          moType RcsRem:NrEtcm
          exception none
          nrOfAttributes 3
          "nrEtcmId" String "2"
          "version" String "$etcmcuup"
          "managedFunction" String "CUUP"
        )
        CREATE
        (
           parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:EbsCounterSpecification=1"
           identity "2"
           moType RcsRem:NrFtem
           exception none
           nrOfAttributes 3
          "nrFtemId" String "2"
          "version" String "$ftemcuup"
           "managedFunction" String "CUUP"
        )
        CREATE
        (
           parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:EbsCounterSpecification=1"
           identity "3"
           moType RcsRem:NrFtem
           exception none
           nrOfAttributes 3
           "nrFtemId" String "3"
           "version" String "$ftemdu"
           "managedFunction" String "DU"
       )
       CREATE
       (
           parent "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:PmEventSpecification=1"
           identity "2"
           moType RcsRem:NrPmEvents
           exception none
           nrOfAttributes 3
           "nrPmEventsId" String "2"
           "managedFunction" String "CUUP"
           "version" String "$pmcuup"
        )
       SET
       (
           mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:EbsCounterSpecification=1,RcsRem:NrEtcm=1"
           exception none
           nrOfAttributes 2
           "version" String "$etcmcucp"
           "managedFunction" String "CUCP"
       )
       SET
       (
           mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:EbsCounterSpecification=1,RcsRem:NrFtem=1"
           exception none
           nrOfAttributes 2
           "version" String "$ftemcucp"
           "managedFunction" String "CUCP"
        )
         SET
       (
           mo "ComTop:ManagedElement=$LTENAME,ComTop:SystemFunctions=1,RcsSysM:SysM=1,RcsRem:RuntimeExportM=1,RcsRem:PmEventSpecification=1,RcsRem:NrPmEvents=1"
           exception none
           nrOfAttributes 2
           "version" String "$pmcucp"
           "managedFunction" String "CUCP"
       );
		);# end @MO   
   $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);

push(@NETSIMMOSCRIPTS, $NETSIMMOSCRIPT); 	
	$pmJobCounter++;

	  
################################################
# build mml script 
################################################
  @MMLCmds=(".open ".$SIMNAME,
            ".select ".$LTENAME,
            ".start ",
            "pmdata:disable;",
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

