#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_OSS15
#
#     Description : Contains all functions related to updates for LTE OSS15B
#                   30K network
#
#     Author : SimNet (epatdal)  
#                  
#############################################################################
# Version2    : LTE 15B
# Revision    : CXP 903 0491-136-1 
# Purpose     : Add DG2 node to multisims script 
# Description : Add getManagedElement 
# Date        : 03 Apr 2015
# Who         : edalrey
#############################################################################
# Version3    : LTE 15B
# Revision    : CXP 903 0491-140-1 
# Purpose     : Improve generation of LTE2<RAN> relation files 
# Description : Add createNodeTypesForSims getNodeTypeForSim 
# Date        : 14 Apr 2015
# Who         : edalrey
#############################################################################
# Version4    : LTE 16A
# Revision    : CXP 903 0491-163-1
# Jira        : NETSUP-3157 
# Purpose     : CPP simulation incorrectly determined to be DG2 Fix
# Description : CPP simulation incorrectly determined to be DG2 at build time
#		error in createNodeTypesForSims subroutine
# Date        : July 2015
# Who         : ejamfur
#############################################################################
#############################################################################
# Version5    : LTE 16A
# Revision    : CXP 903 0491-164-1
# Jira        : NETSUP-3161 
# Purpose     : Single network build across multiple NETSim servers support
# Description : Modify the createNodeTypesForSims subroutine to allow a
#		simulated network to be build across multiple NETSim servers
# Date        : July 2015
# Who         : ejamfur
#############################################################################
#############################################################################
# Version5    : LTE 15.14
# Revision    : CXP 903 0491-171-1
# Jira        : CIP-9795
# Purpose     : Add writeCellPatternToConfigFile subroutine
# Description : writes cell pattern generated from cell ratios to the
#               CONFIG.env file.
# Date        : Sept 2015
# Who         : ejamfur
#############################################################################
##########################################
#  Environment
##########################################
package LTE_OSS15;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(isSimDG2 getDG2SimStringNodeName getDG2SimIntegerNodeNum getDG2StringNodeName getManagedElement createNodeTypesForSims getNodeTypeForSim writeCellPatternToConfigFile);

use Cwd;
use POSIX;
use LTE_CellConfiguration;
##########################################
# Vars
##########################################
my $gen=".."x1;
my $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
##########################################
# funcs
##########################################
#-----------------------------------------
#  Name : getDG2StringNodeName
#  Description : returns a DG2 node string value
#  for a given DG2 nodecount number
#  ex : node number 3 returns LTE01pERBS00003
#  Params : $DG2SIMSTART # starting DG2 sim num
#           $NODECOUNT # nodecount
#           $DG2NUMOFRBS # DG2 nodes per sim
#  Example : &getDG2StringNodeName($DG2SIMSTART,$NODECOUNT,$DG2NUMOFRBS)
#  Return : returns a DG2 node string name
#-----------------------------------------
sub getDG2StringNodeName{

  local($dg2simstart,$nodecount,$ttldg2nodespersim)=@_;
  local $nodezeros,$simnodename,$simnum;
 
  $simnum=int(($nodecount)/$ttldg2nodespersim);
  if($nodecount==$ttldg2nodespersim*$simnum){$simnum=$simnum-1;}

  if (($simnum<0)||($nodecount<0)){$simnodename="ERROR";return($simnodename);}
  if(($simnum<1)||($nodecount==$ttldg2nodespersim)){$simnum=$dg2simstart;}
  elsif($simnum>0){
      $nodecount=$nodecount-($ttldg2nodespersim*$simnum);
      $simnum=$simnum+$dg2simstart;}

  print "DEBUG I am here\n"; 
  
  if($nodecount<10){$nodezeros="0000";}
   elsif($nodecount<100){$nodezeros="000";}
    else{$nodezeros="00";}
  if($simnum<=9)
    {$simnodename="LTE0$simnum"."dg2ERBS".$nodezeros.$nodecount;}
  else
    {$simnodename="LTE$simnum"."dg2ERBS".$nodezeros.$nodecount;}# end else
  return($simnodename);
}# end getDG2StringNodeName
#------------------------------------------------------------
#  Name : isSimDG2
#  Description : determines if a NETSim simulation is of type
#                DG2 or not based on the name of the simulation
#
#  Params : $SimulationName = name of the NETSim simulation
#  Example : &isSimDG2($SimName);
#            &isSimDG2("LTESRBSV1x160-RVDG2-FDD-LTE02");
#
#  Returns : YES if simulation is of type DG2
#            NO if simulation is NOT of type DG2 ie. LTE
#---------------------------------------------------------------
sub isSimDG2{
    local ($simname)=@_;
    local $returnvalue="ERROR";
    local $simserachvalue="DG2";

    # check param is valid
    if (length($simname)<1){return $returnvalue;}
    
    # check for DG2 simnam
    if($simname=~m/gNodeBRadio/){
       $returnvalue="YES"}# end if
    else{$returnvalue="NO";}# end else
    return($returnvalue);
} # end isSimDG2
#-----------------------------------------
#  Name : getDG2SimStringNodeName
#  Description : returns a string value
#  for a netsim DG2 simulation node name
#  ex : node string name LTE01dg2ERBS00003
#  Params : $LTE # simnum
#           $COUNT # nodecount
#  Example : getDG2SimStringNodeName($LTE,$COUNT)
#  Return : returns a DG2 node string name
#-----------------------------------------
sub getDG2SimStringNodeName{
	local($simnum,$nodecount)=@_;
	local $nodezeros,$simnodename;
	if($nodecount<10)	{$nodezeros="0000";}
	elsif($nodecount<100)	{$nodezeros="000";}
	else			{$nodezeros="00";}

	if($simnum<=9)	{$simnodename="LTE0$simnum"."dg2ERBS".$nodezeros.$nodecount;}
	else		{$simnodename ="LTE$simnum"."dg2ERBS".$nodezeros.$nodecount;}# end else
	return($simnodename);
}# end getDG2SimStringNodeName
#-----------------------------------------
#  Name : getDG2SimIntegerNodeNum
#  Description : returns an integer value
#  for a netsim DG2 simulation node string
#  within a DG2 network
#  ex : LTE01pERBS00003 returns 3
#  Params : $DG2SIMSTART # starting DG2 sim num
#           $LTE # actual script simnum
#           $COUNT # nodecount
#           $DG2NUMOFRBS # total DG2 nodes
#  Example :&getDG2SimIntegerNodeNum($DG2SIMSTART,$LTE,$COUNT,$DG2NUMOFRBS)
#  Return : returns an integer node num
#           for a netsim DG2 simulation
#           string node name
#-----------------------------------------
sub getDG2SimIntegerNodeNum{
	local($simstart,$simnum,$nodecount,$ttlsimnodes)=@_;
	local $intnodenum;

	$intnodenum=$nodecount+($ttlsimnodes*($simnum-1));

	if($intnodenum>$ttlsimnodes){
		$intnodenum=(($simnum-1)*$ttlsimnodes)+$nodecount;
	}# end if
	return($intnodenum);
}# end sub getDG2SimIntegerNodeNum
#-----------------------------------------------------------
#  Name 	: getManagedElement 
#  Description	: returns an string value for
#  	the ManagedElement MO of a simulation
#  	based on CPP vs COM/ECIM model type.
#  	CPP nodes have ManagedElement=1
#  	COM/ECIM nodes have ManagedElement=$strinNodeName
#
#  	ex: LTE01ERBS00003 	  returns "1" 
#  	ex: LTE01dg2ERBS00003 returns "LTE01dg2ERBS00003"
#  Params	: $stringNodeName # string name of the node
#  Example	: &getManagedElement($LTENAME)
#  Return 	: string value for
#	    ManagedElement MO
#-----------------------------------------------------------
sub getManagedElement{
	local ($stringNodeName)=@_;
	local $returnedNodeName;
	if($stringNodeName=~/dg2/){$returnedNodeName=$stringNodeName;}
	else{$returnedNodeName=1;}
	return($returnedNodeName);
}# end sub getManagedElement
#-----------------------------------------------------------
#  Name		: createNodeTypesForSims 
#  Description	: create the file nodeTypesForSims.env
#	under ~/lte/bin/, which contains a list of Sims
#	in a MULTISIM build and the sims' node types. 
#  Params	: $MULTISIMS # full MULTISIMS.env filepath
#  Example	: createNodeTypesForSims($MULTISIMS)
#  Return	: return file path of output file 
#-----------------------------------------------------------
sub createNodeTypesForSims{
	local ($MULTISIMS)=@_;
	open FH, "<", "$MULTISIMS" or die $!;
		@filelines=<FH>;
	close(FH);

	local @nodeTypes=(),$maxSimulation="";
	foreach $element(@filelines){
		$element=~s/^\s+//;$element=~s/\s+$//;
		# CXP 903 0491-164-1
		if($element=~/\#/ && !($element=~/\#CREATE/)){next;}
		if($tempelement=~m/DONOTCREATE/){next;}
		if($element=~/NETWORKBLOCK/){next;}

		if($element=~/CREATE/){
			my $simName,$simNumber;
			$simName=$element;
			$simName=~s/.*REATE-//;
			$simNumber=$element;
			$simNumber=~s/.*(?=-LTE)//;
			$simNumber=~s/-LTE//;

			if($simName=~m/DG2/){
				$nodeTypes[$simNumber]="radionode";
			}
			elsif($simName=~m/PICO/){
				$nodeTypes[$simNumber]="p";
			}
			if($simNumber>$maxSimulation){$maxSimulation=$simNumber;}
		}# end if
	}# end foreach
	my $outputDir=cwd,$outputFile;
	$outputDir=~s/lte.*//,$outputDir=$outputDir."lte/dat";
	$outputFile=$outputDir."/nodeTypesForSims.env";
	open (F1, "> ".$outputFile);
	for (my $i=0; $i <= $maxSimulation; $i++){
		print F1 "$i:$nodeTypes[$i]\n";
	}
	close (F1);
	return $outputFile;
}
#-----------------------------------------------------------
#  Name		: getNodeTypeForSim 
#  Description	: returns a string value for the node type
#  	of a simulation.
#
#  	ex : PICO returns 'p'
# 	     DG2  returns 'dg2'
#  Params	: $simNumber # number of Sim 
#  Example	: getNodeTypeForSim($simNumber) 
#  Return	: returns the node type for a Sim 
#-----------------------------------------------------------
sub getNodeTypeForSim{
        local ($nth)=@_;
        local $type;

        my $filePath=cwd."/";
        $filePath=~s/script.*//;$filePath=$filePath."script/dat/nodeTypesForSims.env";
    
        open FH3, '<', $filePath or die "$filePath: $!";
        my @lines = <FH3>;
        $type = @lines[$nth];
	$type=~s/\n//;
	my @value = split(':',$type);
        return $value[1];
}
#-----------------------------------------------------------
#  Name         : writeCellPatternToConfigFile
#  Description  : writes cell pattern generated by ratios to
#                 the CONFIG.en
#  Params       : @CELLPATTERN
#  Example      : writeCellPattern(@CELLPATTERN); 
#-----------------------------------------------------------
sub writeCellPatternToConfigFile {
    local @CELLPATTERN=@_;
    local $"=",";
    local $prefix="CELLPATTERN=";
    local $formattedCellPattern=$prefix."@CELLPATTERN";

    local $dir=cwd,$currentdir=$dir."/";
    local $scriptpath="$currentdir",$envdir;

    $scriptpath=~s/lib.*//;$scriptpath=~s/bin.*//;
    $envdir=$scriptpath."dat/CONFIG.env";

   if (!-e "$envdir")
       {print "ERROR writing cell pattern to CONFIG.env : $envdir does not exist\n";}

   open FH,'<', "$envdir" or die $!;
   my @lines = <FH>;
   close(FH);

   my @newlines;
   foreach(@lines) {
        if ($_=~m/CELLPATTERN/) {
            $_=~s/\=.*//;
        }
         $_ =~ s/CELLPATTERN/$formattedCellPattern/g;
         push(@newlines,$_);
   }

   open FH, '>', "$envdir" or die $!;
        print FH @newlines;
   close(FH);
}# writeCellPatternToConfigFile
########################
# END LIB MODULE
########################
