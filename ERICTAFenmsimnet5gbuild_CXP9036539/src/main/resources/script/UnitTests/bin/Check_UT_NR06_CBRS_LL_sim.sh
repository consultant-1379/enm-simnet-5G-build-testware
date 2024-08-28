#!/bin/sh

######FUNCTION DEFINTIONS########
function check_LTEcell_config(){
echo "hi"
echo -e -e  "\n*** Verifying TDD cell MOs configuration***" | tee -a ut_result_$SIM.txt

for TDD in ${TDD_list[@]}
do
echo "TDD=$TDD"
        cell_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$TDD,"eUtranCellTDDId").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
        cell_name=`echo -e $cell_name | tr -d '"'`
        cell_id=`echo -e $cell_name | cut -d "-" -f 2`
        echo -e "TDD cell MO Id: $TDD and MO name: $cell_name"
       sec_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$TDD,"sectorCarrierRef").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
       echo "sec_ref=$sec_ref"
               echo -e "cell name: $cell_name  and cell id : $cell_id ,  sec ref: $sec_ref"
       if [[ $sec_ref != *"SectorCarrier=$cell_id"* ]]
           then
                echo -e "\033[0;31mFAILED\033[m: $NE - The LTE cell is not referencing to its corresponding SectorCarrier" | tee -a ut_result_$SIM.txt;return 1
        fi
done

  echo -e -e '\033[0;34mPASSED TDDcells mos configuration is good in the mixed mode NR06simulation \033[m' | tee -a ut_result_$SIM.txt
}

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

function check_sectorCarrier_config(){
  echo -e -e "\n*** Verifying SectorCarrier MOs configuration and sectorFunctionRef***" | tee -a ut_result_$SIM.txt
count=1
for SC in ${SC_list[@]}
    do
        sc_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$SC,'sectorCarrierId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
        sc_name=`echo -e $sc_name | tr -d '"'`
        sef_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$SC,'sectorFunctionRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
        sef_ref=`echo -e $sef_ref | tr -d '"'`
         echo -e "SectorCarrier MO Id: $SC , MO name: $sc_name  , SectorEqipmentFunctionRef: $sef_ref "

		if [[ $sef_ref != *"SectorEquipmentFunction=1"* ]]
		then
			echo -e "\033[0;31mFAILED\033[m: $NE - The LTE cell is not referencing to its corresponding SectorCarrier" | tee -a ut_result_$SIM.txt;return 1

		else
			echo -e "\033[0;34mPASSED\033[m: $NE - The LTE cell is referencing to its corresponding SectorCarrier" | tee -a ut_result_$SIM.txt;
			count=`expr $count + 1`
			if [[ $count -gt $cellsize ]]
				then
				break
			fi
		fi

	done
echo -e -e '\033[0;34mPASSED\033[m' | tee -a ut_result_$SIM.txt
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
		echo $SEF
		sef_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$SEF,'sectorEquipmentFunctionId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		sef_name=`echo -e $sef_name | tr -d '"'`
		if [[ $sef_name -ne 1 ]] 
		then 
		continue 
		fi
		echo "SEF=$SEF"
		echo "sef_name=$sef_name"
		rfb_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e  'e csmo:get_attribute_value(null,$SEF,'rfBranchRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
		echo "rfb_ref=$rfb_ref"
		if  [[ ${rfb_ref} != *"AntennaUnitGroup=$sef_name,MulticastAntennaBranch=1"* ]] && [[ ${rfb_ref} != *"AntennaUnitGroup=$sef_name,MulticastAntennaBranch=2"* ]] && [[ ${rfb_ref} != *"AntennaUnitGroup=$sef_name,MulticastAntennaBranch=3"* ]] && [[ ${rfb_ref} != *"AntennaUnitGroup=$sef_name,MulticastAntennaBranch=4"* ]]
			then
			echo -e "\033[0;31m FAILED\033[m: $NE - The LDN has some other RiPort " | tee -a ut_result_$SIM.txt ;return 1
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
			rfbs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$AG,\"ReqAntennaSystem:MulticastAntennaBranch\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
			rfbs1=$(echo -e $rfbs | sed 's/[][]//g')
			rfbs1=$(echo -e $rfbs1 | sed 's/ //g')
			RFB_list=(${rfbs1//,/ })
			rfbsize=${#RFB_list[@]}
			echo -e "ag name: $ag_name and rfb: ${RFB_list[@]} , rfb size: $rfbsize"
			if [ $rfbsize -lt 4 ];then
			echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have  4 MulticastBranch mos under AntennaUnitGroup" | tee -a ut_result_$SIM.txt;return 1
			else 
				for RFB in ${RFB_list[@]}
					do
						echo "RFB=$RFB"
						rfb_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RFB,'multicastAntennaBranchId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
						rfb_name=`echo -e $rfb_name | tr -d '"'`
						rfp_ref=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RFB,'transceiverRef').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
						rfp_ref=`echo -e $rfp_ref | tr -d '"'`
						if [[ $rfb_name -eq 1 ]];then
							if [[ $rfp_ref != *"Transceiver=1"* ]];then
								echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,MulticastBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
							fi
						elif [[ $rfb_name -eq 2 ]];then
							if [[ $rfp_ref != *"Transceiver=2"* ]];then
								echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,MulticastBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
							fi
						elif [[ $rfb_name -eq 3 ]];then
							if [[ $rfp_ref != *"Transceiver=1"* ]];then
								echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,MulticastBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
							fi
						elif [[ $rfb_name -eq 4 ]];then
							if [[ $rfp_ref != *"Transceiver=2"* ]];then
								echo -e "\033[0;31mFAILED\033[m:Node $NE doesn't have expected rfPortRef value on MO AntennaUnitGroup=$ag_name,MulticastBranch=$rfb_name " | tee -a ut_result_$SIM.txt;return 1
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
echo -e "\n*** Verifying FRUs MOs configuration***" | tee -a ut_result_$SIM.txt
count=0
if [[ $frusize -lt 9 ]]
	then	
		echo "This node has FRUs lessthan 9"
	continue
fi
for FRU in ${FRU_list[@]}
do
	fru_name=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'fieldReplaceableUnitId').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
	fru_name=`echo -e $fru_name | tr -d '"'`
	if [[ $fru_name == 1 ]] || [[ $fru_name == 2 ]] || [[ $fru_name == 3 ]] || [[ $fru_name == 4 ]] || [[ $fru_name == 5 ]] || [[ $fru_name == 6 ]] || [[ $fru_name == 7 ]] || [[ $fru_name == 8 ]] || [[ $fru_name == "IRU-1" ]] 
		then
			if [[ $fru_name == 1 ]] || [[ $fru_name == 2 ]] || [[ $fru_name == 3 ]] || [[ $fru_name == 4 ]] || [[ $fru_name == 5 ]] || [[ $fru_name == 6 ]] || [[ $fru_name == 7 ]] || [[ $fru_name == 8 ]]
				then
					pd=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'productData').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
					pd_name=`echo -e $pd | awk -F "," '{print $6}' | cut -d "\"" -f 2`
					if [[ $pd_name !=  *"4459"* ]] && [[ $pd_name !=  *"4469"* ]] && [[ $pd_name !=  *"44Kr"* ]] && [[ $pd_name !=  *"41Kr"* ]] 
					then
						echo -e "\033[0;34mFAILED\033[m: $NE - Dont have expected motypes on node " | tee -a ut_result_$SIM.txt;return 1
					fi
					tps=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqTransceiver:Transceiver\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
					tps1=$(echo -e $tps | sed 's/[][]//g')
					tps_list=(${tps1//,/ })
					tpssize=${#tps_list[@]}
					if [[ $tpssize != 2  ]]
					then
						echo -e "\033[0;34mFAILED\033[m: $NE - Dont have 2 Tranceivers in FRU:$FRU " | tee -a ut_result_$SIM.txt;return 1
					else
						for TPS in ${tps_list[@]}
						do
							tpname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${TPS}).' | /netsim/inst/netsim_shell"`
							tpname1=$(echo -e $tpname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g'  | awk -F "=" '{print $5}'  )
							if [[ $tpname1 != 1  ]] && [[ $tpname1 != 2  ]]
							then
								echo -e "\033[0;34mFAILED\033[m: $NE - Dont have expected transceiver 1 or 2  on FRU " | tee -a ut_result_$SIM.txt;return 1
							fi
						done
					fi
					rdiports=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqRdiPort:RdiPort\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
					rdiports1=$(echo -e $rdiports | sed 's/[][]//g')
					rdiports_list=(${rdiports1//,/ })
					for RDI in ${rdiports_list[@]}
					do
						rdiname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${RDI}).' | /netsim/inst/netsim_shell"`
						rdiname1=$(echo -e $rdiname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $4}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )

						rdiPort_Id=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RDI,"rdiPortId").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
						rdiPort_Id=`echo $rdiPort_Id | tr -d '"'`
						if [[ $rdiname1 != $rdiPort_Id  ]]
							then
							echo -e "\033[0;34mFAILED\033[m: $NE - Does not have the expected RdiPort " | tee -a ut_result_$SIM.txt;return 1
						fi
					done
					remoteRdiPort_Id=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RDI,"remoteRdiPortRef").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
					remoteRdiPort_Id1=`echo $remoteRdiPort_Id | awk -F "," '{print $4}' | awk -F "=" '{print $2}' | tr -d '"'`
						if [[ $fru_name != $remoteRdiPort_Id1  ]]
							then
							echo -e "\033[0;34mFAILED\033[m: $NE - Have other rdiPortref  than expected RdiPort " | tee -a ut_result_$SIM.txt;return 1
						fi

	else	
	pd=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$FRU,'productData').' | /netsim/inst/netsim_shell -sim $SIM -ne $NE "`
	pd_name=`echo -e $pd | awk -F "," '{print $6}' | cut -d "\"" -f2`

		if [[ $pd_name !=  *"1648"* ]] && [[ $pd_name !=  *"1649"* ]] && [[ $pd_name !=  *"8848"* ]] && [[ $pd_name !=  *"16Fr"* ]] && [[ $pd_name !=  *"88RB"* ]]
		then
			echo -e "\033[0;34mFAILED\033[m: $NE - Dont have expected motypes on node:$FRU " | tee -a ut_result_$SIM.txt;return 1
		fi


		rdiports=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqRdiPort:RdiPort\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		rdiports1=$(echo -e $rdiports | sed 's/[][]//g')
		rdiports_list=(${rdiports1//,/ })
		IRUrdiportscount=${#rdiports_list[@]}
		if [[ $IRUrdiportscount != 8  ]]
		then
		echo -e "\033[0;34mFAILED\033[m: $NE - Dont have 8RdiPort mos on node:$FRU " | tee -a ut_result_$SIM.txt;return 1
		else
			for RDI in ${rdiports_list[@]}
			do
				rdiname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${RDI}).' | /netsim/inst/netsim_shell"`
				rdiname1=$(echo -e $rdiname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $4}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )
				rdiPort_Id=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_attribute_value(null,$RDI,"rdiPortId").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
				rdiPort_Id=`echo $rdiPort_Id | tr -d '"'`
				if [[ $rdiname1 != $rdiPort_Id  ]]
				then
					echo -e "\033[0;34mFAILED\033[m: $NE - Does not have the expected RdiPort " | tee -a ut_result_$SIM.txt;return 1
				fi
			done
		fi
		rcvdpowerscanner=`echo netsim | sudo -S -H -u netsim bash -c "echo -e 'e csmo:get_children_by_type(null,$FRU,\"ReqRcvdPowerScanner:RcvdPowerScanner\").' | /netsim/inst/netsim_shell -sim $SIM -ne $NE | tail -1"`
		rcvd1=$(echo -e $rcvdpowerscanner | sed 's/[][]//g')
		rcvdname=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e  csmo:mo_id_to_ldn(null,${rcvd1}).' | /netsim/inst/netsim_shell"`
		rcvdname1=$(echo -e $rcvdname| awk -F "[][]" '{print $2}' | sed 's/ //g' | sed 's/"//g' | awk -F "," '{print $4}' | awk -F ":" '{print $2}' | awk -F "=" '{print $2}' )

		if [[ $rcvdname1 != 1  ]]
		then
			echo -e "\033[0;34mFAILED\033[m: $NE - RcvdPowerScanner mo value is not equal to 1  " | tee -a ut_result_$SIM.txt;return 1
		fi
			fi
	fi
done
echo -e '\033[0;34mPASSED FRU\033[m' | tee -a ut_result_$SIM.txt
}



SIM=$1
echo "SIM=$SIM"
if [[ $# -ne 1 ]]
then
    echo "ARGUMENTS ARE NOT PASSED"
    echo "Sim should be passed for the UT "
fi

if [[ $SIM != "NR"*"-gNodeBRadio-MULTIRAT-NR06" ]];then
                echo "The script only runs for CBRS Suite Simulation NR*-gNodeBRadio-MULTIRAT-NR06";exit 0
fi
    if [ -e ut_result_$SIM.txt ];then rm -rf ut_result_$SIM.txt ; fi
        echo -e -e "***SIM: \033[0;44m$SIM\033[m***" |  tee -a ut_result_$SIM.txt

#echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .show simnes' | /netsim/inst/netsim_shell | grep -v \">>\" | grep -v \"OK\" | grep -v \"NE\"" > NodeData.txt

#cat NodeData.txt | awk '{print $1}' > NodeData1.txt
#IFS=$'\n' read -d '' -r -a NodeList < NodeData1.txt
#Length=${#NodeList[@]}

#echo "Length=$Length"
#echo "Nodelist=${NodeList[@]}"
#echo "node1: ${NodeList[1]}"
nodeNames=`su netsim -c "echo -e '.show simnes\n' | /netsim/inst/netsim_shell -sim $SIM | grep 'LTE MSRBS-V' | cut -d ' ' -f1"`
echo "nodeNames are $nodeNames"
for NE in ${nodeNames[@]}
do	
#NE="NR06gNodeBRadio00001"
echo "NE=$NE"
 echo -e -e "******NE: \033[0;45m$NE\033[m*****" | tee -a ut_result_$SIM.txt
                 #  echo -e -e ".select $NE" >> /netsim/setattr.mml
#                  tdds=`echo netsim | sudo -S -H -u netsim bash -c "echo -e'.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"Lrat:EUtranCellTDD\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
tdds=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"Lrat:EUtranCellTDD\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
                   tdds1=$(echo -e $tdds | sed 's/[][]//g')
                   tdds1=$(echo -e $tdds1 | sed 's/ //g')
                   TDD_list=(${tdds1//,/ })
                   cellsize=${#TDD_list[@]}
echo "cellsize=$cellsize"
                   scs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"Lrat:SectorCarrier\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
                   scs1=$(echo -e $scs | sed 's/[][]//g')
                   scs1=$(echo -e $scs1 | sed 's/ //g')
                   SC_list=(${scs1//,/ })
                   scsize=${#SC_list[@]}
echo "scsize=$scsize"		   
		  DUs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"GNBDU:NRCellDU\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		  DUs1=$(echo -e $DUs | sed 's/[][]//g')
		  DUs1=$(echo -e $DUs1 | sed 's/ //g')
		  DU_list=(${DUs1//,/ })
		  NRcellsize=${#DU_list[@]}
echo "NRCellsize=$NRcellsize"
		 nrscs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"GNBDU:NRSectorCarrier\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		 nrscs1=$(echo -e $nrscs | sed 's/[][]//g')
		 nrscs1=$(echo -e $nrscs1 | sed 's/ //g')
		 NRSC_list=(${nrscs1//,/ })
		 nrscsize=${#NRSC_list[@]}
echo "nrscsize=$nrscsize"
		 ags=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"ReqAntennaSystem:AntennaUnitGroup\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
		   ags1=$(echo -e $ags | sed 's/[][]//g')
		   ags1=$(echo -e $ags1 | sed 's/ //g')
		   AG_list=(${ags1//,/ })
		   agsize=${#AG_list[@]}
echo "agsize=$agsize"
		 frus=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"ReqFieldReplaceableUnit:FieldReplaceableUnit\").' | /netsim/inst/netsim_shell "`
		   frus1=$(echo -e $frus | awk -F "[][]" '{print $2}')
		   frus1=$(echo -e $frus1 | sed 's/ //g')
		   FRU_list=(${frus1//,/ })
		   frusize=${#FRU_list[@]}
echo "frusize=$frusize"
		sefs=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"RmeSectorEquipmentFunction:SectorEquipmentFunction\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
                   sefs1=$(echo -e $sefs | sed 's/[][]//g')
                   sefs1=$(echo -e $sefs1 | sed 's/ //g')
                   SEF_list=(${sefs1//,/ })
                   sefsize=${#SEF_list[@]}
                   SEF1=${SEF_list[0]}
echo "sefsize=$sefsize"
check_LTEcell_config
check_NRcell_config
check_sectorCarrier_config
check_NRsectorCarrier_config
check_sectorFunction_config
check_antennaUnitGroup_config
check_fru_config

done

echo -e "Script ended at "`date`
