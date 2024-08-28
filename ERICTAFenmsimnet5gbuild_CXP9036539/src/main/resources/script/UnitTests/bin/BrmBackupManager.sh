#!/bin/bash
############# This script checks the count of brmBackupManager mo###########
echo -e "Script started at "`date`
SIM=$1
if [[ $# -ne 1 ]]
then
echo "ERROR has morethan 1 input parameter"
fi
if [ -e ut_result_$SIM.txt ];then rm -rf ut_result_$SIM.txt ; fi
NodesList=`echo netsim | sudo -S -H -u netsim bash -c "echo  -e -e '.open $SIM \n .show simnes' | /netsim/inst/netsim_shell " | grep "LTE MSRBS-V2" | cut -d" " -f1`
for NE in ${NodesList[@]}
    do
	Brm=`echo netsim | sudo -S -H -u netsim bash -c "echo  -e -e '.open $SIM \n .select $NE \n e csmo:get_mo_ids_by_type(null,\"RcsBrM:BrmBackupManager\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
	Brm1=$(echo -e $Brm | sed 's/[][]//g')
                   Brm1=$(echo -e $Brm1 | sed 's/ //g')
                   Brm_list=(${Brm1//,/ })
                   brmsize=${#Brm_list[@]}
		   if [ $brmsize -ne 1 ]
		   then
		   echo -e "\033[0;31mFAILED\033[m: This Node $NE doesnot have  1  BrmBackupManager mo" | tee -a ut_result_$SIM.txt;return 1
		   else
		   echo "PASSED on NODE:$NE"
		   fi
    done
echo -e -e '\033[0;34mPASSED \033[m' | tee -a ut_result_$SIM.txt
echo -e "Script ended at" `date`
