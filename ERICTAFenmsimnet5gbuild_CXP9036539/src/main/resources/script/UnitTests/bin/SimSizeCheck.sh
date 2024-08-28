#!/bin/sh

#Version History
###################################################################################################
#Created by     : Vinay Baratam
#Created on     : 06th Apr 2021
#Revision       : CXP 903 6539-1-31
#Purpose        : Adding Simulation Size UT is in delta or not for EVNFM, VNF-LCM 
#Jira Details   : NNS-35146, NSS-35147
###################################################################################################
###################################################################################################
#Created by     : Yamuna Kanchireddygari
#Created on     : 03rd Sept 2019
#Revision       : CXP 903 6539-1-5
#Purpose        : checking Simulation Size is in delta or not based on node type 
#Jira Details   : NNS-26434
###################################################################################################

SIM=$1
NumOfNodes=`echo $SIM | awk -F "x" '{print $2}' | awk -F "-" '{print $1}'`

if [[ $SIM =~ "MULTIRAT" ]]
then
    nodeSize=10.2
    echo "$SIM"
elif [[ $SIM =~ "NRAT" ]]
then
    nodeSize=9.8
    echo "$SIM"
elif [[ $SIM =~ "CCDM" || $SIM =~ "CCPC" || $SIM =~ "CCRC" || $SIM =~ "CCSC" || $SIM =~ "SC" || $SIM =~ "NSSF" ]]
then
    nodeSize=0.3
    echo "$SIM"
elif [[ $SIM =~ "vPP" ]]
then
    nodeSize=0.44
    echo "$SIM"
elif [[ $SIM =~ "VTIF" || $SIM =~ "vSD" ]]
then
    nodeSize=0.38
    echo "$SIM"
elif [[ $SIM =~ "RAN-VNFM" || $SIM =~ "VNF-LCM" || $SIM =~ "EVNFM" ]]
then
    nodeSize=0.25
    echo "$SIM"
elif [[ $SIM =~ "VTFRadioNode" || $SIM =~ "5GRadioNode" ]]
then
    nodeSize=1.5
    echo "$SIM"
elif [[ $SIM =~ "vRSM" || $SIM =~ "vRM" ]]
then
    nodeSize=0.42
    echo "$SIM"
elif [[ $SIM =~ "HP-NFVO" ]]
then
    nodeSize=1.3
    echo "$SIM"
elif [[ $SIM =~ "UDR" || $SIM =~ "UDM-AUSF" ]]
then
    nodeSize=0.19
    echo "$SIM"
elif [[ $SIM =~ "NRF" ]]
then
    nodeSize=0.29
    echo "$SIM"
elif [[ $SIM =~ "RNFVO" ]]
then
    nodeSize=1.2
    echo "$SIM"
elif [[ $SIM =~ "RNNODE" ]]
then
    nodeSize=1.4
    echo "$SIM"
elif [[ $SIM =~ "OpenMano" ]]
then
    nodeSize=1.18
    echo "$SIM"
elif [[ $SIM =~ "vRC" ]]
then
    nodeSize=0.58
    echo "$SIM"
elif [[ $SIM =~ "PCC" || $SIM =~ "PCG" ]]
then
    nodeSize=0.3
    echo "$SIM"
else
    echo "#####################################################################"
    echo "There is no unit test for checking simulation Size on $SIM"
    echo "#####################################################################"
#    exit 1
fi

SimSize1=`du -shx /netsim/netsimdir/$SIM | awk -F " " '{print $1}'`

if [[ $SimSize1 =~ "M" ]]
then
     ActualSize=`echo "$SimSize1" | sed 's/[^0-9]*//g'`
     ActualSimSize=`printf "%0.1f" $ActualSize`
     echo "$ActualSimSize is in MB"
else
     SimSize2=`echo "$SimSize1" | sed 's/[^0-9]*//g'`
     ActualSimSize=`echo "scale=2; $SimSize2/1024" | bc`
     echo "$SimSize2 is in KB Now it is converted into MB i.e., $ActualSimSize MB"
fi

BufferSimSize=`echo "scale=1; 0.1*$NumOfNodes*$nodeSize" | bc`  # It will give 10% of actual sim size 
SimSize=`echo "scale=1; $ActualSimSize+$BufferSimSize" | bc` 
#echo "$ActualSimSize && $SimSize"
str=$((`echo "$ActualSimSize > $SimSize"| bc`))
if [ $str -eq 0 ]
then
      echo "###############################################################################"
      echo "Info: PASSED Simulation ($SIM) size is in delta i.e., less than $SimSize"
      echo "###############################################################################"
else
      echo "###############################################################################"
      echo "Info: FAILED Simulation ($SIM) size is not in delta i.e., more than $SimSize"
      echo " Please check if any extra data is present on the sim"
      echo "###############################################################################"
fi
if [[ $SIM =~ "NR" || $SIM =~ "vPP" || $SIM =~ "vRC" || $SIM =~ "RNNODE" || $SIM =~ "vRM" || $SIM =~ "vSD" ]]
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

