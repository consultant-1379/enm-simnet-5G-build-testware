#!/bin/bash

######FUNCTION DEFINTIONS########
function check_cell_config(){
echo -e  "\n*** Verifying DU cell MOs configuration***" | tee -a ut_result_$SIM.txt


   if [[ $cellsize -ne  2 ]]
   then
	echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have $cellsize cells " | tee  -a ut_result_$SIM.txt;return 1
   else
   	for DU in ${DU_list[@]}
   	do
		
		cell_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$DU,"nRCellDUId").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		cell_name=`echo -e $cell_name | tr -d '"'`
		cell_id=`echo -e $cell_name | cut -d "-" -f 2`
		echo -e "DU cell MO Id: $DU and MO name: $cell_name"
		admin_state=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$DU,"administrativeState").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		admin_state=`echo -e $admin_state | tr -d '"'`
		sec_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$DU,"nRSectorCarrierRef").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sec_ref=`echo -e $sec_ref | tr -d '"'`
		echo -e "cell name: $cell_name  and cell id : $cell_id , admin state: $admin_state , sec ref: $sec_ref"

		if [[ $sec_ref != *"SectorCarrier=$cell_id"* ]]
		then
			echo -e "\033[0;31mFAILED\033[m: $NE - The NR cell is not referencing to its corresponding SectorCarrier" | tee -a ut_result_$SIM.txt;return 1	
		fi
	
		if [ $admin_state -ne 0 ];then echo -e "\033[0;31mFAILED\033[m: $NE - adminsistrtaiveState value is not LOCKED"  | tee -a ut_result_$SIM.txt;return 1; fi
		   
		
		
	done
	
   fi
  echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}
 
function check_sectorCarrier_config(){
  echo -e "\n*** Verifying SectorCarrier MOs configuration***" | tee -a ut_result_$SIM.txt
  if [[ $scsize -ne 2 ]]
  then
	echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have 2 SectorCarrier mos" | tee -a ut_result_$SIM.txt;return 1 
	
   else
   	for SC in ${SC_list[@]}
   	do
		sc_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SC,'nRSectorCarrierId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sc_name=`echo -e $sc_name | tr -d '"'`
		sef_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SC,'sectorEquipmentFunctionRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sef_ref=`echo -e $sef_ref | tr -d '"'`  
		cbrs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SC,'cbrsEnabled').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		echo -e "SectorCarrier MO Id: $SC and MO name: $sc_name and sef-ref : $sef_ref  and cbrsEnabled:$cbrs"
		if [ $cbrs != true ];then 
			echo -e "\033[0;31mFAILED\033[m: $NE - DU cells don't have cbrsEnabled as true"  | tee -a ut_result_$SIM.txt;return 1
		fi 
        	 if [[ $sef_ref != *"SectorEquipmentFunction=1" ]];then 
			echo -e "\033[0;31mFAILED\033[m: $NE - The SectorCarrier  doesn't have sectorFunction ref  set to 1"  | tee -a ut_result_$SIM.txt;return 1
		 fi
		
	done
  fi
	echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}
function check_sectorFunction_config(){
echo -e "\n*** Verifying SectorEquipmentFunction MOs configuration***" | tee -a ut_result_$SIM.txt
  if [ $sefsize -lt  1 ]
  then
	echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have atleast 1 SectorEquipmentFunction mo" | tee -a ut_result_$SIM.txt;return 1 
	
   else
   	for SEF in ${SEF_list[@]}
   	do
		
		sef_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SEF,'sectorEquipmentFunctionId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sef_name=`echo -e $sef_name | tr -d '"'`
		if [[ $sef_name -eq 1 ]];then
		rfb_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SEF,'rfBranchRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		rfb_ref=`echo -e $rfb_ref | cut -d"[" -f 2 | cut -d"]" -f 1`  
		echo -e "SectorEquipmentFunction MO Id: $SEF and MO name: $sef_name , rfb_ref: $rfb_ref"
		
			if [[ $rfb_ref != *"AntennaUnitGroup=$sef_name,RfBranch=1"* && $rfb_ref != *"AntennaUnitGroup=$sef_name,RfBranch=2"* && $rfb_ref != *"AntennaUnitGroup=$sef_name,RfBranch=3"* && $rfb_ref != *"AntennaUnitGroup=$sef_name,RfBranch=4"* ]];then
					echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfBranchRef values " | tee -a ut_result_$SIM.txt;return 1
			fi
		fi
	done
  fi
	echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}

function check_antennaUnitGroup_config(){
echo -e "\n*** Verifying AntennaUnitGroup MOs configuration***" | tee -a ut_result_$SIM.txt
  if [ $agsize -lt  1 ]
  then
	echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have atleast 1 AntennaUnitGroup mo" | tee -a ut_result_$SIM.txt;return 1
   else
   	for AG in ${AG_list[@]}
   	do
		
		ag_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$AG,'antennaUnitGroupId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		ag_name=`echo -e $ag_name | tr -d '"'`
		echo -e "AntennaUnit MO Id: $AG and MO name: $ag_name"
		if [[ $ag_name -eq 1 ]];then		
			rfbs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$AG,\"ReqAntennaSystem:RfBranch\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
			rfbs1=$(echo -e $rfbs | sed 's/[][]//g')
			rfbs1=$(echo -e $rfbs1 | sed 's/ //g')
			RFB_list=(${rfbs1//,/ })
			rfbsize=${#RFB_list[@]}
		
			echo -e "ag name: $ag_name and rfb: ${RFB_list[@]} , rfb size: $rfbsize"
			if [ $rfbsize -lt 4 ];then
				echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have  4 RfBranch mos under AntennaUnitGroup" | tee -a ut_result_$SIM.txt;return 1
			else 
				for RFB in ${RFB_list[@]}
				do
					echo -e "rfb: $RFB"
				 	rfb_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RFB,'rfBranchId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
					rfb_name=`echo -e $rfb_name | tr -d '"'`
					rfp_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RFB,'rfPortRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
					rfp_ref=`echo -e $rfp_ref | tr -d '"'`
					echo -e "ag_name: $ag_name , rfb_name: $rfb_name , rfp_ref: $rfp_ref "
					
					if [[ $rfb_name -eq 1 ]];then
						if [[ $rfp_ref != *"FieldReplaceableUnit=1,RfPort=A" ]];then
							echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,RfBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
						fi
					elif [[ $rfb_name -eq 2 ]];then
						if [[ $rfp_ref != *"FieldReplaceableUnit=1,RfPort=B" ]];then
							echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,RfBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
						fi
					elif [[ $rfb_name -eq 3 ]];then
						if [[ $rfp_ref != *"FieldReplaceableUnit=1,RfPort=C" ]];then
							echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,RfBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
						fi
					elif [[ $rfb_name -eq 4 ]];then
						if [[ $rfp_ref != *"FieldReplaceableUnit=1,RfPort=D" ]];then
							echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,RfBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
						fi
					fi
				
				done
			fi
		fi
	done
  fi
	echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}

function check_fru_config(){
echo -e "\n*** Verifying FRU MOs configuration***" | tee -a ut_result_$SIM.txt
  if [ $frusize -lt  1 ]
  then
	echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have atleast 2 FRU mos" | tee -a ut_result_$SIM.txt;return 1  
	#echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have 12 Sectorcarrier mos" > Result.txt
   else
	k=0
   	for FRU in ${FRU_list[@]}
   	do
		
		fru_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'fieldReplaceableUnitId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
	#	echo -e "fruname : $fru_name"
		fru_name=`echo -e $fru_name | tr -d '"'`
		echo -e "fruname : $fru_name"
		echo -e "FRU MO Id: $FRU and MO name: $fru_name"
		if [[ $fru_name -ne 1 ]] ; then continue ; fi
		pd=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'productData').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		pd_name=`echo -e $pd | awk -F "," '{print $6}' | cut -d "\"" -f 2`
		pdsn=`echo -e $pd | awk -F "," '{print $12}' | cut -d "\"" -f 2`
		if [[ $fru_name -eq 1 ]];then			
				rfps=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqRfPort:RfPort\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
				rfps1=$(echo -e $rfps | sed 's/[][]//g')
				rfps1=$(echo -e $rfps1 | sed 's/ //g')
			  	RFP_list=(${rfps1//,/ })
				rfpsize=${#RFP_list[@]}
				echo -e "rfpsize: $rfpsize , pd: $pd_name and sn:$sn1"
				if [ $rfpsize -lt 4 ];then echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have atleast 4 RfPort MOs under FRU=$fru_name" | tee -a ut_result_$SIM.txt;return 1 ; fi
				if [[ $pd_name != "Radio 4408 B48" ]];then
			  		echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have correct CBRS productData for FRU=$fru_name " | tee  -a ut_result_$SIM.txt;return 1
				fi
		 fi
	done
	
 fi
	echo -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
}
  
echo -e "Script started at "`date`
	#SIM="NR22-Q1-V4x5-gNodeBRadio-MULTIRAT-NR04"
	SIM=$1
	if [[ $SIM != "NR22-Q1-V4x5-gNodeBRadio-MULTIRAT-NR04" ]];then
		echo "The script only runs for CBRS Suite Simulation NR21-Q4-V1x5-gNodeBRadio-NRAT-NR03";exit 0
	fi
	if [ -e ut_result_$SIM.txt ];then rm -rf ut_result_$SIM.txt ; fi
	echo -e "***SIM: \033[0;44m$SIM\033[m***" |  tee -a ut_result_$SIM.txt
	#NodesList=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .show simnes" | /netsim/inst/netsim_shell | grep "LTE MSRBS-V2" | cut -d" " -f1"`
	NodesList=("NR04gNodeBRadio00005")
	for NE in ${NodesList[@]}
	do
		   echo -e  "******NE: \033[0;45m$NE\033[m*****" | tee -a ut_result_$SIM.txt
		   DUs=`echo netsim | sudo -S -H -u netsim bash -c "echo  -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"GNBDU:NRCellDU\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		
		   DUs1=$(echo -e $DUs | sed 's/[][]//g')
		   DUs1=$(echo -e $DUs1 | sed 's/ //g')
		   DU_list=(${DUs1//,/ })
		   cellsize=${#DU_list[@]}
		    scs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"GNBDU:NRSectorCarrier\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		   scs1=$(echo -e $scs | sed 's/[][]//g')
		   scs1=$(echo -e $scs1 | sed 's/ //g')
		   SC_list=(${scs1//,/ })
		   scsize=${#SC_list[@]}

		   sefs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"RmeSectorEquipmentFunction:SectorEquipmentFunction\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		   sefs1=$(echo -e $sefs | sed 's/[][]//g')
		   sefs1=$(echo -e $sefs1 | sed 's/ //g')
		   SEF_list=(${sefs1//,/ })
		   sefsize=${#SEF_list[@]}
		  
		   
		   ags=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"ReqAntennaSystem:AntennaUnitGroup\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		   ags1=$(echo -e $ags | sed 's/[][]//g')
		   ags1=$(echo -e $ags1 | sed 's/ //g')
		   AG_list=(${ags1//,/ })
		   agsize=${#AG_list[@]}

		frus=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"ReqFieldReplaceableUnit:FieldReplaceableUnit\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		   frus1=$(echo -e $frus | sed 's/[][]//g')
		   frus1=$(echo -e $frus1 | sed 's/ //g')
		   FRU_list=(${frus1//,/ })
		   frusize=${#FRU_list[@]}


check_cell_config
check_sectorCarrier_config
check_sectorFunction_config
check_antennaUnitGroup_config
check_fru_config
done

echo -e "Script ended at "`date`



