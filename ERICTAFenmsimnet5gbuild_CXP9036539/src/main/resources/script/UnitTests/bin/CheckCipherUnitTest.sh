#!/bin/sh

##########################################################################################################################
# Version     : 1.4
# Revision    : CXP 903 6539-1-31
# JIRA        : NSS-35146, NSS-35147
# Created by  : Vinay Baratam
# Created on  : 06.04.2021
# Purpose     : Adding Ciphers support for vNF-LCM, EVNFM Nodes.
###########################################################################################################################
##########################################################################################################################
# Version     : 1.3
# Revision    : CXP 903 6539-1-26
# JIRA        : NSS-33178
# Created by  : Yamuna Kanchireddygari
# Created on  : 05.11.2020
# Purpose     : Check Ciphers support on VTFRadioNode,vSD,vPP,vRC,RAN-VNFM Nodes.
###########################################################################################################################
##########################################################################################################################
# Version     : 1.2
# Revision    : CXP 903 6539-1-17
# JIRA        : NSS-29323
# Created by  : Yamuna Kanchireddygari
# Created on  : 26.02.2020
# Purpose     : Check Ciphers on VTIF Nodes.
###########################################################################################################################
##########################################################################################################################
# Created by  : Yamuna Kanchireddygari
# Created on  : 02.07.2019
# Purpose     : Check Ciphers on NR Nodes.
###########################################################################################################################

PWD=`pwd`

SimName=$1
       echo "Simulation is: $SimName"
if [[ $SimName == *gNodeBRadio* || $SimName == *NR* || $SimName == *VTIF* || $SimName == *VTFRadioNode* || $SimName == *vPP* || $SimName == *vRC* || $SimName == *vSD* || $SimName == *RAN-VNFM* || $SimName == *VNF-LCM* || $SimName == *EVNFM* ]]
then
       echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SimName' \n .show simnes' | /netsim/inst/netsim_shell | grep -v \">>\" | grep -v \"OK\" | grep -v \"NE\"" > ComEcimNodeData.txt
       cat ComEcimNodeData.txt | awk '{print $1}' > ComEcimNodeData1.txt
       IFS=$'\n' read -d '' -r -a node < ComEcimNodeData1.txt
       Length=${#node[@]}
#       echo "---------node length=$Length---------"
               for i in "${node[@]}"
                do
                  if [[ "$i" == *gNodeBRadio* || "$i" == *NR* || "$i" == *VTIF* || "$i" == *VTFRadioNode* || "$i" == *vPP* || "$i" == *vRC* || "$i" == *vSD* || "$i" == *RANVNFM* || "$i" == *VNFLCM* || "$i" == *EVNFM* ]]
                  then
                      echo netsim | sudo -S -H -u netsim bash -c   "echo -e '.open '$SimName' \n .select $i \n .start \n e {Res1,Res2} = try ecim_netconflib:mo_ref_to_mo_id(null,\"ManagedElement=$i,SystemFunctions=1,SecM=1,Ssh=1\") of SshID -> SupCip = csmo:get_attribute_value(null,SshID,supportedCiphers),LenSupCip = length(SupCip),SelCip = csmo:get_attribute_value(null,SshID,selectedCiphers),LenSelCip = length(SelCip),Res11 = LenSupCip =:= 9,Res12 = LenSelCip =:= 9,{Res11,Res12} catch _Error -> {false,false} end. \n e {Res3,Res4} = try ecim_netconflib:mo_ref_to_mo_id(null,\"ManagedElement=$i,SystemFunctions=1,SecM=1,Tls=1\") of TlsID -> SupCip1 = csmo:get_attribute_value(null,TlsID,supportedCiphers),LenSupCip1 = length(SupCip1),EnCip1 = csmo:get_attribute_value(null,TlsID,enabledCiphers),LenEnCip1 = length(EnCip1),Res21 = LenSupCip1 =:= 49,Res22 = LenEnCip1 =:= 49,{Res21,Res22} catch _Error -> {false,false} end. \n e case lists:member(false,[Res1,Res2,Res3,Res4]) of true -> \"$SimName\" ; false -> \"ok\" end.' | ~/inst/netsim_shell" > ResultComEcim.txt
                  else 
                     echo netsim | sudo -S -H -u netsim bash -c  "echo -e '.open '$SimName' \n .select $i \n .start \n e {Res1,Res2} = try csmo:ldn_to_mo_id(null,string:tokens(\"ManagedElement=1,SystemFunctions=1,Security=1,Ssh=1\",\",\")) of SshID -> SupCip = csmo:get_attribute_value(null,SshID,supportedCipher),LenSupCip = length(SupCip),SelCip = csmo:get_attribute_value(null,SshID,selectedCipher),LenSelCip = length(SelCip),Res11 = LenSupCip =:= 9,Res12 = LenSelCip =:= 9,{Res11,Res12} catch _Error -> {false,false} end. \n e {Res3,Res4} = try csmo:ldn_to_mo_id(null,string:tokens(\"ManagedElement=1,SystemFunctions=1,Security=1,Tls=1\",\",\")) of TlsID -> SupCip1 = csmo:get_attribute_value(null,TlsID,supportedCipher),LenSupCip1 = length(SupCip1),EnCip1 = csmo:get_attribute_value(null,TlsID,enabledCipher),LenEnCip1 = length(EnCip1),Res21 = LenSupCip1 =:= 49,Res22 = LenEnCip1 =:= 49,{Res21,Res22} catch _Error -> {false,false} end. \n e case lists:member(false,[Res1,Res2,Res3,Res4]) of true -> \"$SimName\" ; false -> \"ok\" end.' | ~/inst/netsim_shell "> ResultComEcim.txt 
                  fi
                     Check=`tail -n 1 ResultComEcim.txt |  sed -e 's/^"//' -e 's/"$//'`
                      
                      if [ "$Check" = "ok" ]
                      then
                        echo "PASSED : Cipher is updated successfully on $i"
                        else
                        echo "FAILED : Cipher is not updated on $SimName - $i"
                        exit 1
                      fi
                    
                   done
else
         echo "********************************************************************"
         echo "Ciphers check will run only for NR sims in 5G network & VTIF nodes"
         echo "********************************************************************"
fi
