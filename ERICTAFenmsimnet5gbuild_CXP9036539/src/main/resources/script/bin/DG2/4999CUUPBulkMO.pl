#!/usr/bin/perl
#####################################################################################
#     Version      : 1.0
#     Revision     : CXP 903 6539-1-33
#     Author       : xmitsin
#     JIRA         : NSS-34841
#     Description  : Updating Code
#     Date         : 10th May 2021
####################################################################################
#     Version      : 1.1
#     Revision     : CXP 903 6539-1-34
#     Author       : zhainic
#     JIRA         : NSS-35983
#     Description  : Updating Code
#     Date         : 10th Jun 2021
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
local $date=`date`,$pdkdate=`date '+%FT%T'`,$LTENAME;
local $dir=cwd,$currentdir=$dir."/";
local $scriptpath="$currentdir";
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local $MOSCRIPT="$scriptpath".${0}.".mo";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local @MOCmds,@MMLCmds,@netsim_output;
local $NETSIMMOSCRIPT,$NETSIMMMLSCRIPT,$NODECOUNT=1,$NODENUM=0,$TYPE;
local $DG2NUMOFRBS=&getENVfilevalue($ENV,"DG2NUMOFRBS");
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
#my $counter=1;
#my $counts=3;

while ($NODECOUNT<=$DG2NUMOFRBS){

    $LTENAME=&getLTESimStringNodeName($LTE,$NODECOUNT);
    $MIMVERSION=&queryMIM($SIMNAME,$NODECOUNT);
    $MIMVERSION = "MSRBS-V2-".$MIMVERSION;
    $ProductDatafile="ProductData.env";
    $ProductData=&getENVfilevalue($ProductDatafile,"$MIMVERSION");
    @productData = split( /:/, $ProductData );
    $productNumber=$productData[0];
    $productRevision=$productData[1];
    chomp $pdkdate;
    $NODENUM=((($LTE - 1) * $DG2NUMOFRBS) + $NODECOUNT);
    #Check for Product Data information
    if (($productNumber eq "ERROR")||($productRevision eq "")) {#start if
       print "ERROR : Product data information missing, the script will exit\n\n";
       exit;
       }#end if
    
    my $counter=1;
    my $counts=3;
   
    for ($idCounter=1;$idCounter<=12;$idCounter++)

{

        # build mml script
        @MOCmds=();
        @MOCmds=qq^ CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUUP:GNBCUUPFunction=1,GNBCUUP:S1UTermination=1"
    identity "$idCounter"
    moType GNBCUUP:S1ULink
    exception none
    nrOfAttributes 2
    "remoteEndPoint" String "127.0.0.$counts"
    "localEndPoint" String "127.0.0.$counter"
)
^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$counter ++;
$counts ++;
#$idCounter ++;

}###end For S1ULink ipv4

for ($idCounter=13;$idCounter<=18;$idCounter++)

{

        # build mml script
        @MOCmds=();
        @MOCmds=qq^ CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUUP:GNBCUUPFunction=1,GNBCUUP:S1UTermination=1"
    identity "$idCounter"
    moType GNBCUUP:S1ULink
    exception none
    nrOfAttributes 2
    "remoteEndPoint" String "2001:1b70:82a1:103::64:$counts"
    "localEndPoint" String "2001:1b70:82a1:103::64:$counter"
)
^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$counter ++;
$counts ++;
#$idCounter ++;

}###end For S1ULink ipv6

for ($idCounter=1;$idCounter<=2;$idCounter++)
{

###ComTop:ManagedElement=NR01gNodeBRadio00004,GNBCUUP:GNBCUUPFunction=1,GNBCUUP:RpUserPlaneTermination=1,GNBCUUP:RpUserPlaneLink=1
@MOCmds=qq^ CREATE

(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUUP:GNBCUUPFunction=1"
    identity "$idCounter"
    moType GNBCUUP:EP_NgU
    exception none
    nrOfAttributes 2
    "remoteEndPoint" String "2001:1b70:82a1:103::64:$counts"
    "localEndPoint" String "2001:1b70:82a1:103::64:$counter"
)
   ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$counter ++;
$counts ++;
}###end For EP_NGU ipv6

for ($idCounter=3;$idCounter<=6;$idCounter++)
{

###ComTop:ManagedElement=NR01gNodeBRadio00004,GNBCUUP:GNBCUUPFunction=1,GNBCUUP:RpUserPlaneTermination=1,GNBCUUP:RpUserPlaneLink=1
@MOCmds=qq^ CREATE

(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUUP:GNBCUUPFunction=1"
    identity "$idCounter"
    moType GNBCUUP:EP_NgU
    exception none
    nrOfAttributes 2
    "remoteEndPoint" String "127.0.0.$counts"
    "localEndPoint" String "127.0.0.$counter"
)
   ^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$counter ++;
$counts ++;
}###end For EP_NGU ipv4

my $counter=31;
my $counts=33;
for ($idCounter=1;$idCounter<=5;$idCounter++)
{

@MOCmds=qq^ CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUUP:GNBCUUPFunction=1,GNBCUUP:RpUserPlaneTermination=1"
    identity "$idCounter"
    moType GNBCUUP:RpUserPlaneLink
    exception none
    nrOfAttributes 2
    "remoteEndPoint" String "127.0.0.$counts"
    "localEndPoint" String "127.0.0.$counter"
)
^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$counter ++;
$counts ++;
}###end For RpUserPlaneTermination ipv4

for ($idCounter=6;$idCounter<=8;$idCounter++)
{

@MOCmds=qq^ CREATE
(
    parent "ComTop:ManagedElement=$LTENAME,GNBCUUP:GNBCUUPFunction=1,GNBCUUP:RpUserPlaneTermination=1"
    identity "$idCounter"
    moType GNBCUUP:RpUserPlaneLink
    exception none
    nrOfAttributes 2
    "remoteEndPoint" String "2001:1b70:82a1:103::64:$counts"
    "localEndPoint" String "2001:1b70:82a1:103::64:$counter"
)
^;# end @MO
    $NETSIMMOSCRIPT=&makeMOscript("append",$MOSCRIPT.$NODECOUNT,@MOCmds);
$counter ++;
$counts ++;
}###end For RpUserPlaneTermination ipv6

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
