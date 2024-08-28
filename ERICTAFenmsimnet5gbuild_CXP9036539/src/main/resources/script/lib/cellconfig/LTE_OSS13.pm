#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_OSS13 (v1.0)
#
#     Description : Contains all functions related to updates for LTE OSS13
#                   30K network
#
#     Functions :  &getIRATHOMcsvfiledate("...script ended at Mon Jan 14 12:59:42 GMT 2013");
#                  &getIRATHOMConfigfilevalue("CONFIG.env","IRATHOMENABLED");
#                  &getIRATHOMcsvfilerawvalue("MCC=46;MNC=6;MNCLENGTH=2");
#                      
#############################################################################
#   Name: QGORMOR
#   Version v1.1
#
#   description: Updated getuniqueLTEipv4interfaceset to include IPHostLink and also IPOam attributes
#                Also changed the static IPAddressing  to each IPInterface
#
#############################################################################
#    END LIB MODULE HEADER
#############################################################################
##########################################
#  Environment
##########################################
package LTE_OSS13;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(getIRATHOMConfigfilevalue getIRATHOMcsvfilerawvalue getIRATHOMcsvfiledate getuniqueLTEipv4interfaceset generateLte_STNIp);
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
#  Name : getIRATHOMConfigfilevalue
#  Description : returns a value for the
#  /dat/CONFIG.env file which contains
#  preassigned IRATHOM values
#  Params : CONFIG.env &
#           $Value ie. IRATHOMENABLED=YES where
#           $Value=IRATHOMENABLED and return value is YES
#  Example : &getIRATHOMConfigfilevalue("CONFIG.env","IRATHOMENABLED")
#  Return : YES where IRATHOMENABLED=YES
#-----------------------------------------
sub getIRATHOMConfigfilevalue{
    local ($env_file_name2,$env_file_constant2)=@_;
    local @envfiledata2=();
    local $env_file_value2="ERROR";
    # navigate to dat directory
    $envdir2=$env_file_name2;
    if (!-e "$envdir2")
       {print "ERROR : $envdir2 does not exist\n";return($env_file_value2);}
    open FH, "$envdir2" or die $!;
    @envfiledata2=<FH>;close(FH);
    foreach $_(@envfiledata2){
      if ($_=~/\#/){next;} # end if
      if ($_=~/$env_file_constant2/)
          {$env_file_value2=$_;$env_file_value2=~s/^\s+//;
           $env_file_value2=~s/^.*=//;
           $env_file_value2=~s/\s+$//;} # end if
    }# end foreach
    return($env_file_value2);
} # getIRATHOMConfigfilevalue
#------------------------------------------------------------------------
#  Name : getIRATHOMcsvfiledate
#  Description : returns the end date of the
#                input WRAN to LTE relations filename
#        ~/customdata/irathom/IRATHOMWRAN2LTEFILENAME
#                which is labelled IRATHOMWRAN2LTEFILENAME in the
#        ~/dat/CONFIG.env
#   eg. IRATHOMWRAN2LTEFILENAME=UtranData13B_For_LTE.csv
#
#   where UtranData13B_For_LTE.csv is the input file
#   being queried
#
#   Input file lines have the following format :
#
#   eg. ...script ended at Mon Jan 14 12:59:42 GMT 2013
#
#  Params : $fileline ie. single date line entry from the input WRAN to LTE file
#  Example : $fileline=&getIRATHOMcsvfiledate("...script ended at Mon Jan 14 12:59:42 GMT 2013");
#  Return : Mon Jan 14 12:59:42 2013
#--------------------------------------------------------------------------
 sub getIRATHOMcsvfiledate{
      local ($filelinewithdate)=@_; # line with date from csv file
      local ($returnfilelinewithdate);
      # verify param
      if($filelinewithdate eq " "){
         $returnfilelinewithdate=$filelinewithdate;
         $returnfilelinewithdate="ERROR";
         return($returnfilelinewithdate);
      }# end if
      # get WRAN to LTE csv file end date
      $filelinewithdate=~s/...script ended at//;
      $filelinewithdate=~s/GMT\s+//;
      $filelinewithdate=~s/^\s+//;$filelinewithdate=~s/\s+$//;
      $returnfilelinewithdate=$filelinewithdate;
      return($returnfilelinewithdate);
 }# end getIRATHOMcsvfiledate
#------------------------------------------------------------------------
#  Name : getIRATHOMcsvfilerawvalue
#  Description : returns a formated full line value from the
#                input WRAN to LTE relations filename
#        ~/customdata/irathom/IRATHOMWRAN2LTEFILENAME
#                which is labelled IRATHOMWRAN2LTEFILENAME in the
#        ~/dat/CONFIG.env
#   eg. IRATHOMWRAN2LTEFILENAME=UtranData13B_For_LTE.csv
#
#   where UtranData13B_For_LTE.csv is the input file
#   being queried
#
#   Input file lines have the following format :
#
#   eg. ROWID=1;EXTUCFDDID=RNC01-1-1;MUCID=RNC01-1-1;USERLABEL=RNC01-1-1;LAC=1;PCID=1;CID=1;RAC=1;ARFCNVDL=1
#       MCC=46;MNC=6;MNCLENGTH=2
#       ROWID=13;EXTUCFDDID=RNC01-11-1;MUCID=RNC01-11-1;USERLABEL=RNC01-11-1;LAC=1;PCID=13;CID=13;RAC=1;ARFCNVDL=1
#
#  Params : $fileline ie. single data line entry from the input WRAN to LTE file
#  Example : $fileline=&getIRATHOMcsvfilerawvalue("MCC=46;MNC=6;MNCLENGTH=2");
#  Return : 46;6;2
#--------------------------------------------------------------------------
sub getIRATHOMcsvfilerawvalue{
    local ($fileline)=@_; # line from csv file
    local $returnformatfileline;
    local @arrline=();
    local $arrsize=0,$element,$tempelement;
    local $counter=0;
    @arrfileline= split(/;/,$fileline);
    # verify WRAN to LTE csv file line
    if(@arrfileline==0){
       $returnformatfileline="FATAL ERROR : input WRAN to LTE file line empty";
       return($returnformatfileline);
    }# end if
    
    foreach $element(@arrfileline){
                     $tempelement="";
                     $tempelement=$element;
                     $tempelement=~s/.*=/;/;
                     $returnformatfileline="$returnformatfileline$tempelement";
    }# end foreach
    $returnformatfileline=~s/;//;
    $returnformatfileline=~s/^\s+//;$returnformatfileline=~s/\s+$//;
    
    return($returnformatfileline);
}# end getIRATHOMcsvfilerawvalue
#-----------------------------------------------------
#  Name : generateLte_STNIp
#  Description : This function works out the correct IPAddress to assign to the IPInterfaces of the nodes on OSS
#  This function assumes that the STN-ERBS is 1-to-1 and works out the IPAddress according to this. This particular function will
#  need to be
#  updated if there are a one to many relationship between STN and ERBS nodes.
#  For each STN - ERBS connection we assume 2 /30 subnets are used.
#  This means that 8 IP addresses spaces are used for each ERBS to STN connection.
#  Each STN has 7 ports to connect to an ERBS node and 4 which connect to the IPRouter, so to future proof this solution somewhat
#  i have taken
#  this into account and reserved these. 7 * 8 = 56, 4 * 6
#  This means that for each STN network there are 72 address spaces used up.
#############################################################################

sub generateLte_STNIp{
our $QUART1 = 0;
our $QUART2 = 0;
our $QUART3 = 0;
our $nodeid = 0;
    our $target = $_[0];

# Figure out what is my node id
    our $simnumber = substr $target, 3, 2; # Gets the first 2 digits
    our $nodenumber = substr $target, 9, 5;
    our $temp = ($simnumber -1 ) * 160;
    if ( $simnumber == 1 ) {
        $nodeid = $nodenumber + 0; # this is to get rid of the 00001 etc.
    }
    else {
    our $nodeid = $nodenumber + $temp;
}
# Figure out what IPAddress to assign affected node, at the minute this assumes all ICON nodes to have same configuration


# IPAddress is going to look like this for first subnet on each node $QUART1.$QUART2.$QUART3.0
# IPAddress is going to look like this for second subnet on each node $QUART1.$QUART2.$QUART3.4
    if ( $nodeid < 256 ) {
       our $QUART3 = $nodeid;
       our  $QUART2 = 0;
}   else {
       our $QUART3 = $nodeid % 256;
       our $QUART2 = $nodeid / 256;
    }
     our $QUART1 = &getENVfilevalue($ENV, "ICON_LTE_STN_START");


     my @IPInterface1 = [];
     push (@IPInterface1, "vid:100");
     push (@IPInterface1, "vLan:true");
     push (@IPInterface1, "networkPrefixLength:30");
     push (@IPInterface1, "defaultRouter0:$QUART1.$QUART2.$QUART3.1");
     push (@IPInterface1, "defaultRouter1:0.0.0.0");
     push (@IPInterface1, "defaultRouter0:0.0.0.0");
     push (@IPInterface1, "subnet:$QUART1.$QUART2.$QUART3.0/30");


    my @IPInterface2 = [];
     push (@IPInterface2, "vid:900");
     push (@IPInterface2, "vLan:true");
     push (@IPInterface2, "networkPrefixLength:30");
     push (@IPInterface2, "defaultRouter0:$QUART1.$QUART2.$QUART3.5");
     push (@IPInterface2, "defaultRouter1:0.0.0.0");
     push (@IPInterface2, "defaultRouter0:0.0.0.0");
     push (@IPInterface2, "subnet:$QUART1.$QUART2.$QUART3.4/30");

return (\@IPInterface1, \@IPInterface2);
}
#------------------------------------------------------------------------
#  Name : getuniqueLTEipv4interfaceset
#  Description : returns three unique LTE ipinterface addresses based
#  on the nodecount and address_space1 of the ip address
#  ex : 159.107.173.3 equates to address_space1.address_space2.addess_space3.address_space4
#  Params : $address_space1,$nodecount
#           $address_space1 = first portion of ipv4 address eg. 159 in 159.107.173.3
#           $nodecount = node count
#  Example : &getuniqueLTEipv4interfaceset($address_space1,$nodecount);
#  Return : an array containing three unique ipv4 adderesses
#-------------------------------------------------------------------------
sub getuniqueLTEipv4interfaceset{
   local ($address_space1,$nodecount)=@_;
   local ($address_space2=0,$address_space3=0,$address_space4=0);
   local $maxiprange=256;
   local  @IPHostLink = ();
   
   # build unique ipv4 address
   if ( $nodecount < $maxiprange ) {
       $address_space3 = $nodecount;
       $address_space2 = 0;
   }# end if
   else{
        $address_space3 = $nodecount % $maxiprange;
        $address_space2 = int($nodecount/$maxiprange);
   }# end else
   
   # subnet1
   push (@IPHostLink, "$address_space1.$address_space2.$address_space3.0");
   # ipInterface=1  default router 0
   push (@IPHostLink, "$address_space1.$address_space2.$address_space3.1");
   # ipInterface=1 IPAccessHostEt=1
   push (@IPHostLink, "$address_space1.$address_space2.$address_space3.2");
   # ipInterface=2 subnet2
   push (@IPHostLink, "$address_space1.$address_space2.$address_space3.4");
   # ipInterface=2 defaultRouter0
   push (@IPHostLink, "$address_space1.$address_space2.$address_space3.5");
   # ipInterface=2 IpOam=1,Ip=1,IpHostLink=1
   push (@IPHostLink, "$address_space1.$address_space2.$address_space3.6");


   return (@IPHostLink);
} # end getuniqueLTEipv4interfaceset
########################
# END LIB MODULE
########################
