#!/bin/sh

##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 23.07.2019
# Purpose     : Checks enbID on LTE26 and NR01 nodes ( NSS-25816 )
###########################################################################################################################
rm NodeData_LTE.txt NodeData1_LTE.txt ResultLTE.txt Data.csv NodeData_NR.txt NodeData_NR_all.txt NodeData_NR1.txt

NRSim=$1
LTESim=$2

if [[ $NRSim =~ "NR01"  ]]
then
echo "Starting the Check on $NRSim"
continue
else
echo "Skipping the test. This Test is only for NR01 simulations"
exit 
fi



if [[ -z ${LTESim} ]]
then
  LTESim=`ls /netsim/netsimdir/ | grep -i LTE26`
  #${LatestVersion}
fi
echo "LTESim=${LTESim}"

#############   Working on the LTE part   #########################
echo netsim | sudo -S -H -u netsim bash -c 'printf ".open '$LTESim' \n .show simnes" | /netsim/inst/netsim_shell | grep -v ">>" | grep -v "OK" | grep -v "NE"' > NodeData_LTE.txt
cut -f1 -d ' ' NodeData_LTE.txt > NodeData1_LTE.txt
IFS=$'\n' read -d '' -r -a node < NodeData1_LTE.txt


for LteNode in `cat NodeData1_LTE.txt`
do
        echo netsim | sudo -S -H -u netsim bash -c "printf \".open $LTESim \n .select $LteNode \n e X=csmo:ldn_to_mo_id(null,[\\\"ComTop:ManagedElement=$LteNode\\\"]). \n e Value = csmo:get_children_by_type(null,X,\\\"Lrat:ENodeBFunction\\\"). \n e [Y]=Value. \n e csmo:get_attribute_value(null,Y,eNBId).\" | /netsim/inst/netsim_shell" > ResultLTE.txt
        echo $LteNode: `cat ResultLTE.txt | tail -1` >> Data.csv
done

echo "########### WOrking on NR sim #########################"
echo netsim | sudo -S -H -u netsim bash -c 'printf ".open '$NRSim' \n .show simnes" | /netsim/inst/netsim_shell | grep -v ">>" | grep -v "OK" | grep -v "NE"' > NodeData_NR.txt
cut -f1 -d ' ' NodeData_NR.txt > NodeData_NR_all.txt 
cat NodeData_NR_all.txt| head -10 > NodeData_NR1.txt
IFS=$'\n' read -d '' -r -a node < NodeData_NR1.txt


for NRNode in `cat NodeData_NR1.txt`
do

     digit=`echo $NRNode | awk -F "Radio" {'print $2'}`
     n=`expr $digit + 0`
     rem=$(( $n % 2 )); 
     if [ $rem -eq 0 ]
     then
     
         id=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$NRSim' \n .select $NRNode \n e X=csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NRNode\",\"GNBCUCP:GNBCUCPFunction=1\",\"GNBCUCP:EUtraNetwork=1\"]).' | /netsim/inst/netsim_shell | tail -1"`
         
         
         externalENodeBFunctionId=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$NRSim' \n .select $NRNode \n e Value=csmo:get_children_by_type(null,$id,\"GNBCUCP:ExternalENodeBFunction\"). \n e [Y]=Value. \n e csmo:get_attribute_value(null,Y,externalENodeBFunctionId).' | /netsim/inst/netsim_shell | tail -1 | tr -d '\"'"`
         
         eNodeBId=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$NRSim' \n .select $NRNode \n e Value=csmo:get_children_by_type(null,$id,\"GNBCUCP:ExternalENodeBFunction\"). \n e [Y]=Value. \n e csmo:get_attribute_value(null,Y,eNodeBId).' | /netsim/inst/netsim_shell | tail -1"`
         
         
         eNodeBId_fromCSV=`cat Data.csv | grep "$externalENodeBFunctionId" | awk -F ":" {'print $2'}`
         
         if [ $eNodeBId -eq $eNodeBId_fromCSV ]
         then 
                echo "INFO: PASSED on $NRNode, ENodeBId on NR node is $eNodeBId and on LTE node $externalENodeBFunctionId is $eNodeBId_fromCSV."
         else
                echo "INFO: FAILED on $NRNode, ENodeBId on NR node is $eNodeBId and on LTE node $externalENodeBFunctionId is $eNodeBId_fromCSV."
                exit 1
         fi
         
         
 else     
 
         echo netsim | sudo -S -H -u netsim bash -c "echo -e  '.open $NRSim \n .select $NRNode \n e X=csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NRNode\",\"NratGNodeBFunction:GNodeBFunction=1\",\"NratGNodeBFunction:EUtraNetwork=1\"]). \n e Values = csmo:get_children_by_type(null,X,\"NratGNodeBFunction:ExternalENodeBFunction\"). \n e [ {csmo:mo_id_to_ldn(null,X1),X1} || X1 <- Values ]. ' | /netsim/inst/netsim_shell" > Data.txt 
               
         Data_Length=`cat Data.txt |grep -n "mo_id_to_ldn" | cut -f1 -d:`
         LineNo=`expr "$Data_Length" + 1`
         LastLineNo=`wc -l < Data.txt`
               
         awk "NR >=$LineNo && NR <=$LastLineNo" Data.txt > Data1.txt
         id=`grep -A1 'NratGNodeBFunction:ExternalENodeBFunction=LTE26' Data1.txt|grep -v "NratGNodeBFunction:ExternalENodeBFunction=LTE26" |sed 's/},//'| tr -d " "`
               
               
         ExteNodeBfunID=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $NRSim \n .select $NRNode \n e csmo:get_attribute_value(null,$id,externalENodeBFunctionId).' | /netsim/inst/netsim_shell | tail -1 | tr -d '\"'"`
         #echo "******************* ExteNodeBfunID=$ExteNodeBfunID ******************"
         eNodeBId=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open $NRSim \n .select $NRNode \n e csmo:get_attribute_value(null,$id,eNodeBId).' | /netsim/inst/netsim_shell | tail -1 "`
         #echo "*********************  eNodeBId=**$eNodeBId*** and ExtENodeBId_fromCSV is ***$ExtENodeBId_fromCSV**   **************************"
         ExtENodeBId_fromCSV=`cat Data.csv | grep "$ExteNodeBfunID" | awk -F ":" {'print $2'} | tr -d " "`
         #echo "--------------->**$ExtENodeBId_fromCSV**"
         if [ $eNodeBId -eq $ExtENodeBId_fromCSV ]
         then 
                echo "INFO: PASSED on $NRNode, eNodeBId on NR node is $eNodeBId and on LTE node $ExteNodeBfunID is $ExtENodeBId_fromCSV."
         else
                echo "INFO: FAILED on $NRNode, eNodeBId on NR node is $eNodeBId and on LTE node $ExteNodeBfunID is $ExtENodeBId_fromCSV."
                exit 1
         fi


 fi


done