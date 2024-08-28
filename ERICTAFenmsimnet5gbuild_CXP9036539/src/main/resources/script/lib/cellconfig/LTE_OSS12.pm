#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  LTE_OSS12 (v5.0)
#
#     Description : Contains all functions related to updates for LTE OSS12.2
#                   30K network
#
#     CDM :
#
#     Functions : createGSMFreqGroup($NETWORKCELLSIZE,$CELLNUM);
#                 getIPv6Sims($IPV4IPV6,NUMOFRBS,$NETWORKCELLSIZE);
#                      
#############################################################################
#############################################################################
# Version1    : LTE 17A
# Revision    : CXP 903 0491-268-1
# Jira        : NSS-5225
# Purpose     : Reduce the time taken for Eutra Scripts for last sims.
# Description : To make build time uniform for all sims, logic of
#               generating data has been changed such that it will be
#               same for all nodes.
# Date        : Oct 2016
# Who         : xmitsin
####################################################################
#############################################################################
# Version2    : 16.17
# Revision    : CXP 903 0491-272-1
# Jira        : NSS-7884
# Purpose     : Eutra Network data laoding optimization
# Description : Fix of optimization of Eutra Network data loading
# Date        : Nov 2016
# Who         : xkatmri
#############################################################################
####################################################################
#    END LIB MODULE HEADER
#############################################################################
##########################################
#  Environment
##########################################
package LTE_OSS12;
require Exporter;
@ISA=qw(Exporter);
# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT=qw(createGSMFreqGroup getIPv6Sims buildLTENetworkBlocks getLTENetworkProxies
           getNodeFlexibleCellSize getNodeFlexibleCellIndex getNodeFlexibleCellfromCellIndex
           getConfigGenericnodecellsValue getLastTtlNetworkBlocks quickgetNodeFlexibleCellfromCellIndex
           getNetworkEUtranFrequencyBands getEUtranExternalNodes randomLTENetworkProxies 
           getLastTtlNetworkBlocksNodenum);
use Cwd;
use POSIX;
use LTE_CellConfiguration;
##########################################
# Vars
##########################################
my $gen=".."x1;
#my $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
##########################################
# funcs
##########################################
#-----------------------------------------------------
#  Name : getLTENetworkProxies
#  Description : gets the network EUtran cell proxies
#  as defined by the TERE where the vallues are as
#  below and reside in the CONFIG.env
#
# --Node Cells-----------------4---1---3---6--Req30Knetwork--Actual30Knetwork
# --ExtENodeBFunctions---------30--30--30--30-225,000--------225,000
# --ExternalEUtranCellProxies--48--34--36--72-360,000--------376,500
# --InterEUtranCellRelations---136-34--102-204-1,020,000-----1,020,000
# --IntraEUtranCellRelations---3---0---2---5---22,500--------22,500
#
#  Params : GENERICNODECELLS,EXTERNALENODEBFUNCTION_MAJOR,EXTERNALENODEBFUNCTION_MINOR,
#  EXTERNALEUTRANCELLPROXIES_MAJOR,EXTERNALEUTRANCELLPROXIES_MINOR,INTEREUTRANCELLRELATIONS_MAJOR,
#  INTEREUTRANCELLRELATIONS_MINOR,NETWORKCELLSIZE
#  Example : @networkblockswithlteproxies=&getLTENetworkProxies($CELLPATTERN,$GENERICNODECELLS,$EXTERNALENODEBFUNCTION,
#                                                               $EXTERNALEUTRANCELLPROXIES_MAJOR,$EXTERNALEUTRANCELLPROXIES_MINOR,$INTEREUTRANCELLRELATIONS_MAJOR,
#                                                               $INTEREUTRANCELLRELATIONS_MINOR,$NETWORKCELLSIZE,@networkblocks);
#  Return :
#
#------------------------------------------------------
sub getLTENetworkProxies{
    local ($CELLPATTERN,$GENERICNODECELLS,$LTENETWORKBREAKDOWN,$EXTERNALENODEBFUNCTION,
           $EXTERNALEUTRANCELLPROXIES_MAJOR,$EXTERNALEUTRANCELLPROXIES_MINOR,
           $NETWORKCELLSIZE,@networkblocks)=@_;
    local @cellpattern=split(/\,/,$CELLPATTERN);
    local (@PRIMARY_NODECELLS)=&buildNodeCells(@cellpattern,$NETWORKCELLSIZE);
    local @networkblockswithlteproxies;
    local @genericnodecells=split(/\,/,$GENERICNODECELLS);
    local @externaleutrancellproxies_major=split(/\,/,$EXTERNALEUTRANCELLPROXIES_MAJOR);
    local @externaleutrancellproxies_minor=split(/\,/,$EXTERNALEUTRANCELLPROXIES_MINOR);
    # start size network by major minor breakdown
    local $ttlnetworknodes=int($NETWORKCELLSIZE/4);# ttl lte nodes in network
    local $ltenetwork_major=$LTENETWORKBREAKDOWN,$ltenetwork_minor=$LTENETWORKBREAKDOWN;
    $ltenetwork_major=~s/\:.*//;$ltenetwork_major=~s/^\s+//;$ltenetwork_major=~s/\s+$//;
    $ltenetwork_minor=~s/^.*://;$ltenetwork_minor=~s/^\s+//;$ltenetwork_minor=~s/\s+$//;
    local $ttlnetworknodes_major=int(($ttlnetworknodes/100)*$ltenetwork_major);
    local $ttlnetworknodes_minor=int(($ttlnetworknodes/100)*$ltenetwork_minor);
    # end size network by major minor breakdown
    local $lastnetworkblock=&getLastTtlNetworkBlocks(@networkblocks);
    local $networkblock=$lastnetworkblock-1;
    local $element=0,$tempnetworkblock,$tempnodenum,$tempnodenum2,$tempnodenum3,$tempcellid,$tempcellid2,$counter1;
    local $concattempcellid2,$concattempcellid3;
    local $tempcellproxies,$tempexternalenodeb,$tempexternaleutrancellproxies;
    local $SubBlockNum;# sub network blocks either 1 or 2 in the network
    local $nodecellsize,$tempnodecellindex,$tempnodecellindex1,$tempnodecellindex2;
    local $arraycounter=0,$tnodecounter,$arraysize,$tempblocknum;
    local $tempnodenum0,$nodematched=0;
    # cycle thru network blocks and allocate cell proxies
    $element="";$SubBlockNum=1;$arraycounter=0;
    ########################################################
    # START RULE 1 : Network Blocks <= Total Network Blocks
    ########################################################
    $arraysize=@networkblocks-1; $element=0;
    #print "DEBUG $networkblock $lastnetworkblock...$arraysize...$element\n";

    while ($networkblock<=$lastnetworkblock){# start while RULE 1

          # highlights network block under investigation
          if($SubBlockNum>2){$SubBlockNum=1;}# end if

          while($element<=$arraysize){# start while network blocks
                  $element=~s/^\s+//;$element=~s/\s+$//;
                  if($networkblocks[$element]=~/BLOCK/){# start if get network block num
                     $tempnetworkblock=$networkblocks[$element];
                     $tempnodenum=$networkblocks[$element];
                     $tempnetworkblock=~s/NodeNum.*//;
                     $tempnetworkblock=~s/BLOCK//;
                     $tempnetworkblock=~s/^\s+//;$tempnetworkblock=~s/\s+$//;
                     if($networkblock!=$tempnetworkblock){last;}

                     if($networkblock==$tempnetworkblock){# check network block
                      $tempnodenum=~s/^.*m//;
                      $tempnodenum=~s/^\s+//;$tempnodenum=~s/\s+$//;
                     }# end  if
                     $element++;
                     next;
                   }# end if get network block num
              $tempcellid=$networkblocks[$element];
              $nodecellindex=&getNodeFlexibleCellIndex($tempcellid,$NETWORKCELLSIZE,@PRIMARY_NODECELLS);
              $tempnodecellindex=$nodecellindex;
              ####################################################
              # START RULE 2 : CellProxies<=EXTERNALENODEBFUNCTION
              # START RULE 3 : CellProxies<=EXTERNALEUTRANCELLPROXIES
              ####################################################
              # NOTE : EXTERNALEUTRANCELLPROXIES must be >= EXTERNALENODEBFUNCTION
              $tempexternalenodeb=$EXTERNALENODEBFUNCTION;
              $tempcellproxies=1;
              
              # determine network breakdown cell proxies
              $nodecellsize=&getNodeFlexibleCellSize($tempnodenum,@PRIMARY_NODECELLS);
 
              if($tempnodenum>$ltenetwork_major){
                 $tempexternaleutrancellproxies=&getConfigGenericnodecellsValue($nodecellsize,$GENERICNODECELLS,
                                                                                $EXTERNALEUTRANCELLPROXIES_MINOR);
              }# end of
              else {$tempexternaleutrancellproxies=&getConfigGenericnodecellsValue($nodecellsize,$GENERICNODECELLS,
                                                                          $EXTERNALEUTRANCELLPROXIES_MAJOR);
              }# end else
               
              # id external nodenum to establish network block handshake
              if($SubBlockNum==1)
                 {$tempnodenum2=($networkblock*$tempexternalenodeb)+1;
                  $tempblocknum=$tempnodenum2;}
               if($SubBlockNum==2)
                   {$tempnodenum2=$tempblocknum-$tempexternalenodeb;}
              $tempnodenum3=$tempnodenum2;$concattempcellid2="";$tnodecounter=1;

              while($tempcellproxies<=$tempexternaleutrancellproxies){ # start inner while cell proxies

                    # check network block not exceeded
                    if($tnodecounter>$tempexternalenodeb){
                       $tempnodenum3=$tempnodenum2;
                       $tnodecounter=1;
                    }# end if
                    
                    ######################################
                    # start process enodebfunction
                    ######################################
                    if($tempcellproxies<=$tempexternalenodeb){ # start if enodefunction

                        $tempcellid2=&getNodeFlexibleCellfromCellIndex($tempnodenum3,$tempnodecellindex,@PRIMARY_NODECELLS);
                        if($tempcellid2==0){# handle where cell index does not exist
                           $nodecellsize=&getNodeFlexibleCellSize($tempnodenum3,@PRIMARY_NODECELLS);
                           if($nodecellsize==1){
                              $tempnodecellindex1=$nodecellsize;}
                           else {$tempnodecellindex1=$nodecellsize-1;}# end else
                                 $tempcellid2=&getNodeFlexibleCellfromCellIndex($tempnodenum3,$tempnodecellindex1,@PRIMARY_NODECELLS);
                        }# end if
                    }# end if enodefunction
                    ######################################
                    # end process enodebfunction
                    ######################################

                    #########################################
                    # start process externaleutrancellproxies 
                    #########################################
                    else{ $tempnodecellindex2=$tempnodecellindex;

                          if(ceil($tempcellproxies/$tempexternalenodeb)==2){
                             $nodecellsize=&getNodeFlexibleCellSize($tempnodenum3,@PRIMARY_NODECELLS);
                             $tempnodecellindex2=($nodecellsize);
                          }# end if

                          if(ceil($tempcellproxies/$tempexternalenodeb)==1){
                             $nodecellsize=&getNodeFlexibleCellSize($tempnodenum3,@PRIMARY_NODECELLS);
                             $tempnodecellindex2=($nodecellsize-1);
                          }# end if

                          if(ceil($tempcellproxies/$tempexternalenodeb)==3){
                             $nodecellsize=&getNodeFlexibleCellSize($tempnodenum3,@PRIMARY_NODECELLS);
                             $tempnodecellindex2=($nodecellsize-2);
                          }# end if
             
                          #else{$tempnodecellindex2++;}# end else

                          $tempcellid2=&getNodeFlexibleCellfromCellIndex($tempnodenum3,$tempnodecellindex2,@PRIMARY_NODECELLS);
                          
                          if($tempcellid2==0){# handle where cell index does not exist
                             $nodecellsize=&getNodeFlexibleCellSize($tempnodenum3,@PRIMARY_NODECELLS);
                         
                          if($nodecellsize==1){
                             $tempnodecellindex2=$nodecellsize;}# end inner else
                          else {$tempnodecellindex2=$nodecellsize-1;}# end else
                               $tempcellid2=&getNodeFlexibleCellfromCellIndex($tempnodenum3,$tempnodecellindex2,@PRIMARY_NODECELLS);
                          }# end if
                    }# end else
                    #########################################
                    # end process externaleutrancellproxies
                    #########################################
                    $concattempcellid2="$concattempcellid2$gen$tempnodenum3$gen$tempcellid2";
                    $tempnodenum3++;
                    $tempcellproxies++;
                    $tnodecounter++;
              }# end inner while cell proxies
              ##################################################
              # END RULE 2 : CellProxies<=EXTERNALENODEBFUNCTION
              # END RULE 3 : CellProxies<=EXTERNALEUTRANCELLPROXIES
              ##################################################
              # write out results
              $tempcellproxies=$tempcellproxies-1;
              $networkblockswithlteproxies[$arraycounter]="Nodenum $tempnodenum CellIndex $nodecellindex CellID $tempcellid ExtCells $tempcellproxies $concattempcellid2";
            $arraycounter++;
            $element++;
          }# end while network blocks
          $networkblock++;$SubBlockNum++;
    }# end while
    #######################################################
    # END  RULE 1 : Network Blocks <= Total Network Blocks
    #######################################################
    return(@networkblockswithlteproxies);
}# end getLTENetworkProxies
#------------------------------------------------------
#  Name : getNodeFlexibleCellSize
#  Description : gets the number of flexible cells in
#  an instance of a node.
#
#  Params :  nodenum ,@PRIMARY_NODECELLS
#  Example : $nodecellsize=&getNodeFlexibleCellSize($nodenum,@PRIMARY_NODECELLS);
#  Return : returns the number of flexible cells in a node
#-------------------------------------------------------
sub getNodeFlexibleCellSize{
   local ($nodenum,@PRIMARY_NODECELLS)=@_;
   local $nodecellsize;
   local @primarycells=@{$PRIMARY_NODECELLS[$nodenum]};
   $nodecellsize=@primarycells;
   if($nodecellsize<1){$nodecellsize="FATAL ERROR : $nodecellsize is not a valid nodecell size";}
   return($nodecellsize);
}# end getNodeFlexibleCellIndex
#------------------------------------------------------
#  Name : getNodeFlexibleCellIndex
#  Description : gets the index of a flexible cell
#  within an instance of a node with numerically sorted
#  cells ex: in a 30K network nodenum 1 has cells
#  1,177,2,178,3,179 where cell 177 has an cell index of 2 
#
#  Params : cellid,NETWORKCELLSIZE,@PRIMARY_NODECELLS
#  Example : $nodecellindex=&getNodeFlexibleCellIndex($cellid,$NETWORKCELLSIZE,@PRIMARY_NODECELLS);
#  Return : returns the index number of a flexible cell
#           in a node
#------------------------------------------------------
sub getNodeFlexibleCellIndex{
    local ($cellid,$NETWORKCELLSIZE,$nodeNum,$blockSize,@PRIMARY_NODECELLS)=@_;
    local $nodenum=&getNodeNumfromFlexibleCellId($cellid,$NETWORKCELLSIZE,$nodeNum,$blockSize,@PRIMARY_NODECELLS);
    local @primarycells=@{$PRIMARY_NODECELLS[$nodenum]};
    local $element,$counter=1;
    local @primarycells=@{$PRIMARY_NODECELLS[$nodenum]};
    
    foreach $element(@primarycells){
                     if($element==$cellid){last;} # match
                     $counter++;
    }# end foreach
    $nodecellindex=$counter;
    if($nodecellindex<1){$nodecellindex="FATAL ERROR : $nodecellindex is not a valid nodecell index";}
    return($nodecellindex);
}# end getNodeFlexibleCellIndex
#------------------------------------------------------
#  Name : quickgetNodeFlexibleCellfromCellIndex
#  Description : gets the index of a flexible cell
#  within an instance of a node with numerically sorted
#  cells ex: in a 30K network nodenum 1 has sorted cells
#  1,2,3,177,178,179 where a get cell index of 4 returns
#  177 for nodenum 1.
#
#  Params :  nodenum,cellindex,networkblocks
#  Example : $nodecellid=&quickgetNodeFlexibleCellfromCellIndex($nodenum,$cellindex,@networkblocks);
#  Return : returns the node flexible cellid for an instance
#  of a cellindex or 0 when no cellindex exists
#------------------------------------------------------
sub quickgetNodeFlexibleCellfromCellIndex{
    local ($nodenum,$cellindex,@networkblocks)=@_;
    local $nodecellid=0,$element,$tempnodenum,$counter=0;
    local $tempcellindex=1,$matchstatus=0;
    foreach $element(@networkblocks){
                     if($element=~/BLOCK/){
                        $tempnodenum=$element;
                        $tempnodenum=~s/^.*m//;
                        $tempnodenum=~s/^\s+//;$tempnodenum=~s/\s+$//;
                     }# end if
                     if($tempnodenum==$nodenum){$counter++;last;} # found nodenum
                     $counter++;
    }# end foreach
    $element="test";
    while (!($element=~/BLOCK/)){
             if(($tempcellindex<1)||($tempcellindex>6)){last;}# oops
             if($tempcellindex==$cellindex){
                $nodecellid=$networkblocks[$counter];$matchstatus=1;last;
             }# end if
             $counter++;$tempcellindex++;
    }# end while
    if($matchstatus==0){$nodecellid=0;}
    return($nodecellid);
}# end quickgetNodeFlexibleCellfromCellIndex
#------------------------------------------------------
#  Name : getNodeFlexibleCellfromCellIndex
#  Description : gets the index of a flexible cell
#  within an instance of a node with numerically sorted
#  cells ex: in a 30K network nodenum 1 has sorted cells
#  1,2,3,177,178,179 where a get cell index of 4 returns
#  177 for nodenum 1.
#
#  Params :  nodenum,cellindex,@PRIMARY_NODECELLS
#  Example : $nodecellid=&getNodeFlexibleCellfromCellIndex($nodenum,$cellindex,@PRIMARY_NODECELLS);
#  Return : returns the node flexible cellid for an instance
#  of a cellindex or 0 when no cellindex exists
#------------------------------------------------------
sub getNodeFlexibleCellfromCellIndex{
     local ($nodenum,$cellindex,@PRIMARY_NODECELLS)=@_;
     local @primarycells=@{$PRIMARY_NODECELLS[$nodenum]};
     local $cellid=0,$element,$counter=1;
     local @sorted_primarycells=sort {$a<=>$b} @primarycells;
     # cycle thru network
     foreach $element(@sorted_primarycells){
             if($cellindex==$counter){$cellid=$element;last;}
             $counter++;
     }# end foreach
     if($cellid<0){$cellid="FATAL ERROR : $cellid does not have a valid cell index";}
     return($cellid);
}# end getNodeFlexibleCellfromCellIndex
#------------------------------------------------------
#  Name : buildLTENetworkBlocks
#  Description : gets the network block size for an
#  instance of a network. The network blocks are
#  ordered in blocks of two each of size EXTERNALENODEBFUNCTION
#  covering the whole network. Continguous network blocks are
#  related to each other in groups of two network blocks ex : Block 1
#  is bi-directonally related to Block 2 and  Block 3 is bi-directonally
#  related to Block 4 etc. The function takes in a nodenum and assigns the
#  two network blocks where that nodenum lives within the ttl network.
#
#  Params : CELLPATTERN,LTENETWORKBREAKDOWN,EXTERNALENODEBFUNCTION,NETWORKCELLSIZE
#  Example :@networkblocks=&buildLTENetworkBlocks($nodenum,$CELLPATTERN,$LTENETWORKBREAKDOWN,
#           $EXTERNALENODEBFUNCTION_MAJOR,$EXTERNALENODEBFUNCTION_MAJOR,$NETWORKCELLSIZE);
#  Return : returns 2 network blocks and associated cells that
#           cover the nodenum within the network/NETWORKCELLSIZE
#-------------------------------------------------------
sub buildLTENetworkBlocks{
    local ($nodenum,$CELLPATTERN,$LTENETWORKBREAKDOWN,$EXTERNALENODEBFUNCTION,$NETWORKCELLSIZE)=@_;
    local @cellpattern=split(/\,/,$CELLPATTERN);
    local (@PRIMARY_NODECELLS)=&buildNodeCells(@cellpattern,$NETWORKCELLSIZE);
    local @NetworkBlockByCells=();
    local $ttlnetworknodes=int($NETWORKCELLSIZE/4);# ttl lte nodes in network
    local $nodecounter,$arraycounter,$networkblocknum,$networkblockcounter;
    local @primarycells,@sorted_primarycells;
    local $element1,$acounter2=0;$match=0;
    local $tempextenodebfunction=($EXTERNALENODEBFUNCTION*2);
    local $nodeblock;$blockstart;$blockend,$blockstartnum,$blockendnum;
    
    # cycle thru network configuration breakdown
    $arraycounter=0;$networkblocknum=1;$networkblockcounter=1;
    # verify nodenum is valid within the ttl network
    if ($nodenum>$ttlnetworknodes){
        $NetworkBlockByCells[0]="FATAL ERROR : $nodenum exceeds ttl network nodes";
        return(@NetworkBlockByCells);
    }# end if
    # get the sub network blocks
    $nodeblock=ceil($nodenum/$EXTERNALENODEBFUNCTION);
    if(($nodeblock/2)=~/\./){ # float
       $blockstart=$nodeblock;
       $blockend=$nodeblock+1;
    }# end if
    else{
         $blockstart=$nodeblock-1;
         $blockend=$nodeblock;
    }# end else
    # get blocknodenums
    if($blockstart==1){$blockstartnum=1;}
     else{$blockstartnum=$EXTERNALENODEBFUNCTION*($blockstart-1)+1;} # end else
    if($blockend==1){$blockendnum=1;}
     else{$blockendnum=$EXTERNALENODEBFUNCTION*($blockend);} # end else
     $nodecounter=$blockstartnum;
     $networkblocknum=$blockstart;
    ################################ 
    # start build ttl network blocks
    ################################ 
    while ($nodecounter<=$blockendnum){

           if($networkblockcounter>$EXTERNALENODEBFUNCTION){
              $networkblockcounter=1;
              $networkblocknum++;
               
           }# end if

           $NetworkBlockByCells[$arraycounter]="BLOCK $networkblocknum NodeNum $nodecounter";
           $arraycounter++;

           @primarycells=@{$PRIMARY_NODECELLS[$nodecounter]};
           @sorted_primarycells=sort {$a<=>$b} @primarycells;

           $element="";
           foreach $element(@sorted_primarycells){
                   $NetworkBlockByCells[$arraycounter]="$element";
                   $arraycounter++;
           }# end foreach
           $nodecounter++;$networkblockcounter++;
    }# end while 
    ################################ 
    # end build ttl network blocks
    ################################ 

    return(@NetworkBlockByCells);
}# end buildLTENetworkBlocks
#------------------------------------------------------
#  Name : getIPv6Sims
#  Description : enables X2 by determing the allocation 
#                and spread of IPV6 IPs across the LTE 
#                network on a simulation basis.
#                eg. getIPV6Sims might return (LTE01,LTE05,LTE10...)
#                which indicates the LTE sim numbers where IPs are
#                of type IPV6 in order to enable X2
#                the remaining sim numbers are of type IPV4                  
#                
#  Params : $IPV4IPV6,$NUMOFRBS,$NETWORKCELLSIZE
#  Example :&getIPv6Sims($IPV4IPV6,NUMOFRBS,$NETWORKCELLSIZE)
#  Return : returns a populated array containing data
#           giving list of simulations where IPV6 is used 
#           to enable X2
#-------------------------------------------------------
sub getIPv6Sims{ 
               local ($ipv4ipv6,$numofrbs,$networkcellsize)=@_;
               local $ttlnumberofnetworksims=ceil(($networkcellsize/4)/$numofrbs);
               local $tempip="";$ipv4breakdown;$ipv6breakdown;
               local $ipv6siminterval="";# ipv6 simulation interval
               local @ipv6simspread=();$loopcounter=1;$match=1;$arrayindex=0; 
               $tempip=$ipv4ipv6;$tempip=~s/\:.*//;$ipv4breakdown=$tempip;
               $tempip=$ipv4ipv6;$tempip=~s/.*\://;$ipv6breakdown=$tempip;
               $ipv6siminterval=int(100/$ipv6breakdown);
               # cycle thru sim network and allocate x2 ipv6 sims
               while ($loopcounter<=$ttlnumberofnetworksims){
                     if($match==$ipv6siminterval){

                        if($loopcounter<10){
                          $ipv6simspread[$arrayindex]="LTE0".$loopcounter;
                        }# end inner if

                        if($loopcounter>=10){
                           $ipv6simspread[$arrayindex]="LTE$loopcounter";
                        }# end inner if
                        $arrayindex++;$match=0;
                     }# end if
               $loopcounter++;$match++;
               }# end while
               return(@ipv6simspread);   
}# end getIPv6Sims
#------------------------------------------------------
#  Name : createGSMFreqGroup
#  Description : apportions GSMFreqGroups throughout 
#                a network based on breakdown as defined
#                in TERE 16K and 20K documents see ->
#                CDM : 1/152 74-AOM 901 075 - PA13 - lte_gen_net_cfg-20  
#  Params : NETWORKCELLSIZE and CELLNUM
#  Example :&createGSMFreqGroup($NETWORKCELLSIZE,$CELLNUM)
#  Return : returns a populated array containing data
#           giving breakdown of GSMFreqGroups by
#           
#  nodenumber-freqgroup-fregroup2-freqgroup3-groupnodesize
#
#  array data return details :
#  nodenumber=node count
#  freqgroup=primary GSM freqgroup for nodenumber
#  fregroup2=neighbouring freqgroup for nodenumber
#  fregroup3=neighbouring freqgroup for nodenumber # 3 freqgroups
#  groupnodesize=number of nodes in each freqgroup     
#-------------------------------------------------------
sub createGSMFreqGroup{
   local ($networkcellsize,$cellnum)=@_;
   local @GeranFreqGroup=(),$freqgroup="";
   local $groupnumbers=9,$groupnodesize; # GSMFreqGroups and nodes in group
   local $ttlnetworknodes=int($networkcellsize/$cellnum);
   local $loopcounter=0,$nodenumber=1,$stringelement;
   # freqgroup layout
   local $freqgroup2,$freqgroup3,$maxgroup1=$groupnumbers/3,$maxgroup2=($groupnumbers/3)*2,$maxgroup3=$groupnumbers;
   local $counter=1,$counter2=3;
   local @SORTEDGeranFreqGroup=(); 

   if($ttlnetworknodes<1){
       $GeranFreqGroup[0]="ERROR invalid network nodes of $ttlnetworknodes";
       return(@GeranFreqGroup);}

   # GeranFreqGroup breakdown algorithm
   $groupnodesize=int($ttlnetworknodes/$groupnumbers);
   if($groupnodesize<1){
       $GeranFreqGroup[0]="ERROR invalid GSMFreqGroups of $groupnodesize";
       return(@GeranFreqGroup);}

   while($ttlnetworknodes>=$nodenumber){
         # determine GSMFreqGroup
         if ($nodenumber<=$groupnodesize){
             $freqgroup=1;
         }# end if
         else{$freqgroup=ceil($nodenumber/$groupnodesize);}

         if($freqgroup>$groupnumbers){$freqgroup=$groupnumbers;}
         # determine neighbouring groups
         if($freqgroup==1|$freqgroup==4|$freqgroup==7){$freqgroup2=$freqgroup+1;$freqgroup3=$freqgroup+2;}
         if($freqgroup==2|$freqgroup==5|$freqgroup==8){$freqgroup2=$freqgroup-1;$freqgroup3=$freqgroup+1;}
         if($freqgroup==3|$freqgroup==6|$freqgroup==9){$freqgroup2=$freqgroup-2;$freqgroup3=$freqgroup-1;}

         @SORTEDGeranFreqGroup=sort($freqgroup,$freqgroup2,$freqgroup3);
        $freqgroup=$SORTEDGeranFreqGroup[0];$freqgroup2=$SORTEDGeranFreqGroup[1];$freqgroup3=$SORTEDGeranFreqGroup[2];
         $stringelement="$nodenumber$gen$freqgroup$gen$freqgroup2$gen$freqgroup3$gen$groupnodesize";
         
         $GeranFreqGroup[$loopcounter]="$stringelement";
         $loopcounter++;$nodenumber++;
   }# end while

   return(@GeranFreqGroup);
}# end createGSMFreqGroup
#------------------------------------------------------
#  Name : getConfigGenericnodecellsValue
#  Description : the CONFIG.env GENERICNODECELLS
#  corresponds to cell patterns or cell proxies as defined
#  by for example EXTERNALEUTRANCELLPROXIES_MAJOR etc.
#  The CONFIG.env values GENERICNODECELLS=4,1,3,6 correspond
#  to EXTERNALEUTRANCELLPROXIES_MAJOR=48,34,36,72 in that
#  for example GENERICNODECELLS=4 returns EXTERNALEUTRANCELLPROXIES_MAJOR=48
#  which means that the network requirement is that 4 cells have
#  48 externaleutrancellproxies, 1 has 34, 3 has 36 etc.
#  Params : $cellsize - either cellsize 1,3 or 6
#           $GENERICNODECELLS - ordered cell sizes
#           $value - ordered value from the CONFIG.env file eg.
#                    INTEREUTRANCELLRELATIONS_MAJOR or EXTERNALEUTRANCELLPROXIES_MAJOR etc.
#  Example : $value=&getConfigGenericnodecellsValue($cellsize,$GENERICNODECELLS,$value);
#            $value=&getConfigGenericnodecellsValue(1,$GENERICNODECELLS,$EXTERNALEUTRANCELLPROXIES_MAJOR);
#  Return : returns the corresponding value from the CONFIG.env
#  for the corresponding $GENERICNODECELLS
#-------------------------------------------------------
sub getConfigGenericnodecellsValue{
    local ($cellsize,$GENERICNODECELLS,$value)=@_;
    local @genericnodecells=split(/\,/,$GENERICNODECELLS);
    local @value=split(/\,/,$value);
    local $element1,$element2,$counter=0;
    local $configvalue="FATAL ERROR : cannot locate the GENERICNODECELLS CONFIG.env value";
    # cycle thru CONFIG.env $GENERICNODECELLS
    foreach $element1(@genericnodecells){
            $element1=~s/^\s+//;$element1=~s/\s+$//;
            if($cellsize==$element1){# match
               $configvalue=$value[$counter];
            }# end if
            $counter++;
    }# end foreach
    return($configvalue);
}# end sub getConfigGenericnodecellsValue
#------------------------------------------------------
#  Name : getLastTtlNetworkBlocks
#  Description : gets the last viable network block
#  from a total network where each network block in the
#  network consists of two blocks eg. a 30K network with
#  an EXTERNALENODEBFUNCTION=30 has 250 network blocks
#  and the last viable network block = 250 which has
#  124 sub network blocks
#  Params : @networkblocks - total network blocks
#  Example : $lastnetworkblock=&getLastTtlNetworkBlocks(@networkblocks);
#  Return : returns the last viable network block in a
#  predefined network
#-------------------------------------------------------
sub getLastTtlNetworkBlocks{
    local (@networkblocks)=@_;
    local $element,$lastnetworkblock=0;
    # cycle thru the network blocks to get the last network block
    foreach $element(@networkblocks){
            if($element=~/BLOCK/){
               $lastnetworkblock=$element;$lastnetworkblock=~s/NodeNum.*//;
               $lastnetworkblock=~s/BLOCK//;
               $lastnetworkblock=~s/^\s+//;$lastnetworkblock=~s/\s+$//;
            }# end if
    }# end foreach
    if(($lastnetworkblock !=0)&&($lastnetworkblock/2)=~/\./)
       {$lastnetworkblock=$lastnetworkblock-1;}# end if
    return($lastnetworkblock);
}# end getLastTtlNetworkBlocks
#------------------------------------------------------
#  Name : getLastTtlNetworkBlocksNodenum
#  Description : gets the last viable nodenum
#  from a total network where each network block in the
#  network consists of two blocks eg. a 30K network with
#  an EXTERNALENODEBFUNCTION=30 has 250 network blocks
#  and the last viable network block = 250 which would
#  contain the last nodenum in that block
#
#  Params : @networkblocks - total network blocks
#  Example : $lastnodenum=&getLastTtlNetworkBlocksNodenum(@networkblocks);
#  Return : returns the last viable network block nodenum in a
#  predefined network
#-------------------------------------------------------
sub getLastTtlNetworkBlocksNodenum{
    local (@networkblocks)=@_;
    local $element,$lastnodenum=0;
    # cycle thru the network blocks to get the last network block
    foreach $element(@networkblocks){
            if($element=~/BLOCK/){
               $lastnodenum=$element;
               $lastnodenum=~s/^.*m//;
               $lastnodenum=~s/^\s+//;$lastnodenum=~s/\s+$//;
            }# end if
    }# end foreach
    if($lastnodenum !=0){}# end if
    else {$lastnodenum="FATAL ERROR : invalid getLastTtlNetworkBlocksNodenum";}
    return($lastnodenum);
}# end getLastTtlNetworkBlocksNodenum
#------------------------------------------------------
#  Name : getNetworkEUtranFrequencyBands
#  Description : gets the EUtran frequency bands across the
#  network broken down sequentially as follows :
#
#  Frequencey Band 1 = 40% of total network by network blocks
#  Frequencey Band 2 = 48% of total network by network blocks
#  Frequencey Band 4 = 4% of total network by network blocks
#  Frequencey Band 8 = 6% of total network by network blocks
#
#  Params : $NETWORKCELLSIZE,$EXTERNALENODEBFUNCTION,@PRIMARY_NODECELLS
#  Example : @eutranfreqbands=&getNetworkEUtranFrequencyBands($NETWORKCELLSIZE,
#                                                             $EXTERNALENODEBFUNCTION,@PRIMARY_NODECELLS);
#  Return : returns an array by nodenum..freqnum eg 1..1,2..1,3..1 etc.
#-------------------------------------------------------
sub getNetworkEUtranFrequencyBands{
     local ($NETWORKCELLSIZE,$EXTERNALENODEBFUNCTION)=@_;
     local $ttlnetworknodes,$ttlnetworkblocks,$remainingnetworkblocks;
     local $band1,$band2,$band4,$band8;
     local $borderband1,$borderband2,$borderband4,$borderband8;
     local @eutranfreqbands=(),$counter=0,$nodenum=1,$freqnum=0;
     local $nodecellsize;
     
     $ttlnetworknodes=int($NETWORKCELLSIZE/4);
     $ttlnetworkblocks=int($ttlnetworknodes/$EXTERNALENODEBFUNCTION);
     
     if($ttlnetworkblocks<2){
        $eutranfreqbands[$counter]="FATAL ERROR : getNetworkEUtranFrequencyBands returns invalid network blocks $ttlnetworkblocks";
        return(@eutranfreqbands);
     }# end if
     
     # Define Frequency Band 1
     $band1=int($ttlnetworkblocks*40)/100;
     if(($band1/2)=~/\./){$band1++;}# ensure even number of network blocks
     $remainingnetworkblocks=$ttlnetworkblocks-$band1;

     # Define Frequency Band 2
     $band2=int($ttlnetworkblocks*48)/100;
     if(($band2/2)=~/\./){$band2++;}# ensure even number of network blocks
     $remainingnetworkblocks=$remainingnetworkblocks-$band2;

     # Define Frequency Band 4
     $band4=int($ttlnetworkblocks*6)/100;
     if(($band4/2)=~/\./){$band4++;}# ensure even number of network blocks
     $remainingnetworkblocks=$remainingnetworkblocks-$band4;

     # Define Frequency Band 8
     $band8=($ttlnetworkblocks-($band1+$band2+$band4));
     
     ###################################################
     # define band max. network block borders
     ###################################################
     $borderband1=$band1;$borderband2=$band1+$band2;
     $borderband4=$band1+$band2+$band4;
     $borderband8=$band1+$band2+$band4+$band8;
     
     $borderband1=$borderband1*$EXTERNALENODEBFUNCTION;
     $borderband2=$borderband2*$EXTERNALENODEBFUNCTION;
     $borderband4=$borderband4*$EXTERNALENODEBFUNCTION;
     $borderband8=$borderband8*$EXTERNALENODEBFUNCTION;
     
     # assign frequency band per  blocks
     while ($nodenum<=$ttlnetworknodes){
            if($nodenum<=$borderband1){
               $freqnum=1;
            }# end if
            if($nodenum>$borderband1 && $nodenum<=$borderband2){
               $freqnum=2;
            }# end if
            if($nodenum>$borderband2 && $nodenum<=$borderband4){
               $freqnum=4;
            }# end if
            if($nodenum>$borderband4 && $nodenum<=$borderband8){
               $freqnum=8;
            }# end if
            # by nodenum..freqnum
            $eutranfreqbands[$counter]="$nodenum$gen$freqnum";
            $nodenum++;$counter++;
     }# end while
     return(@eutranfreqbands);
}# end getNetworkEUtranFrequencyBands
#------------------------------------------------------
#  Name : getEUtranExternalNodes
#  Description : gets the EUtran external nodes from
#  two network blocks
#
#  Params : @networkblockswithlteproxies(returned from &getLTENetworkProxies)
#  Example : @eutranextnodes=&getEUtranExternalNodes(@networkblockswithlteproxies);
#  Return : an array of unique ascending external enodebfuntion node nums
#-------------------------------------------------------
sub getEUtranExternalNodes{
     local (@networkblockswithlteproxies)=@_;
     local $element,$nodenum,$cellindex,$externalnode;
     local $tempnode="",$tempcellindex,$tempexternalnode;
     local @eutranextnodes=();
     local @tempeutranextnodes=();
     local $counter=0,$counter2=0,$element2="";
     local $startextnum,$started;
     foreach $element(@networkblockswithlteproxies){# inner foreach
             $nodenum=$element;
             $externalnode=$element;
             # get nodenum
             $nodenum=~s/C.*//;$nodenum=~s/Nodenum//;
             $nodenum=~s/^\s+//;$nodenum=~s/\s+$//;
             if($nodenum==$tempnode){next;}# end if
             $tempnode=$nodenum;
             $eutranextnodes[$counter]="Nodenum $nodenum";
             $counter++;
             # get external nodes
             $externalnode=~s/^N.*s//;
             $externalnode=~s/\d+//;
             $externalnode=~s/\..//;
             @tempeutranextnodes=split(/\../,$externalnode);
             # cycle thru external nodes ie. every second one
             $counter2=1;$started=1;$startextnum="xyz";$element2="";
             foreach $element2(@tempeutranextnodes){
                               if(($element2==$startextnum)&&($started>2))
                                   {last;} # duplicate ext nodenum
                               if($counter2>1){$counter2=1;next;}
                               $element2=~s/^\s+//;$element2=~s/\s+$//;
                               $eutranextnodes[$counter]="$element2";
                               if($started==1){$startextnum=$element2;}# end if
                               $counter++;$counter2++;$started++;
             }# end inner foreach
     }# end foreach
     if(@eutranextnodes<1){"FATAL ERROR: invalid value from getEUtranExternalNodes";}
     return(@eutranextnodes);
}# end getEUtranExternalNodes
#------------------------------------------------------
#  Name : randomLTENetworkProxies
#  Description : randomises the LTE network proxies
#  based on output from getLTENetworkProxies
#
#  Params : $EXTERNALENODEBFUNCTION,@PRIMARY_NODECELLS,@networkblockswithlteproxies(returned from &getLTENetworkProxies)
#  Example : @formatlteproxies=&randomLTENetworkProxies( $CELLPATTERN,$NETWORKCELLSIZE,
#                                                       $EXTERNALENODEBFUNCTION,@networkblockswithlteproxies);
#  Return : an array of unique
#-------------------------------------------------------
sub randomLTENetworkProxies{
    local ($CELLPATTERN,$NETWORKCELLSIZE,$EXTERNALENODEBFUNCTION,@networkblockswithlteproxies)=@_;
    local $element;local @formatlteproxies=();
    local $nodenum,$prevnodenum="test",$cellindex,$counter=0;
    local $counter2=1,$nodecellsize;
    local @cellpattern=split(/\,/,$CELLPATTERN);
    local (@PRIMARY_NODECELLS)=&buildNodeCells(@cellpattern,$NETWORKCELLSIZE);
    # probably need to make this more cell random
    local $index6=1; # 6 cell node
    local $index3=1; # 3 cell node
    local $index1=1; # 1 cell node
    local $tempindex;
    
    # cycle thru lte proxies and get random cell proxies
    foreach $element(@networkblockswithlteproxies){
    
                     if($counter2==$EXTERNALENODEBFUNCTION+1){
                        if($index6>6){$index6=1;}
                        if($index3>3){$index3=1;}
                     }# end if
                     
                     if($index6>6){$index6=1;}
                     if($index3>3){$index3=1;}
                     
                     $element=~s/^\s+//;$element=~s/\s+$//;
                     $nodenum=$element;
                     $cellindex=$element;

                     # get nodenum
                     $nodenum=~s/C.*//;$nodenum=~s/Nodenum//;
                     $nodenum=~s/^\s+//;$nodenum=~s/\s+$//;

                     $nodecellsize=&getNodeFlexibleCellSize($nodenum,@PRIMARY_NODECELLS);
                     
                     if($nodecellsize==6){$tempindex=$index6;}
                     elsif($nodecellsize==3){$tempindex=$index3;}
                     else {$tempindex=$index1;}# end else
                     
                     # get cellindex
                     $cellindex=~s/CellID.*//;
                     $cellindex=~s/^.*x//;
                     $cellindex=~s/^\s+//;$cellindex=~s/\s+$//;
                     
                     
                     if(($nodenum != $prevnodenum)&&($cellindex==$tempindex)){
                         $formatlteproxies[$counter]="$element";
                         $counter2++;
                         $counter++;
                         $prevnodenum=$nodenum;
                         #if($nodecellsize==6){$index6++;}
                         #elsif($nodecellsize==3){$index3++;}
                         #else {}# end else
                     }# end if
    }# end foreach
    if(@formatlteproxies<1){$formatlteproxies[0]="FATAL ERROR : randomLTENetworkProxies has 0 output"}
    return(@formatlteproxies);
}# end randomLTENetworkProxies
########################
# END LIB MODULE
########################
