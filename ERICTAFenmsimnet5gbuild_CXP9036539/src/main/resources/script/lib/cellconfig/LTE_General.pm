#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_General (v1.1)
#
#     Description : Contains all general/netsim functions.
#
#     Functions : getENVfilevalue("TEST.env","SIMTYPE")
#                 getLTESimIntegerNodeNum($LTE,$COUNT,$NUMOFRBS)
#                 getLTESimStringNodeName($LTE,$COUNT)
#                 makeMMLscript($MOSCRIPT,@MOCmds)
#                 makeMOscript($MMLSCRIPT,@MMLCmds);
#                 listNodePrimaryCells(@nodecells);
#                 listNodeAdjacentCells(@nodecells);
#############################################################################
# Revision : 1
#
# Description : Updated function getLTESimNum tso that the last simluation of
# the network is extended to 75 (60k LTE 15B) instead of the previous 48 for
# the 30k network of LTE 12.2
#
# Implementation: Updated ttlxsimnum to 75
#
# Dev : ecasjim
#
# Date : 21/01/15
#############################################################################
# Version2    : LTE 15B
# Revision    : CXP 903 0491-136-1
# Purpose     : Add DG2 node to multisims script
# Description : Update getLTESimStringNodeName, getENVfilevalue, makeMMLscript
# Date        : 03 Apr 2015
# Who         : edalrey
#############################################################################
#############################################################################
# Version3    : LTE 16.5
# Revision    : CXP 903 0491-199-1
# Jira        : NSS-1269
# Purpose     : WRAN External network configuration for ENM for 16B
# Description : To support the Scalable Network Feature removed hardcoded values
#		and added corresponding logic to get the values at runtime
# Date        : Feb 2016
# Who         : xsrilek
#############################################################################
#############################################################################
# Version4    : LTE 16.5
# Revision    : CXP 903 0491-202-1
# Jira        : NSS-2417
# Purpose     : To build simulations with number 75 and above
# Description : Updated the variable $ttlxsimnum to support sim
#               with number 75 and above
# Date        : March 2016
# Who         : xkatmri
#############################################################################
#############################################################################
# Version5    : LTE 16.8
# Revision    : CXP 903 0491-222-1
# Jira        : NSS-2417
# Purpose     : To build 60K network
# Description : Updated the variable $ttlxsimnum to support sim number 150
# Date        : May 2016
# Who         : xkatmri
#############################################################################
#############################################################################
# Version6    : LTE 17A
# Revision    : CXP 903 0491-238-1
# Jira        : NSS-1954
# Purpose     : To reduce number of cdma2000 and cdma200001 relations
#               and proxies
# Description : As per the Generic NRM the cdma2000 cdma20001Rtt
#               relations and proxies are higher, So reducing cdma2000
#               relations and proxies and turnning off the feature of
#               cdma20001Rtt
# Date        : July 2016
# Who         : xsrilek
#############################################################################
#############################################################################
# Version7    : LTE 17B
# Revision    : CXP 903 0491-288-1
# Jira        : NSS-8645
# Purpose     : Increase RetSubUnit to 1.5 per cell
# Description : To increase the RetSubUnits average for the network
#               to be 1.5
# Date        : March 2017
# Who         : xsrilek
####################################################################
 # Version8    : LTE 18B
 # Revision    : CXP 903 0491-322-1
 # Jira        : NSS-16469
 # Purpose     : To build sims upto 500
 # Description : Building sim number upto 500
 # Date        : Dec 2017
 # Who         : xkatmri
 ####################################################################
#############################################################################
#    END LIB MODULE HEADER
#############################################################################
##########################################
#  Environment
##########################################
package LTE_General;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(getDg2MimVersionFromSimNameByNodeCount getAllNodeIPAddress createRBS6Kdata getNetworkExtUtranCellID getNodeCellIndex getEUtranFreqID_NUM getLTESimNum listNodePrimaryCells listNodeAdjacentCells getENVfilevalue makeMOscript makeMMLscript getLTESimIntegerNodeNum getLTESimStringNodeName getERBSTotalCount queryMIM isgreaterthanMIM uniq isSimLTE checkMIMVersionRange isSimflaggedasTDDinCONFIG isCdma20001xRttYes isCdma2000Yes isNodeNumLocInReqPer getCbrsType);
use Cwd;
use LTE_OSS15;
use LTE_NodeConfigurability;
##########################################
# Vars
##########################################
my $gendelimeter=".."x1;
#my $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
##########################################
# funcs
##########################################
#-----------------------------------------
#  Name : getAllNodeIPAddress
#  Description : returns all node ip
#  addresses for all simulations on the
#  netsim server
#  Note : all LTE network netsim servers are listed
#         in config file /dat/CONFIG.env
#  NETWORKSERVERS=netsimlin315:netsimlin316
#  NETSIMLOGIN=netsim
#  NETSIMPASSWORD=netsim
#  Params : $netsimservers,$netsimlogin,$netsimpassword
#  Example :@allservernodeips=&getAllNodeIPAddress($netsimservers,$netsimlogin,$netsimpassword)
#  Return : returns an array with all $nodename..$ipaddresses for the netsim server
#-----------------------------------------
sub getAllNodeIPAddress{
    local ($netsimservers,$netsimlogin,$netsimpassword)=@_;
    local @servernodeipaddress=();
    local $arr_counter=0,$arr_element;
    local $cli;
    # get the LTE network servers
    local @networkservers=split(/\:/,$netsimservers);
    local @raw_netsim_nes_ips=(),$temp_raw_ips=();
    local $nodename="",$ipadd="";
    local $element="",$output;
    local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
    local $command="echo .show allsimnes|$NETSIM_INSTALL_PIPE";

    foreach $element(@networkservers){
        $element=~s/^\s+//;$element=~s/\s+$//;
        @temp_raw_ips=();
        $output="";
        # Connect to host
        $cli = new Control::CLI("TELNET");
        $cli->connect($element);
        # Perform login
        $cli->login(    Username        => $netsimlogin,
                        Password        => $netsimpassword,
                   );
        # Send a command and read the resulting output
        $output = $cli->cmd("xterm");
        $output=$cli->cmd($command);
        @temp_raw_ips=split(/$element/,$output);
        local $ip1,$ip2,$ip3,$ip4;
        foreach $arr_element(@temp_raw_ips){
            if ($arr_element !~ /([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)/) {
                       next;
            }# end if
            $servernodeipaddress[$arr_counter]="$arr_element";
            $arr_counter++;
        }# end foreach
        $cli->disconnect($element);
    }# end foreach

    if (@servernodeipaddress==0){$servernodeipaddress[0]="ERROR";return(@servernodeipaddress);}
    return(@servernodeipaddress);
}# end getAllNodeIPAddress
#------------------------------------------------------
#  Name : createRBS6Kdata
#  Description : apportions RBS6K cabinet
#  sharing across a LTE network in accordance
#  with a predefined cabinet sharing algorithm
#  as defined in CDM LMI-11:0179
#  Params : NETWORKCELLSIZE and CELLNUM
#  Example :&createRBS6Kdata($NETWORKCELLSIZE,$CELLNUM)
#  Return : returns a populated array containing
#  all data relevant to RBS6Kcabinet sharing in a LTE
#  network
#-------------------------------------------------------
sub createRBS6Kdata{
    local ($networkcellsize,$cellnum)=@_;
    local $element,$rbs6kdatacounter=0;
    local @RBS6KDATA=();
    local $match=0;
    # rbs6k specific data items as per CDM LMI-11:0179
    local $RBS6K_unique=20,$RBS6K_double=60,$RBS6K_triple=20; # % value
    local $MIXEDMODESET=60; # % value
    local $ERBSNodeNum=1,$TtlERBSNodeNum="ERROR";
    local $unique_ERBS,$double_ERBS,$triple_ERBS;
    local $unique_ERBS_range,$double_ERBS_range,$triple_ERBS_range;
    local $double_ERBS_mixedmodeset,$triple_ERBS_mixedmodeset;
    local $double_ERBS_mixedmodeset_range,$triple_ERBS_mixedmodeset_range;
    local $double_flag=0,$triple_flag=0;
    local $MixedModeRadio="false",$licenseStateMixedMode="disabled",$ismanaged="false";
    # rbs6kdata boundaries
    $TtlERBSNodeNum=$networkcellsize/$cellnum;
    if($TtlERBSNodeNum=~/\./){
       $TtlERBSNodeNum="ERROR..invalid total ERBS nodes $TtlERBSNodeNum";
       return($TtlERBSNodeNum);
    }# end if

    # set ERBS max node ranges for cabinet ids
    $unique_ERBS=int(($TtlERBSNodeNum*$RBS6K_unique)/100);
    $double_ERBS=int((($TtlERBSNodeNum*$RBS6K_double)/100)+($unique_ERBS));
    $triple_ERBS=int(($TtlERBSNodeNum*$RBS6K_triple)/100+($double_ERBS));

    # set cabinet id ranges per mode sharing type
    $uniquecabinetid=1;$sharingcabinetid=$unique_ERBS+$uniquecabinetid;

    # set ERBS node ranges for mixed mode set
    $double_ERBS_mixedmodeset=int(($TtlERBSNodeNum*$RBS6K_double)/100)*($MIXEDMODESET/100)+$unique_ERBS;
    $triple_ERBS_mixedmodeset_nodenum=int(($TtlERBSNodeNum*$RBS6K_triple)/100)*($MIXEDMODESET/100);
    $start_triple_ERBS_mixedmodeset=$double_ERBS+1;
    $end_triple_ERBS_mixedmodeset=$triple_ERBS_mixedmodeset_nodenum+$double_ERBS+1;

    $RBS6KDATA[0]="NodeNum..sharingcabinetid..ismanaged..MixedModeRadio..licenseStateMixedMode";
    # populate rbs6k data
    while($ERBSNodeNum<=$TtlERBSNodeNum){
      $match=0;
      if (($ERBSNodeNum<=$unique_ERBS)&&($match==0)){ # unique mode sharing type
         $RBS6KDATA[$ERBSNodeNum]="$ERBSNodeNum$gendelimeter$uniquecabinetid$gendelimeter$ismanaged$gendelimeter$MixedModeRadio$gendelimeter$licenseStateMixedMode";
         $uniquecabinetid++;
      }# end if

      if (($ERBSNodeNum>$unique_ERBS)&&($ERBSNodeNum<=$double_ERBS)
         &&($ERBSNodeNum<=$double_ERBS_mixedmodeset)&&($match==0)){ # double WITH mixed mode set
         $ismanaged="true";$MixedModeRadio="true";$licenseStateMixedMode="enabled";
         $RBS6KDATA[$ERBSNodeNum]="$ERBSNodeNum$gendelimeter$sharingcabinetid$gendelimeter$ismanaged$gendelimeter$MixedModeRadio$gendelimeter$licenseStateMixedMode";
         $double_flag++;
         if($double_flag==2){$double_flag=0;$sharingcabinetid++;}
      }# end if

      if (($ERBSNodeNum<=$double_ERBS)&&($ERBSNodeNum>$double_ERBS_mixedmodeset)
         &&($ERBSNodeNum<$start_triple_ERBS_mixedmodeset)&&($match==0)){ # double WITHOUT mixed mode set
         $ismanaged="true";$MixedModeRadio="false";$licenseStateMixedMode="disabled";
         $RBS6KDATA[$ERBSNodeNum]="$ERBSNodeNum$gendelimeter$sharingcabinetid$gendelimeter$ismanaged$gendelimeter$MixedModeRadio$gendelimeter$licenseStateMixedMode";
         $double_flag++;
         if($double_flag==2){$double_flag=0;$sharingcabinetid++;}
      }# end if

      if (($ERBSNodeNum>$double_ERBS)&&($ERBSNodeNum<=$end_triple_ERBS_mixedmodeset)
         &&($match==0)){ # triple WITH mixed mode set
         $ismanaged="true";$MixedModeRadio="true";$licenseStateMixedMode="enabled";
         $RBS6KDATA[$ERBSNodeNum]="$ERBSNodeNum$gendelimeter$sharingcabinetid$gendelimeter$ismanaged$gendelimeter$MixedModeRadio$gendelimeter$licenseStateMixedMode";
         $double_flag++;
         if($double_flag==3){$double_flag=0;$sharingcabinetid++;}
      }# end if

      if (($ERBSNodeNum>$end_triple_ERBS_mixedmodeset)&&($ERBSNodeNum<=$triple_ERBS)
         &&($match==0)){ # triple WITHOUT mixed mode set
         $ismanaged="true";$MixedModeRadio="false";$licenseStateMixedMode="disabled";
         $RBS6KDATA[$ERBSNodeNum]="$ERBSNodeNum$gendelimeter$sharingcabinetid$gendelimeter$ismanaged$gendelimeter$MixedModeRadio$gendelimeter$licenseStateMixedMode";
         $double_flag++;
         if($double_flag==3){$double_flag=0;$sharingcabinetid++;}
      }# end if

     $ERBSNodeNum++;
    }# end while
    return(@RBS6KDATA);
}# end createRBS6Kdata
#------------------------------------------------------------------------------------------------------------------------------------------
#  Name : getNetworkExtUtranCellID
#  Description : builds an ExternalUtranCell ID list
#  based on alogorithm as defined in LMI-11:0511
#  section UtranCellRelation - lte_gen_net_cfg_37 & 29
#  The list build has cellid formats of nodenum-cellnum
#  eg. node 1 cell 2 is referenced in the list as 1-2
#      node 2000 cell 3 is referenced in the lst as 2000-3
#  Params : $IRATHOMENABLED,$IRATHOMTTLUTRANCELLS,$NODENUMBERNETWORKNINETYFIVE,$EXTCELLSPERFREQNINETYFIVE,$NODENUMBERNETWORKFIVE,$EXTCELLSPERFREQFIVE
#  Example :&getNetworkExtUtranCellIDs($IRATHOMENABLED,$IRATHOMTTLUTRANCELLS,$NODENUMBERNETWORKNINETYFIVE,$EXTCELLSPERFREQNINETYFIVE,$NODENUMBERNETWORKFIVE,$EXTCELLSPERFREQFIVE)
#  Return : returns a populated array containing
#  all network ExternalUtranCell IDs referenced by
#  nodenum-cellnum eg. 2000-3
#  array row header = nodenum-utranfrequency-cellnum-extutrancellid
#                       eg: 1-1-1-20000
#                           1-1-2-20001
#                           1-1-3-20002
#------------------------------------------------------------------------------------------------------------------------------------------
sub getNetworkExtUtranCellID{
    #----------------------------------------------------------------
    # Update : LTE 13B
    # Purpose     : Sprint 2.2 External Utran Network Inconsistencies
    # Description : create 500k external utran cells and relations
    #               and amend master proxy inconsistencies
    #----------------------------------------------------------------
    local ($IRATHOMENABLED,$IRATHOMTTLUTRANCELLS,$NODENUMBERNETWORKNINETYFIVE,$EXTCELLSPERFREQNINETYFIVE,$NODENUMBERNETWORKFIVE,$EXTCELLSPERFREQFIVE)=@_;
    #----------------------------------------------------------
    # Update : LTE13B Sprint 0.7  Irathom LTE WCDMA
    # simulated Utran proxy cid reset to start at 20000
    # to avoid clash with Irathom defined external proxies cid
    #----------------------------------------------------------
    local $extcellidcounter=20000;
    #local $ttlnumberofirathomnodes=625; # LTE13B
    #local $ttlnumberofirathomnodes=496; # LTE14B.1
    local $ttlnumberofirathomnodes=&getTtlIrathomNodes($IRATHOMTTLUTRANCELLS,$NODENUMBERNETWORKNINETYFIVE,$EXTCELLSPERFREQNINETYFIVE,$NODENUMBERNETWORKFIVE,$EXTCELLSPERFREQFIVE);
    local $nodecounter=1;
    local $totalnetworknodes=$NODENUMBERNETWORKNINETYFIVE+$NODENUMBERNETWORKFIVE;
    local $resetcellidcounter=20000; # LTE14B.1 SNAG List - too Many ExternalUtranCells - reduced by 20K

    # ensure $nodecounter offset is increased by 496 if irathom enabed
    # ie. Irathom = 496 irathom nodes/10000 external utran cells
    if (uc($IRATHOMENABLED) eq "YES"){
        $nodecounter=$ttlnumberofirathomnodes+$nodecounter;
        $totalnetworknodes=$totalnetworknodes+$ttlnumberofirathomnodes;
    }# end if

    local $arrayindex=0;
    local $tempcellnum,$cellnum;
    local @EXTUTRANCELLID=();
    local $ExtUtranCellPerNode;
    local $maxUtranFreq=6;

    # ensure $extcellid is <=20000 throughout the entire network
    # and include for available Irathom cells if included in the network
    local $MAXNodesWithUniqueExtUtranCellID=($extcellidcounter+(2*$IRATHOMTTLUTRANCELLS));
    if (uc($IRATHOMENABLED) eq "YES"){
        $MAXNodesWithUniqueExtUtranCellID=$MAXNodesWithUniqueExtUtranCellID-$IRATHOMTTLUTRANCELLS;
    }# end if IRATOMENABLED

    local $UtranFrequency;
    if($totalnetworknodes==0){$EXTUTRANCELLID[0]="ERROR - invalid networkcellsize of $networkcellsize";}

    while($nodecounter<=$totalnetworknodes){
          $xtempcellnum=1;$tempcellnum=1;
          $UtranFrequency=1;
          # determine 6 UtranFrequency * ExternalUtranCell per Node for breakdown of network
          if($nodecounter<=$NODENUMBERNETWORKNINETYFIVE){
             $ExtUtranCellPerNode=($EXTCELLSPERFREQNINETYFIVE*$maxUtranFreq);
             $cellnum=$EXTCELLSPERFREQNINETYFIVE;
          }# end if
          if($nodecounter>$NODENUMBERNETWORKNINETYFIVE){
             $ExtUtranCellPerNode=($EXTCELLSPERFREQFIVE*$maxUtranFreq);
             $cellnum=$EXTCELLSPERFREQFIVE;
          }# end if

          while($xtempcellnum<=$ExtUtranCellPerNode){# get externalutrancellid
                if($tempcellnum>$cellnum){$tempcellnum=1;$UtranFrequency++;}
                $EXTUTRANCELLID[$arrayindex]="$nodecounter-$UtranFrequency-$tempcellnum-$extcellidcounter";
                $xtempcellnum++;$extcellidcounter++;$arrayindex++;
                $tempcellnum++;
                # reset cellid
                #print "DEBUG $extcellidcounter..$MAXNodesWithUniqueExtUtranCellID\n";
                if($extcellidcounter > $MAXNodesWithUniqueExtUtranCellID){
                     $extcellidcounter=$resetcellidcounter; # LTE14B.1 SNAG List - too Many ExternalUtranCells - reduced by 20K
                }# end inner if
          }# end inner while
         $nodecounter++;
    }# end outer while
    return(@EXTUTRANCELLID);
}# end getNetworkExtUtranCellID
sub getTtlIrathomNodes{
    local ($IRATHOMTTLUTRANCELLS,$NODENUMBERNETWORKNINETYFIVE,$EXTCELLSPERFREQNINETYFIVE,$NODENUMBERNETWORKFIVE,$EXTCELLSPERFREQFIVE)=@_;
    local $CELLPATTERN=&getENVfilevalue($ENV,"CELLPATTERN");
    local @CELLPATTERN=split(/\,/,$CELLPATTERN);
    local $nodeCountInteger=0;
    local $utranCellsCounter=0;
    local $cell=0;
    local $totalNodesinNetwork=$NODENUMBERNETWORKNINETYFIVE+$NODENUMBERNETWORKFIVE;
    local $totalNodesInPattern = @CELLPATTERN;
    local @networkPattern=();

    if($totalNodesinNetwork<=$totalNodesInPattern){
        @networkPattern=@CELLPATTERN;
    }
    else{
        while(@networkPattern<$totalNodesinNetwork)
        {
            push @networkPattern, @CELLPATTERN;
        }
    }
    foreach $cell (@networkPattern){
        if ($utranCellsCounter>=$IRATHOMTTLUTRANCELLS){last};

        if($nodeCountInteger<=$NODENUMBERNETWORKNINETYFIVE){
            $utranCellsCounter=$utranCellsCounter+($cell*$EXTCELLSPERFREQNINETYFIVE);
            $nodeCountInteger++;
        }
        else{
            $utranCellsCounter=$utranCellsCounter+($cell*$EXTCELLSPERFREQFIVE);
            $nodeCountInteger++;
        }
    }
    return $nodeCountInteger;
}
#-----------------------------------------
#  Name : getERBSTotalCount
#  Description : used as a precursor to
#  determine an EUtrancell
#  frequency based on an algorithm which
#  assigns frequency across a network.
#  The frequency is based on cell sharing
#  frequencies between nodes and external
#  nodes where both must have the same
#  frequency to commuicate
#  Node1 freq=1 can communicate with Node2 freq=1
#  Node2 freq=3 cannot communicate with Node2 freq=1
#  The return from this function is passed to
#  the alogrithm namely
#  getEUtranFreqID_NUM which in turn returns
#  a frequency ID num
#  Note : based on a constant NUMOFRBS=160
#  Params : @getERBSTotalCount(ERBSCOUNT,LTE,NUMOFRBS)
#  ERBSCOUNT=nodenum
#  Example : @getERBSTotalCount(12,5,160)
#  Return : returns a LTE node cellindex
#  which can be either 1,2,3 or 4
#-----------------------------------------
sub getERBSTotalCount{
    local ($zznodenum,$zzltesimnum,$zzttlnumofnodes)=@_;
    local $temp,$minus,$ERBSTOTALCOUNT;
    $zzttlnumofnodes=160; # algorithm based on sim consisting of 160 nodes
    $temp=$zzltesimnum*$zzttlnumofnodes;
    $minus=$zzttlnumofnodes;
    $ERBSTOTALCOUNT=($zznodenum+$temp)-$minus;
    return($ERBSTOTALCOUNT);
}# end sub getERBSTotalCount
#-----------------------------------------
#  Name : getNodeCellIndex
#  Description : gets an integer value
#  denoting the cell position in the node
#  which runs 1 thru 4                     c
#  Allows for a node cell to be referenced as
#  $LTENODENAME-$cellindex
#  $LTE00001-1 denotes the first cell in LTE
#  node $LTE00001
#  Params : @primarycells # node primary cells
#  Example :&getNodeCellIndex($cellid,@primarycells)
#  Return : returns a LTE node cellindex
#  which can be either 1,2,3 or 4
#-----------------------------------------
sub getNodeCellIndex{
    local ($zcellid,@zprimarycells)=@_;
    local $cellindex=1;
    foreach $_(@zprimarycells){
            if($_==$zcellid){last;}
            $cellindex++;
    }#end foreach
    if ($cellindex>4)
        {$cellindex="ERROR node cellindex = $cellindex";}
    return($cellindex);
}# end getNodeCellIndex
#-----------------------------------------
#  Name : getEUtranFreqID_NUM
#  Description : gets the EUtran frequency
#  num for a node
## EUtranFreqRelation Algorithm Function ( added in v3)
#
# e.g where NUMOFEUTRANFREQRELATION is 4
#  EUtranFreqRelation=1 one can be points to n1=ERBS01, n2=ERBS05, n3=ERBS09, n4=ERBS13, nx where nx=(x*NUMOFUTRANRELATION) - (NUMOFUTRANRELATION-1)
#  EUtranFreqRelation=2 one can be points to n1=ERBS02, n2=ERBS06, n3=ERBS10, n4=ERBS14, nx where nx=(x*NUMOFUTRANRELATION) - (NUMOFUTRANRELATION-1)
#  EUtranFreqRelation=3 one can be points to n1=ERBS03, n2=ERBS07, n3=ERBS11, n4=ERBS15, nx where nx=(x*NUMOFUTRANRELATION) - (NUMOFUTRANRELATION-1)
#  EUtranFreqRelation=4 one can be points to n1=ERBS04, n2=ERBS08, n3=ERBS12, n4=ERBS16, nx where nx=(x*NUMOFUTRANRELATION) - (NUMOFUTRANRELATION-1)
#
#  EnodeB1-Cell-1 (Freq=1)
#	 EUtranFreqRelation=1 (Freq=1)
#		EUtranCellRelation-1 reference to ENodeB1-Cell2
#		EUtranCellRelation-2 reference to ENodeB1-Cell3
#		EUtranCellRelation-3 reference to ENodeB1-Cell3
#	 EUtranFreqRelation=2 (Freq=2)
#		EUtranCellRelation-4 reference to ENodeB2-Cell1
#		EUtranCellRelation-5 reference to ENodeB2-Cell2
#	 EUtranFreqRelation=3 (Freq=3)
#		EUtranCellRelation-6 reference to ENodeB3-Cell1
#		EUtranCellRelation-7 reference to ENodeB3-Cell2
#	 EUtranFreqRelation=4 (Freq=4)
#		EUtranCellRelation-8 reference to ENodeB4-Cell1
#		EUtranCellRelation-9 reference to ENodeB4-Cell2
#
#  get num of EutranFrequency for each erbs, according to specified percantage
#  Params : $COUNT # nodecount
#           $KEY # "ID"/"NUM"
#  Example :&getEUtranFreqID_NUM($COUNT,$KEY);
#           &getEUtranFreqID_NUM($1,ID);
#  num for a node
#-----------------------------------------
sub getEUtranFreqID_NUM{
  local ($ynodecount,$ykey)=@_;
  # User Configurable
  # Num of nodes/erbs within network
  local $NUMOFSIMS=47;
  local $NUMOFRBS=160;
  local $TOTALNODES=($NUMOFRBS* $NUMOFSIMS);
  # User Configurable
  # Num of frequency per erbs for each band
  local $BAND_A=8;
  local $BAND_B=4;
  local $BAND_C=2;
  local $BAND_D=1;
  # User Configurable
  # Percentage portion of each band
  local $BAND_A_PERC=6;
  local $BAND_B_PERC=6;
  local $BAND_C_PERC=48;
  local $BAND_D_PERC=40;
  # Not User Configurable
  # Calculated percantage portion of each band
  $BAND_B_SWITCH_PERC=$BAND_A_PERC + 0;
  $BAND_C_SWITCH_PERC=$BAND_A_PERC + $BAND_B_PERC;
  $BAND_D_SWITCH_PERC=$BAND_A_PERC + $BAND_B_PERC + $BAND_C_PERC;
  # Not User Configurable
  # Calculated switch cell percantage portion of each band
  local $SWITCH_TO_BAND_B=($TOTALNODES*$BAND_B_SWITCH_PERC)/100 + 1;
  local $SWITCH_TO_BAND_C=($TOTALNODES*$BAND_C_SWITCH_PERC)/100 + 1;
  local $SWITCH_TO_BAND_D=($TOTALNODES*$BAND_D_SWITCH_PERC)/100 + 1;
  # Not User Configurable
  # Num of frequency are set according to within defined percantage volume
  local $ERBSTOTALCOUNT=$ynodecount,$NUMOFEUTRANFREQ,$EUTRANFREQID;
  if ($ERBSTOTALCOUNT>=1){
      $NUMOFEUTRANFREQ=$BAND_A
  }# endif
  if ($ERBSTOTALCOUNT>=$SWITCH_TO_BAND_B){
      $NUMOFEUTRANFREQ=$BAND_B;
  }# endif
  if ($ERBSTOTALCOUNT>=$SWITCH_TO_BAND_C){
      $NUMOFEUTRANFREQ=$BAND_C;
  }# end if
  if($ERBSTOTALCOUNT>=$SWITCH_TO_BAND_D){
     $NUMOFEUTRANFREQ=$BAND_D;
  }# end if

  local $MOD=$ERBSTOTALCOUNT%$NUMOFEUTRANFREQ;
  if ($MOD==0){
      $EUTRANFREQID=$NUMOFEUTRANFREQ;
  }
  else {$EUTRANFREQID=$MOD;
  }# end else

  if ($ykey eq "ID" ){
      return($EUTRANFREQID);
  }
  else{return($NUMOFEUTRANFREQ);
  } #end else
}# end getEUtranFreqID_NUM
#-----------------------------------------
#  Name : getLTESimNum
#  Description : returns an integer value
#  denoting the LTE simulation number of
#  a LTE node
#  Params : $COUNT # nodecount
#           $NUMOFRBS # total ERBS nodes per sim
#  Example :&getLTESimNum($COUNT,$NUMOFRBS)
#  Return : returns an integer simulation
#           num where a LTE node is located
#           for a netsim LTE sim
#-----------------------------------------
sub getLTESimNum{
  local($xnodenum,$xttlnodespersim)=@_;
  local $xsimnum,$ttlxsimnum;
  if($xnodenum<=$xttlnodespersim){
     $xsimnum=1;return($xsimnum);
  }# end if
  $xsimnum=2;
  $ttlxsimnum=501; # to support sim number upto LTE500 (CXP 903 0491-322-1)
  while($xsimnum<=$ttlxsimnum){
      if($xnodenum<=($xsimnum*$xttlnodespersim)){
         last; # sim located
      }# inner if
      $xsimnum++;
  }# end while
  return($xsimnum);
}# end sub getLTESimNum
#-----------------------------------------
#  Name : getLTESimIntegerNodeNum
#  Description : returns an integer value
#  for a netsim LTE simulation node string
#  ex : LTE01ERBS00003 returns 3
#  Params : $LTE # simnum
#           $COUNT # nodecount
#           $NUMOFRBS # total ERBS nodes
#  Example :&getLTESimIntegerNodeNum($LTE,$COUNT,$NUMOFRBS)
#  Return : returns an integer node num
#           for a netsim LTE simulation
#           string node name
#-----------------------------------------
sub getLTESimIntegerNodeNum{
  local($simnum,$nodecount,$ttlsimnodes)=@_;
  local $intnodenum;
  if ($simnum==1){ # first LTE simulation
      $intnodenum=$nodecount;}# end if
  else{$intnodenum=$nodecount+($ttlsimnodes*($simnum-1));}
  return($intnodenum);
}# end sub getLTESimIntegerNodeNum
#-----------------------------------------
#  Name : getLTESimStringNodeName
#  Description : returns a string value
#  for a netsim LTE simulation node name
#  ex : node strring name LTE01ERBS00003
#  Params : $LTE # simnum
#           $COUNT # nodecount
#  Example : getLTESimStringNodeName($LTE,$COUNT)
#  Return : returns a LTE node string name
#-----------------------------------------
sub getLTESimStringNodeName{
  local($simnum,$nodecount)=@_;
  local $nodezeros,$simnodename,$simType;

  #$simType=&getNodeTypeForSim($simnum)."ERBS";
  #$simType=&getNodeTypeForSim($simnum);
  if($nodecount<10){	$nodezeros="0000";}
  elsif($nodecount<100){$nodezeros="000";}
  else{			$nodezeros="00";}

  if($simnum<=9){$simnodename="NR0$simnum"."gNodeBRadio".$nodezeros.$nodecount;}
  else{		  $simnodename="NR$simnum"."gNodeBRadio".$nodezeros.$nodecount;}# end else

  return($simnodename);
}# end sub getLTESimStringNodeName
#-----------------------------------------
#  Name : getEnvfilevalue
#  Description : returns a value for the
#  /dat/$LTE_name.env file which contains
#  preassigned values.
#  Params : $LTE_ENV_Filename &
#           $Value ie. SIMTYPE=ST where
#  $Value=SIMTYPTE and return value is ST
#  Example : @getENVfilevalue("TEST.env","SIMTYPE")
#  Return : ST where SIMTYPE=ST
#-----------------------------------------
# CXP 903 0491-136-1 : Add new arguemant $simName to
#       changethe name of ENV variable searched for
#	based on CPP/PICO/DG2
sub getENVfilevalue{
    local ($env_file_name,$env_file_constant,$simName)=@_;
    local @envfiledata=();
    local $env_file_value="ERROR";
    local $dir=cwd,$currentdir=$dir."/";
    local $scriptpath="$currentdir",$envdir;
    local $element,$tempelement;

    # check if CPP or PICO or DG2
    if($simName=~/PICO/){$env_file_constant="PICO".$env_file_constant}
    elsif($simName=~/DG2/){$env_file_constant="DG2".$env_file_constant}

    # navigate to dat directory
    $scriptpath=~s/lib.*//;$scriptpath=~s/bin.*//;
    $envdir=$scriptpath."dat/$env_file_name";
    if (!-e "$envdir")
       {print "ERROR : $envdir does not exist\n";return($env_file_value);}

    open FH, "$envdir" or die $!;
    @envfiledata=<FH>;close(FH);
    foreach $element(@envfiledata){
      if ($element=~/\#/){next;} # end if
      if (!($element=~/\=/)){next;} # end if

      $tempelement=$element;
      $tempelement=~s/=.*//;
      $tempelement=~s/\n//;

      $env_file_constant=~s/\n//;

      if ($env_file_constant=~m/$tempelement/)
          {$env_file_value=$element;
           $env_file_value=~s/^\s+//;
           $env_file_value=~s/^.*=//;
           $env_file_value=~s/\s+$//;
     } # end if

    }# end foreach
    return($env_file_value);
}# end getENVfilevalue
#-----------------------------------------
#  Name : makedMOscript
#  Description : builds a netsim mo
#  script
#  Params : $mmlscriptname,
#  Example :&makeMOscript($fileaction,$MOSCRIPT,@MOCmds);
#  Return : populated netsim mo script
#-----------------------------------------
sub makeMOscript{
    local ($fileaction,$moscriptname,@cmds)=@_;
    $moscriptname=~s/\.\///;
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
#-----------------------------------------
#  Name : makedMMLscript
#  Description : builds a netsim mml
#  script
#  Params : $mmlscriptname,
#  Example :&makeMMLscript($fileaction,$MMLSCRIPT,@MMLCmds);
#  Return : populated netsim mml script
#-----------------------------------------
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

    foreach $_(@cmds){print FH "$_\n";}
    close(FH);
    system("chmod 744 $mmlscriptname");
    return($mmlscriptname);
}# end makeMMLscript
#-----------------------------------------
#  Name : listNodePrimaryCells
#  Description : returns the primary cells
#  of a specific node using a predefined
#  list of cells and adjacent cells
#  Params : @nodecells # predetermined node
#                        primary and adjacent cellids
#  Example :&listNodePrimaryCells(@nodecells)
#  note : @nodecells is populated from
#  function call
#  ex: (@nodecells)=&getAllNodeCells(1,4000,$NETWORKCELLSIZE);
#  Return : returns node primary cells from nodecells
#-----------------------------------------
sub listNodePrimaryCells{
    local (@everynodecell)=@_;
    local @listprimarycells=();
    local $listelement="",$listelementcounter=0;
    foreach $listelement(@everynodecell){
            $listelement=~s/\..*//g;
            $listelement=~s/^\s+//;
           $listelement=~s/\s+$//;
           $listprimarycells[$listelementcounter]=$listelement;
            $listelementcounter++;
    }# end foreach
    if(@listprimarycells==0){
       print "sub listNodePrimaryCells returns 0\n";
       $listprimarycells[0]="ERROR";
    }# end if
    return(@listprimarycells);
}# end listNodePrimaryCells
#-----------------------------------------
#  Name : listNodeAdjacentCells
#  Description : returns the adjacent cells
#  of a specific node using a predefined
#  list of cells and adjacent cells
#  Params : @nodecells # predetermined node
#                        primary and adjacent cellids
#  Example :&listNodeAdjacentCells(@nodecells)
#  note : @nodecells is populated from
#  function call
#  ex: (@nodecells)=&getAllNodeCells(1,4000,$NETWORKCELLSIZE);
#  Return : returns node adjacent cells from nodecells
#-----------------------------------------
sub listNodeAdjacentCells{
    local (@every2nodecell)=@_;
    local @listadjacentcells=(),@templistadjacentcells=();
    local @tempadjacentcells1=(),@tempadjacentcells2=();
    local @tempadjacentcells3=(),@tempadjacentcells4=();
    local $listelement2="",$listelementcounter2=1;
    local $tempxcounter=0;
    foreach $listelement2(@every2nodecell){
      $listelement2=~s/N//;$listelement2=~s/N1//;$listelement2=~s/N2//;$listelement2=~s/N3//;
      $listelement2=~s/E//;$listelement2=~s/E1//;$listelement2=~s/E2//;$listelement2=~s/E3//;
      $listelement2=~s/S//;$listelement2=~s/S1//;$listelement2=~s/S2//;$listelement2=~s/S3//;
      $listelement2=~s/W//;$listelement2=~s/W1//;$listelement2=~s/W2//;$listelement2=~s/W3//;
      # mark primary cells
      if($listelementcounter2==1){
         $listelement2=~s/\d+\../cell$listelementcounter2/; # note  primary cellindex
      }# end if
      if($listelementcounter2==2){
         $listelement2=~s/\d+\../cell$listelementcounter2/; # note  primary cellindex
      }# end if
      if($listelementcounter2==3){
         $listelement2=~s/\d+\../cell$listelementcounter2/; # note  primary cellindex
      }# end if
      if($listelementcounter2==4){
         $listelement2=~s/\d+\../cell$listelementcounter2/; # note  primary cellindex
      }# end if

      $listelement2=~s/^\s+//;
      $listelement2=~s/\s+$//;
      if($listelementcounter2==1){
         @tempadjacentcells1=split(/\../,$listelement2);
      }# end if 1
      if($listelementcounter2==2){
         @tempadjacentcells2=split(/\../,$listelement2);
      }# end if 2
      if($listelementcounter2==3){
         @tempadjacentcells3=split(/\../,$listelement2);
      }# end if 3
      if($listelementcounter2==4){
         @tempadjacentcells4=split(/\../,$listelement2);
      }# end if 4
      $listelementcounter2++;
    }# end foreach
    @templistadjacentcells=(@tempadjacentcells1,@tempadjacentcells2,@tempadjacentcells3,@tempadjacentcells4);
    foreach $_(@templistadjacentcells){
               if($_ eq ""){next;}
               $listadjacentcells[$tempxcounter]="$_";
               $tempxcounter++;
    }# end foreach
    if(@listadjacentcells==0){
       print "sub listNodeAdjacentCells returns 0\n";
       $listadjacentcells[0]="ERROR";
    }# end if
    return(@listadjacentcells);
}# end listNodeAdjacentCells
#------------------------------------------------------
#  Name : queryMIM
#  Description : gets the MIM version of the network
#                simulation from sim naming conventions
#                1. LTEC170-ST-LTE17
#                   - returns MIM version C170
#                2. LTEB110x160-ST-FDD-LTE01
#                   - returns MIM version B110
#  Params : $SIMNAME
#  Example :&queryMIM($SIMNAME)
#  Return : returns the MIM version of the network
#           simulation
#-------------------------------------------------------
sub queryMIM{
    local ($simname,$nodeCount)=@_;
    my $isDG2 = $simname =~ m/GNodeBRadio/;

    local $mimversion="ERROR-unable to determine MIM version";
    my $mim=$simname;
    $mim=~s/NR//;
    if ($mim=~m/^[a-zA-Z]/) {
        $mim=~s/-.*//;
    }
    $mim=~s/x.*//;
    $mimversion=$mim;
    $mimversion=~s/^\s+//;$mimversion=~s/\s+$//;

    #if ($isDG2) {
    #    return &getDg2MimVersionFromSimNameByNodeCount($simname,$nodeCount);
    #}

    return($mimversion);
}# end sub queryMIM
#------------------------------------------------------
#   Private                                           -
#------------------------------------------------------
sub getDg2MimVersionFromSimNameByNodeCount {
    my ($simName,$nodeCount)=@_;

    my ($mimsRef,$countsRef) = &splitMimVersionsAndNodeCountsIntoTwoArrays($simName);
    my @mims=@$mimsRef;
    my @counts=@$countsRef;

    my $arrayIndex=0;
    my $totalCount=0;
    for $mimCount (@counts) {
        $totalCount+=$mimCount;
        if ($nodeCount <= $totalCount) {
            last;
        }
        $arrayIndex++;
    }
    return $mims[$arrayIndex];
}
#------------------------------------------------------
#  Name : isgreaterthanMIM
#  Description : compares two LTE mim versions and
#  determines if the first param ie. $MIMVERSION1 is
#  greater than or equal to $MIMVERSION2. The function
#  return yes if $MIMVERSION1 is equal to or greater that
#  $MIMVERSION2
#  eg. B123 is greater that or equal to D125 = no
#      D125 is greater that or equal to D124 = yes
#      E111 is greater that or equal to E110 = yes
#  Params : $MIMVERSION1,$MIMVERSION2
#  Example : $status=&isgreaterthanMIM($MIMVERSION,$COMBINEDCELLMIMVERSIONSUPPORT);
#  Return : returns either yes or no or ERROR
#------------------------------------------------------------
sub isgreaterthanMIM {
    local ($mimVersion1,$mimVersion2)=@_;
    local $greaterOrEqualMIM="ERROR";
    # Extract the digits from mimversions
    local ($firstReleaseNum)=$mimVersion1=~/(\d+)/;
    local ($secondReleaseNum)=$mimVersion2=~/(\d+)/;
    # Extract the letter from mimversions
    local ($firstReleaseLetter)=$mimVersion1=~/(\D)/;
    local ($secondReleaseLetter)=$mimVersion2=~/(\D)/;

    # check if CPP or COM/ECIM
    if (($mimVersion1=~m/^[a-zA-Z]/) && ($mimVersion2=~m/^[a-zA-Z]/)) {

	my $resnumcompare,$reslettercompare;

	$resnumcompare=$firstReleaseNum <=> $secondReleaseNum;
	$reslettercompare=$firstReleaseLetter cmp $secondReleaseLetter;

	# mimversion1 letter is equal to or greater than mimversion2
	if ($reslettercompare>0){
	    $greaterOrEqualMIM="yes";
	}# end if
	# mim letters are equal and mimversion1 number is greater than mimversion2
	elsif(($reslettercompare==0)&&($resnumcompare>=0)){
	       $greaterOrEqualMIM="yes";
	}# end elseif
	# mimversion1 letter is less than mimversion2
	elsif($reslettercompare<0){
	           $greaterOrEqualMIM="no";
	}# end elsif
	# mim letters equal and mimversion1 number is greater than mimversion2
	elsif($resnumcompare>=0){
	            $greaterOrEqualMIM="yes";
	} else { $greaterOrEqualMIM="no";}

    } else {

	if ($firstReleaseNum > $secondReleaseNum) { $greaterOrEqualMIM="yes";}
	if ($firstReleaseNum < $secondReleaseNum) { $greaterOrEqualMIM="no";} else {
       # COM/ECIM version comparsion
	   my $firstVersion=($mimVersion1=~m/V/) ? $mimVersion1 : $mimVersion1."-V0"; $firstVersion=~ s/.*V//g;
	   my $secondVersion=($mimVersion2=~m/V/) ? $mimVersion2 : $mimVersion2."-V0"; $secondVersion=~ s/.*V//g;

	   if ($firstVersion >= $secondVersion && $firstReleaseLetter ge $secondReleaseLetter) { $greaterOrEqualMIM="yes";}
	   if ($firstReleaseNum >= $secondReleaseNum && $firstReleaseLetter gt $secondReleaseLetter && $firstVersion < $secondVersion) { $greaterOrEqualMIM="yes";}
	   if ($firstReleaseNum < $secondReleaseNum && $firstReleaseLetter eq $secondReleaseLetter && $firstVersion < $secondVersion) { $greaterOrEqualMIM="no";}
	   if ($firstReleaseNum == $secondReleaseNum && $firstReleaseLetter eq $secondReleaseLetter && $firstVersion < $secondVersion) {$greaterOrEqualMIM="no";}
	   if ($firstReleaseNum < $secondReleaseNum && $firstReleaseLetter lt $secondReleaseLetter ) { $greaterOrEqualMIM="no";}
	  }
    }
    return($greaterOrEqualMIM);
}# end sub isgreaterthanMIM
#------------------------------------------------------------
sub uniq {
    local %seen;
    return grep { !$seen{$_}++ } @_;
}# end sub uniq
#------------------------------------------------------------
#  Name : isSimLTE
#  Description : determines if a NETSim simulation is of type
#                LTE or not based on the name of the simulation
#                ensuring that is it not DG2 or PICO
#
#  Params : $SimulationName = name of the NETSim simulation
#  Example : &isSimLTE($SimName);
#            &isSimLTE("LTESRBSV1x160-RV-FDD-LTE02");
#
#  Returns : YES if simulation is of type LTE
#            NO if simulation is NOT of type LTE
#---------------------------------------------------------------
sub isSimLTE{
    local ($simname)=@_;
    local $returnvalue="ERROR";
    local $simserachvalue="DG2";

    # check param is valid
    if (length($simname)<1){return $returnvalue;}

    # check for LTE simname
    if(!($simname=~m/DG2/)&&(!($simname=~m/PICO/))){
       $returnvalue="YES"}# end if
    else{$returnvalue="NO";}# end else
    return($returnvalue);
} # end isSimLTE
#------------------------------------------------------------
#  Name : checkMIMVersionRange
#  Description : Determines if a MIM version falls within a
#                predetermined range. The range is defined by
#                two parameters acquired from two innovacations
#                of the isgreaterthanMIM subroutine of an
#                earlier and later MIM version. The range is
#                determined by the comparison of these parameters.
#
#  Params  : &checkMIMVersionRange($lowerLimit,$upperLimit);
#  Example : &checkMIMVersionRange($imLoadBalancingEnable,$imLoadBalancingDisable);
#
#  Returns : YES if lower limit == yes and upper limit == yes
#            NO if either lower or upper Range == no
#---------------------------------------------------------------
sub checkMIMVersionRange{
    local ($lowerRange,$upperRange)=@_;
    local $withinRange="yes";
    local $notWithinRange="no";
    local $returnValue;

    if($lowerRange eq "yes" && $upperRange eq "yes"){
    $returnValue=$withinRange }# end if
    else{$returnValue=$notWithinRange;
        }# end else
    return($returnValue);
} # end checkMIMVersionRange
#----------------------------------------------------------------------------------
#  Name : isSimflaggedasTDDinCONFIG
#
#  Description : determines if a LTE simulation
#                is of type TDD based on the
#                cell type as defined in the
#                CONFIG.env
#
#  Params : $CONFIG (ie. CONFIG.env)
#           $LTETDDSimsi (ie. "TDDSIMS")
#           $SimNumber (eg. 2)
#
#  Example : @isSimflaggedasTDDinCONFIG($CONFIG,"TDDSIMS",2)
#            @isSimflaggedasTDDinCONFIG("CONFIG.env","TDDSIMS","currentSIMnum")
#
#  Return : true (if current simulation (currentSIMnum) is of type TDD) or
#           false (if simulation (currentSIMnum) is NOT of type TDD)
#----------------------------------------------------------------------------------
sub isSimflaggedasTDDinCONFIG{
    local ($env_file_name,$configvalue,$currentsimnumber)=@_;
    local $return_value="ERROR";

    local $dir=cwd,$currentdir=$dir."/";
    local $scriptpath="$currentdir",$envdir;
    local $element,$tempelement;
    local @TDDconfigfilesimvalues=();
    local $TDDelement=0;

    local $elementdata;
    local $arraysize=0;

    # navigate to dat directory
    $scriptpath=~s/lib.*//;$scriptpath=~s/bin.*//;
    $envdir=$scriptpath."dat/$env_file_name";

    if (!-e "$envdir")
       {print "ERROR : $envdir does not exist\n";return($return_value);}

    open FH1, "$envdir" or die $!;
    @envfiledata=<FH1>;close(FH1);

    foreach $element(@envfiledata){

      if ($element=~/\#/){next;} # end if
      if (!($element=~/\=/)){next;} # end if

      $tempelement=$element;
      $tempelement=~s/=.*//;
      $tempelement=~s/\n//;

      $configvalue=~s/\n//;

      if ($configvalue=~m/$tempelement/){
           $env_file_value=$element;
           $env_file_value=~s/^\s+//;
           $env_file_value=~s/^.*=//;
           $env_file_value=~s/\s+$//;
           @TDDconfigfilesimvalues=split(/,/,$env_file_value);
      }# end if

     }# end foreach

     $arraysize=@TDDconfigfilesimvalues;

     $return_value=0;# false

     if ($arraysize==0){$return_value=0;} # false

     foreach $elementdata(@TDDconfigfilesimvalues){
                         if($elementdata eq $currentsimnumber){
                            $return_value=1;# true
                         }# end if
     }# end foreach

     return($return_value);
}# end isSimflaggedasTDDinCONFIG
#------------------------------------------------------------
#  Name : isCdma20001xRttYes
#  Description : Checks whether Cdma20001xRttFeature is turned
#		 ON or OFF from CONFIG.env
#
#  Params : No Parameters
#  Example : &isCdma20001xRttYes;
#
#  Returns : YES if Cdma20001xRttFeature is ON
#            NO if Cdma20001xRttFeature is OFF
#---------------------------------------------------------------
sub isCdma20001xRttYes{
	local $Cdma20001xRttFeature=&getENVfilevalue($ENV,"Cdma20001xRttFeature");
    local $returnvalue;

    if($Cdma20001xRttFeature=~m/ON/) { $returnvalue="YES"; }# end if
    else{$returnvalue="NO";}# end else

    return($returnvalue);
} # end isCdma20001xRttYes

#------------------------------------------------------------
#  Name : isCdma2000Yes
#  Description : Checks whether Cdma2000Feature is turned
#		 ON or OFF from CONFIG.env
#
#  Params : No Parameters
#  Example : &isCdma2000Yes;
#
#  Returns : YES if Cdma2000Feature is ON
#            NO if Cdma2000Feature is OFF
#---------------------------------------------------------------
sub isCdma2000Yes{
	local $Cdma2000Feature=&getENVfilevalue($ENV,"Cdma2000Feature");
    local $returnvalue;

    if($Cdma2000Feature=~m/ON/) { $returnvalue="YES"; }# end if
    else{$returnvalue="NO";}# end else

    return($returnvalue);
} # end isCdma2000Yes
#---------------------------------------------------------------
#  Name : isNodeNumLocInReqPer
#  Description :
#
#  Params : 1 parameter(NodeNumber)
#  Example : &isNodeNumLocInReqPer($nodeNum);
#
#  Returns : TRUE if the node num is with in the percentage
#            FALSE if the node num is not in the percentage
#---------------------------------------------------------------
sub isNodeNumLocInReqPer{
    my ($nodeNum)=@_;
    my $ENV="CONFIG.env";
    my $cellPattern=&getENVfilevalue($ENV,"CELLPATTERN");
    my $retSubUnitPercentage=&getENVfilevalue($ENV,"RETSUBUNITPERCENTAGE");
    my @cellPattern=split(/\,/,$cellPattern);
    my $totalCellInPattern = eval join '+', @cellPattern;
    my $totalNodesInPattern = @cellPattern;
    my $nodeNumInCellPattern=($nodeNum % $totalNodesInPattern);
    my $thresholdCellsInCellPattern = ($totalCellInPattern*$retSubUnitPercentage/100);
    my $sumCounterCellsInCellPattern=0;
    my $counterNodesInCellPattern=0;
    my $returnValue="true";
    if ($nodeNumInCellPattern == 0) {$nodeNumInCellPattern=$totalNodesInPattern; }
    while ($counterNodesInCellPattern < $nodeNumInCellPattern){
            $sumCounterCellsInCellPattern=$sumCounterCellsInCellPattern + $cellPattern[$counterNodesInCellPattern];
            $counterNodesInCellPattern++;
            if($sumCounterCellsInCellPattern >= $thresholdCellsInCellPattern){
                $returnValue="false";
                last;
                }
        }
        return $returnValue;
}
sub getCbrsType{
   my ($nodecountinteger,$CELLNUM)=@_;
   my $ENV="CONFIG.env";
   my $cellType;
   my %cbrsDistribution;
   my $cbrsType="SKIP";
   if ($CELLNUM==1) {
      return ("SKIP");
   } else {
     $cellType = "CBSD_" . $CELLNUM;
     $cbrsType=&getENVfilevalue($ENV,$cellType);
     %cbrsDistribution = split /[,:]/, $cbrsType;
     keys %cbrsDistribution;
     while (my($cbsd,$range)=each %cbrsDistribution) {
        @nodeRange = split( /-/, $range );
        if (($nodecountinteger >= $nodeRange[0]) && ($nodecountinteger <= $nodeRange[1])) {
           $cbrsType=$cbsd;
           last;
        }
        $cbrsType="SKIP";
     }
   }
   return $cbrsType;
}

########################
# END LIB MODULE
####################
