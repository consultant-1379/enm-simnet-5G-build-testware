#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_OSS14
#
#     Description : Contains all functions related to updates for LTE OSS14A
#                   30K network
#
#     Author : SimNet (epatdal)  
#                  
#############################################################################
####################################################################            
# Ver2        : LTE 15B         
# Revision    : CXP 903 0491-114-1              
# Purpose     : Emergency workaround.
# Description : Hardcodes the ERBS/PICO threshold at LTE51.
# Date        : 16 Dec 2014             
# Who         : edalrey         
#################################################################### 
####################################################################            
# Ver3        : LTE 15B         
# Revision    : CXP 903 0491-118-1              
# Purpose     : Emergency workaround.
# Description : Hardcodes the ERBS/PICO threshold at LTE51.
# Date        : 08 Jan 2015             
# Who         : edalrey         
#################################################################### 
####################################################################            
# Ver4        : LTE 16A        
# Revision    : CXP 903 0491-155-1   
# Jira        : NETSUP-3047 
# Purpose     : sets the pico simulations start position at LTE37 as per the 16A SNID.
# Description : Hardcodes the ERBS/PICO threshold at LTE37.
# Date        : 08 Jan 2015             
# Who         : edalrey         
####################################################################
####################################################################
# Version5    : LTE 17A
# Revision    : CXP 903 0491-229-1
# Jira        : NSS-4526
# Purpose     : Pico Network design as per the 17A SNID layout
# Description : Modify the codebase to build pico sims at any simulation
#               number
# Date        : 20-June-2015
# Who         : xsrilek
####################################################################
#############################################################################
#    END LIB MODULE HEADER
#############################################################################
##########################################
#  Environment
##########################################
package LTE_OSS14;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(isSimPICO getPICOSimStringNodeName getPICOSimIntegerNodeNum getPICOStringNodeName);

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
#  Name : getPICOStringNodeName
#  Description : returns a PICO node string value
#  for a given PICO nodecount number
#  ex : node number 3 returns LTE01pERBS00003
#  Params : $PICOSIMSTART # starting PICO sim num
#           $NODECOUNT # nodecount
#           $PICONUMOFRBS # PICO nodes per sim
#  Example : &getPICOStringNodeName($PICOSIMSTART,$NODECOUNT,$PICONUMOFRBS)
#  Return : returns a PICO node string name
#-----------------------------------------
sub getPICOStringNodeName{

  local($picosimstart,$nodecount,$ttlpiconodespersim)=@_;
  local $nodezeros,$simnodename,$simnum;
 
  # CXP 903 0491-155-1 : ensures that simstart is always at LTE37
 # $picosimstart=37;
 
  $simnum=int(($nodecount)/$ttlpiconodespersim);
  if($nodecount==$ttlpiconodespersim*$simnum){$simnum=$simnum-1;}
  $nodecount=$nodecount-($ttlpiconodespersim*$simnum);
  $simnum=$simnum+1;

  if (($simnum<0)||($nodecount<0)){$simnodename="ERROR";return($simnodename);}
  #if(($simnum<1)||($nodecount==$ttlpiconodespersim)){$simnum=$picosimstart;}
  #elsif($simnum>0){
  #    $nodecount=$nodecount-($ttlpiconodespersim*$simnum);
  #    $simnum=$simnum+$picosimstart;}

  if($nodecount<10){$nodezeros="0000";}
   elsif($nodecount<100){$nodezeros="000";}
    else{$nodezeros="00";}
  if($simnum<=9)
    {$simnodename="LTE0$simnum"."pERBS".$nodezeros.$nodecount;}
  else
    {$simnodename="LTE$simnum"."pERBS".$nodezeros.$nodecount;}# end else
  return($simnodename);
}# end getPICOStringNodeName
#------------------------------------------------------------
#  Name : isSimPICO
#  Description : determines if a NETSim simulation is of type
#                PICO or not based on the name of the simulation
#
#  Params : $SimulationName = name of the NETSim simulation
#  Example : &isSimPICO($SimName);
#            &isSimPICO("LTESRBSV1x160-RVPICO-FDD-LTE02");
#
#  Returns : YES if simulation is of type PICO
#            NO if simulation is NOT of type PICO ie. LTE
#---------------------------------------------------------------
sub isSimPICO{
    local ($simname)=@_;
    local $returnvalue="ERROR";
    local $simserachvalue="PICO";

    # check param is valid
    if (length($simname)<1){return $returnvalue;}
    
    # check for PICO simnam
    if($simname=~m/PICO/){
       $returnvalue="YES"}# end if
    else{$returnvalue="NO";}# end else
    return($returnvalue);
} # end isSimPICO
#-----------------------------------------
#  Name : getPICOSimStringNodeName
#  Description : returns a string value
#  for a netsim PICO simulation node name
#  ex : node string name LTE01pERBS00003
#  Params : $LTE # simnum
#           $COUNT # nodecount
#  Example : getPICOSimStringNodeName($LTE,$COUNT)
#  Return : returns a PICO node string name
#-----------------------------------------
sub getPICOSimStringNodeName{
  local($simnum,$nodecount)=@_;
  local $nodezeros,$simnodename;
  if($nodecount<10){$nodezeros="0000";}
   elsif($nodecount<100){$nodezeros="000";}
    else{$nodezeros="00";}
  if($simnum<=9)
    {$simnodename="LTE0$simnum"."pERBS".$nodezeros.$nodecount;}
  else
    {$simnodename="LTE$simnum"."pERBS".$nodezeros.$nodecount;}# end else
  return($simnodename);
}# end getPICOSimStringNodeName
#-----------------------------------------
#  Name : getPICOSimIntegerNodeNum
#  Description : returns an integer value
#  for a netsim PICO simulation node string
#  within a PICO network
#  ex : LTE01pERBS00003 returns 3
#  Params : $PICOSIMSTART # starting PICO sim num
#           $LTE # actual script simnum
#           $COUNT # nodecount
#           $PICONUMOFRBS # total PICO nodes
#  Example :&getPICOSimIntegerNodeNum($PICOSIMSTART,$LTE,$COUNT,$PICONUMOFRBS)
#  Return : returns an integer node num
#           for a netsim PICO simulation
#           string node name
#-----------------------------------------
sub getPICOSimIntegerNodeNum{
  local($simstart,$simnum,$nodecount,$ttlsimnodes)=@_;
  local $intnodenum;

  # CXP 903 0491-114-1 : ensures that simstart is always at LTE51
 # $simstart=37;

 # $simnum=($simnum-$simstart+1);
  if ($simnum==1){ # first LTE simulation
      $intnodenum=$nodecount;}# end if
  else{$intnodenum=$nodecount+($ttlsimnodes*($simnum-1));}

  if($intnodenum>$ttlsimnodes){
     $intnodenum=(($simnum-1)*$ttlsimnodes)+$nodecount;
  }# end if
  return($intnodenum);
}# end sub getPICOSimIntegerNodeNum
########################
# END LIB MODULE
########################
