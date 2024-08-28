#!/bin/sh

#Version History
###################################################################################################
#Version2       : 20.07
#Created by     : Yamuna Kanchireddygari
#Created on     : 1st Apr 2020
#Revision       : CXP 903 6539-1-18
#Purpose        : checking outputDirectory Attribute on filePullCapabities MO
#Jira Details   : NNS-27983
###################################################################################################
###################################################################################################
#Version1       : 19.14
#Created by     : Yamuna Kanchireddygari
#Created on     : 03rd Sept 2019
#Revision       : CXP 903 6539-1-5
#Purpose        : checking fileLocation Attribute on PmMeasurementCapabilities MO
#Jira Details   : NNS-26434
###################################################################################################

rm NodeData1.txt NodeData.txt

SIM=$1
Path=`pwd`

if [[ $SIM =~ "NR" || $SIM =~ "vPP" || $SIM =~ "vRC" || $SIM =~ "VNFM" || $SIM =~ "RNNODE" || $SIM =~ "vRM" || $SIM =~ "vSD" ]]
then
    fileLocationValue="/c/pm_data/"
elif [[ $SIM =~ "5GRadioNode" || $SIM =~ "VTFRadioNode" || $SIM =~ "VTIF" ]]
then
    fileLocationValue="/rop"
elif [[ $SIM =~ "NRF" || $SIM =~ "UDM-AUSF" || $SIM =~ "UDR" ]]
then
    fileLocationValue="/flash/pm"
elif [[ $SIM =~ "PCC" || $SIM =~ "PCG" ]]
then
    fileLocationValue="/PerformanceManagementReportFiles"
else
    echo "*********************************************" >> Result.txt
    echo "There is no fileLocation/outputdirectory unit test for this simulation $SIM" >> Result.txt
    echo "*********************************************" >> Result.txt
    cat Result.txt
    exit
fi

if [[ $SIM =~ "NR" ]]
then
    outputDirectoryValue="/c/pm_data/"
elif [[ $SIM =~ "VTFRadioNode" ]]
then
    outputDirectoryValue="/pm_data"
else
    outputDirectoryValue=null
    echo "*********************************************" >> Result.txt
    echo "There is no outputDirectory unit test for this simulation $SIM" >> Result.txt
    echo "*********************************************" >> Result.txt
    cat Result.txt
fi

echo "fileLocation = $fileLocationValue" >> Result.txt
echo "outputDirectory = $outputDirectoryValue" >> Result.txt

echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .show simnes' | /netsim/inst/netsim_shell | grep -v \">>\" | grep -v \"OK\" | grep -v \"NE\"" > NodeData.txt

cat NodeData.txt | awk '{print $1}' > NodeData1.txt
IFS=$'\n' read -d '' -r -a node < NodeData1.txt
Length=${#node[@]}
#echo "---------node length=$Length---------"
for i in "${node[@]}"
do
    id=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .select $i \n .start \n e X=csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$i\",\"ComTop:SystemFunctions=1\",\"RcsPm:Pm=1\"]).' | /netsim/inst/netsim_shell | tail -1"`
    
    fileLocationId=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .select $i \n e Value=csmo:get_children_by_type(null,$id,\"RcsPm:PmMeasurementCapabilities\"). \n e [Y]=Value. \n e csmo:get_attribute_value(null,Y,fileLocation).' | /netsim/inst/netsim_shell | tail -1 | tr -d '\"'"`
    
	if [[ $SIM =~ "NR" ]]
        then
	    id1=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .select $i \n .start \n e X=csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$i\",\"ComTop:SystemFunctions=1\",\"RcsPMEventM:PmEventM=1\",\"RcsPMEventM:EventProducer=Lrat\"]).' | /netsim/inst/netsim_shell | tail -1"`
		
		outputDirectoryId=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .select $i \n e Value=csmo:get_children_by_type(null,$id1,\"RcsPMEventM:FilePullCapabilities\"). \n e [Y]=Value. \n e csmo:get_attribute_value(null,Y,outputDirectory).' | /netsim/inst/netsim_shell | tail -1 | tr -d '\"'"`
	elif [[ $SIM =~ "VTFRadioNode" ]]
        then
             id1=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .select $i \n .start \n e X=csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$i\",\"ComTop:SystemFunctions=1\",\"RcsPMEventM:PmEventM=1\",\"RcsPMEventM:EventProducer=VTFrat\"]).' | /netsim/inst/netsim_shell | tail -1"`

             outputDirectoryId=`echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SIM' \n .select $i \n e Value=csmo:get_children_by_type(null,$id1,\"RcsPMEventM:FilePullCapabilities\"). \n e [Y]=Value. \n e csmo:get_attribute_value(null,Y,outputDirectory).' | /netsim/inst/netsim_shell | tail -1 | tr -d '\"'"`
         fi
         
         if [[ $SIM =~ "NR" || $SIM =~ "VTFRadioNode" ]]
         then	
		if [[ $outputDirectoryId == $outputDirectoryValue ]]
                then
		    echo "Info: PASSED on $i outputDirectory is $outputDirectoryId" >> Result.txt
		else
		    echo "Info: FAILED on $i outputDirectory is $outputDirectoryId but it should be $outputDirectoryValue" >> Result.txt
        fi
    fi		

    if [[ $fileLocationId == $fileLocationValue ]]
    then
           echo "Info: PASSED on $i fileLocation is $fileLocationId" >> Result.txt
    else
           echo "Info: FAILED on $i fileLoaction is $fileLocationId but it should be $fileLocationValue" >> Result.txt
    fi
done

cat Result.txt

if  grep -q FAILED "Result.txt"
then
    echo "******INFO: There are some Failures********"
    exit 903
else
    echo "****** PASSED PMfileLocation/ouputDirectory on $SIM **********"
fi
