#!/bin/sh

######FUNCTION DEFINTIONS########

function check_NRcell_config(){
echo -e "\n*** Verifying NR cell MOs configuration***" | tee -a ut_result_$SIM.txt
for DU in ${DU_list[@]}
   	do
		
		cell_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$DU,"nRCellDUId").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		cell_name=`echo -e $cell_name | tr -d '"'`
		cell_id=`echo -e $cell_name | cut -d "-" -f 2`
		echo -e "DU cell MO Id: $DU and MO name: $cell_name"
		sec_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$DU,"nRSectorCarrierRef").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sec_ref=`echo -e $sec_ref | tr -d '"'`
		echo -e "cell name: $cell_name  and cell id : $cell_id , admin state: $admin_state , sec ref: $sec_ref"

		if [[ $sec_ref != *"SectorCarrier=$cell_id"* ]]
		then
	            echo -e "\033[0;31mFAILED\033[m: $NE - The NR cell is not referencing to its corresponding SectorCarrier" | tee -a ut_result_$SIM.txt;return 1	
		fi

	done
 echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}


function check_NRsectorCarrier_config(){
  echo -e "\n*** Verifying NRSectorCarrier MOs configuration***" | tee -a ut_result_$SIM.txt
for SC in ${NRSC_list[@]}
   	do
		sc_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SC,'nRSectorCarrierId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sc_name=`echo -e $sc_name | tr -d '"'`
		sef_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SC,'sectorEquipmentFunctionRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sef_ref=`echo -e $sef_ref | tr -d '"'`  
		if [[ $sef_ref != *"SectorEquipmentFunction=1"* ]];then 
			echo -e "\033[0;31mFAILED\033[m: $NE - The SectorCarrier  doesn't have sectorFunction ref  set to 1"  | tee -a ut_result_$SIM.txt;return 1
		fi
		
	done
	echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}

function check_sectorFunction_config(){
echo -e -e "\n*** Verifying SectorEquipmentFunction MOs configuration and rfBranch ref***" | tee -a ut_result_$SIM.txt
if [ $sefsize -lt  1 ]
  then
	echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have atleast 1 SectorEquipmentFunction mo" | tee -a ut_result_$SIM.txt;return 1 
	
else

for SEF in ${SEF_list[@]}
	do
		
		sef_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SEF,'sectorEquipmentFunctionId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sef_name=`echo -e $sef_name | tr -d '"'`
		if [[ $sef_name -ne 1 ]] 
		then 
		continue 
		fi
		
		
		rfb_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$SEF,'rfBranchRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		if  [[ ${rfb_ref} != *"Transceiver=1"* ]]
			then
			echo -e "\033[0;31m FAILED\033[m: $NE - The LDN has some other RiPort " | tee -a ut_result_$SIM.txt ;return 1
        fi
	done
fi
echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}
function check_RiLink_config(){
echo -e "\n*** Verifying RiLink MOs configuration***" | tee -a ut_result_$SIM.txt
for RILK in ${RiLink_list[@]}
do
riLinkvalue=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RILK,'riLinkId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
        riLinkvalue=`echo -e $riLinkvalue | tr -d '"'`
	if [[ $riLinkvalue == 3 ]] || [[ $riLinkvalue == 4 ]]
	then
        if [[ $riLinkvalue == 3 ]]
	then 
	
	riport_ref1=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$RILK,'riPortRef1').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
	if  [[ ${riport_ref1} != *"RiPort=1"* ]]
                        then
                        echo -e "\033[0;31m FAILED\033[m: $NE - The LDN has some other Riport other than RiPort=1 " | tee -a ut_result_$SIM.txt ;return 1
        fi
	riport_ref2=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$RILK,'riPortRef2').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
	if  [[ ${riport_ref2} != *"RiPort=A"* ]]
                        then
                        echo -e "\033[0;31m FAILED\033[m: $NE - The LDN has some other Riport other than RiPort=A " | tee -a ut_result_$SIM.txt ;return 1
        fi
	else 

        riport_ref1=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$RILK,'riPortRef1').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
        if  [[ ${riport_ref1} != *"RiPort=2"* ]]
                        then
                        echo -e "\033[0;31m FAILED\033[m: $NE - The LDN has some other Riport other than  RiPort=2 " | tee -a ut_result_$SIM.txt ;return 1
        fi
        riport_ref2=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$RILK,'riPortRef2').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
        if  [[ ${riport_ref2} != *"RiPort=B"* ]]
                        then
                        echo -e "\033[0;31m FAILED\033[m: $NE - The LDN has some other Riport other than  RiPort=B " | tee -a ut_result_$SIM.txt ;return 1
        fi
      fi
      fi
done
echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}
function check_fru_config(){
echo -e "\n*** Verifying FRUs MOs configuration***" | tee -a ut_result_$SIM.txt
for FRU in ${FRU_list[@]}
do
	fru_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'fieldReplaceableUnitId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
	fru_name=`echo -e $fru_name | tr -d '"'`
	if [[ $fru_name == 1 ]]  
		then
		pd=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'productData').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		pd_name=`echo -e $pd | awk -F "," '{print $6}' | cut -d "\"" -f 2`
		if [[ $pd_name !=  *"3268"* ]]  
		then
		echo -e "\033[0;34mFAILED\033[m: $NE - Dont have expected motypes on node " | tee -a ut_result_$SIM.txt;return 1
		fi
		tps=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqTransceiver:Transceiver\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		tps1=$(echo -e $tps | sed 's/[][]//g')
		tps_list=(${tps1//,/ })
		tpssize=${#tps_list[@]}
		if [[ $tpssize != 1  ]]
		then
		echo -e "\033[0;34mFAILED\033[m: $NE -  have morethan 1  Tranceiver in FRU:$FRU " | tee -a ut_result_$SIM.txt;return 1
		else
		for TPS in ${tps_list[@]}
		do
		tpname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${TPS}).' | /netsim/inst/netsim_shell"`
		tpname1=$(echo -e $tpname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g'  | awk -F "=" '{print $5}'  )
		if [[ $tpname1 != 1  ]] 
		then
		echo -e "\033[0;34mFAILED\033[m: $NE - Dont have expected transceiver 1   on FRU " | tee -a ut_result_$SIM.txt;return 1
		fi
		done
		fi
		riports=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqRiPort:RiPort\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		riports1=$(echo $riports | cut -d "." -f2 | sed 's/[][]//g')		
		riports_list=(${riports1//,/ })
		for RI in ${riports_list[@]}
		do
		riname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${RI}).' | /netsim/inst/netsim_shell"`
		riname1=$(echo -e $riname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $4}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )

		riPort_Id=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RI,"riPortId").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		riPort_Id=`echo $riPort_Id | tr -d '"'`
		if [[ $riname1 != $riPort_Id  ]]
		then
		echo -e "\033[0;34mFAILED\033[m: $NE - Does not have the expected RiPort " | tee -a ut_result_$SIM.txt;return 1
		fi
		done
		sfpmodules=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqSfpModule:SfpModule\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		sfpmodules1=$(echo -e $sfpmodules | sed 's/[][]//g' | cut -d "." -f2)
		sfpmodules_list=(${sfpmodules1//,/ })
		for SP in ${sfpmodules_list[@]}
		do
		
		sfpname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${SP}).' | /netsim/inst/netsim_shell"`
		sfpname1=$(echo -e $sfpname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $4}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )
		
		if [[ $sfpname1 == A ]] || [[ $sfpname1 == B ]]
		then
		sfpchannels=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$SP,\"ReqSfpChannel:SfpChannel\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		sfpchannels1=`echo $sfpchannels | awk -F "[][]" '{print $2}'`
		sfpchannels_list=(${sfpchannels1//,/ })
                sfpchannelssize=${#sfpchannels_list[@]}
		
		for CH in ${sfpchannels_list[@]}
		do
				
		sfpchname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${CH}).' | /netsim/inst/netsim_shell"`	
			
		sfpchname1=$(echo -e $sfpchname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $5}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )
		if [[ $sfpchname1 != 1 ]] && [[ $sfpchname1 != 2 ]] 
		then

		echo -e "\033[0;34mFAILED\033[m: $NE - Does not have the expected sfpchannel " | tee -a ut_result_$SIM.txt;return 1
		fi
		done
		fi
		done
		
rcvdpowerscanner=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqRcvdPowerScanner:RcvdPowerScanner\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		rcvd1=$(echo -e $rcvdpowerscanner | sed 's/[][]//g')
		rcvdname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${rcvd1}).' | /netsim/inst/netsim_shell"`
		rcvdname1=$(echo -e $rcvdname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $4}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )

		if [[ $rcvdname1 != 1  ]]
		then
			echo -e "\033[0;34mFAILED\033[m: $NE - RcvdPowerScanner mo value is not equal to 1  " | tee -a ut_result_$SIM.txt;return 1
		fi
	fi
done
echo -e '\033[0;34mPASSED FRU\033[m' | tee -a ut_result_$SIM.txt
}


echo -e "Script started at "`date`
SIM=$1
echo "SIM=$SIM"

if [[ $# -ne 1 ]]
then
    echo "ARGUMENTS ARE NOT PASSED"
    echo "Sim should be passed for the UT "
fi

if [[ $SIM != NR23-Q2-V3x2-gNodeBRadio-NRAT-NR15 ]];then
                echo "The script only runs for CBRS Suite Simulation NR23-Q2-V3x2-gNodeBRadio-NRAT-NR15";exit 0
fi
#Nodecount=`echo $SIM | cut -d "-" -f3 | cut -d "x" -f2`
#if [[ $Nodecount != 2  ]] ; then echo "This UT is for 2 nodes NR15 3268CBRS sim" ; exit 0 ; fi
    if [ -e ut_result_$SIM.txt ];then rm -rf ut_result_$SIM.txt ; fi
        echo -e -e "***SIM: \033[0;44m$SIM\033[m***" |  tee -a ut_result_$SIM.txt

nodeNames=`su netsim -c "echo -e '.show simnes\n' | /netsim/inst/netsim_shell -sim $SIM | grep 'LTE MSRBS-V' | cut -d ' ' -f1"`
echo "nodeNames are $nodeNames"
for NE in ${nodeNames[@]}
do	
echo "NE=$NE"
 echo -e -e "******NE: \033[0;45m$NE\033[m*****" | tee -a ut_result_$SIM.txt
		  DUs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"GNBDU:NRCellDU\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		  DUs1=$(echo -e $DUs | sed 's/[][]//g')
		  DUs1=$(echo -e $DUs1 | sed 's/ //g')
		  DU_list=(${DUs1//,/ })
		  NRcellsize=${#DU_list[@]}
		 nrscs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"GNBDU:NRSectorCarrier\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		 nrscs1=$(echo -e $nrscs | sed 's/[][]//g')
		 nrscs1=$(echo -e $nrscs1 | sed 's/ //g')
		 NRSC_list=(${nrscs1//,/ })
		 nrscsize=${#NRSC_list[@]}
		 rilinks=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"ReqRiLink:RiLink\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		   rilinks1=$(echo -e $rilinks | sed 's/[][]//g')
		   rilinks1=$(echo -e $rilinks1 | sed 's/ //g')
		   RiLink_list=(${rilinks1//,/ })
		   rilinksize=${#RiLink_list[@]}
		 frus=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"ReqFieldReplaceableUnit:FieldReplaceableUnit\").' | /netsim/inst/netsim_shell "`
		   frus1=$(echo -e $frus | awk -F "[][]" '{print $2}')
		   frus1=$(echo -e $frus1 | sed 's/ //g')
		   FRU_list=(${frus1//,/ })
		   frusize=${#FRU_list[@]}
		sefs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"RmeSectorEquipmentFunction:SectorEquipmentFunction\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
                   sefs1=$(echo -e $sefs | sed 's/[][]//g')
                   sefs1=$(echo -e $sefs1 | sed 's/ //g')
                   SEF_list=(${sefs1//,/ })
                   sefsize=${#SEF_list[@]}
                   SEF1=${SEF_list[0]}
check_NRcell_config
check_NRsectorCarrier_config
check_sectorFunction_config
check_RiLink_config
check_fru_config

done

echo -e "Script ended at "`date`
