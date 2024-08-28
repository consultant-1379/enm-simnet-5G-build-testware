#!/bin/sh

#Version History
###################################################################################################
#Created by     : Yamuna Kanchireddygari
#Created on     : 03rd Sept 2019
#Revision       : CXP 903 6539-1-5
#Purpose        : checking Topology Data 
#Jira Details   : NNS-26434
###################################################################################################

SimName=$1
NodeCount=`echo $SimName | awk -F "x" {'print $2'} | awk -F "-" {'print $1'}`

if [[ $SimName =~ "NR" ]]
then
     echo "############## Checking if Topology File exists or not in $SimName ################"

     TopologyFile="/netsim/netsimdir/$SimName/SimNetRevision/TopologyData.txt"

     if [ -f /netsim/netsimdir/$SimName/SimNetRevision/TopologyData.txt ]
     then
           if [ -s /netsim/netsimdir/$SimName/SimNetRevision/TopologyData.txt ]
           then
                echo "INFO : PASSED Topology  File exists and not empty"
                ######################### Checking if Topology file has any ERRORS ###################
                Catch=`cat /netsim/netsimdir/$SimName/SimNetRevision/TopologyData.txt | grep "CREATE"`
                Catch1=`cat /netsim/netsimdir/$SimName/SimNetRevision/TopologyData.txt | grep ";"`
                if [[ -z "$Catch" ]]; then
                     if [[ -z "$Catch1" ]]; then
                           echo "INFO : PASSED TopologyData.txt has no errors"
                     else
                           echo "INFO : FAILED Check the Topoplogy file for $SimName $Catch1"  
                           exit 1
                     fi
                else
                     echo "INFO : FAILED Check the Topoplogy file for $SimName $Catch"
                     exit 1
                fi
           else
                 echo "INFO: FAILED Topology.txt File exists but empty"
                 exit 1
           fi
    else
           echo "INFO: FAILED, TopologyData.txt File does not exist"
           exit 1
    fi

    Num_lines=`cat /netsim/netsimdir/$SimName/SimNetRevision/TopologyData.txt | grep -v -e '^[[:space:]]*$' | grep -v "#" | wc -l`
    if [[ $Num_lines != $TotalCount ]]
    then
          echo "INFO : PASSED Total count is fine"
    else
          echo "INFO : FAILED Total Count is not equal to Number of lines in Topolofy File"
    fi

else
    echo "######################################################"
    echo "Topology check is only for NR simulations in 5G"
    echo "######################################################"
fi

