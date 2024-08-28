#!/bin/sh
####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-58
#
#     Author       : Saivikas Jaini
#
#     JIRA         : NSS-41370
#
#     Description  : Include NRCellDU,NRSectorCarrier mos in Summary file
#
#     Date         : Dec 2022
#
####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-15
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-28742
#
#     Description  : Create HealthCheck summary
#
#     Date         : Jan 2020
#
####################################################################################

if [ "$#" -ne 2  ]
then
 echo
 echo "Usage: $0 <sim name> <env file>"
 echo
 echo "Example: $0 FG19-Q1-V4x40-RadioNode-NRAT-FG530 CONFIG.env"
 echo
 exit 1
fi

SimName=$1
ENV=$2
NETSIMDIR="/netsim/netsimdir/"
NETSIM_PIPE="/netsim/inst/netsim_pipe"

. ../../dat/$ENV
DATE=$(date +"%h_%m_%H_%M")
CURRPATH=$SIMDIR"/bin/DG2/"
COMMAND_FILE="/netsim/"${SimName}"_tmp_${DATE}.cmd"
COMMAND_FILE2="/netsim/"${SimName}"_tmp2_${DATE}.cmd"
summary_file="/netsim/netsimdir/"${SimName}"/SimNetRevision/Summary_"$SimName".csv"


echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$SimName' \n .show simnes' | /netsim/inst/netsim_shell | grep -v \">>\" | grep -v \"OK\" | grep -v \"NE\"" > NodeData.txt
cat NodeData.txt | awk '{print $1}' > NodeData1.txt
###Storing the nodes in an array###
IFS=$'\n' read -d '' -r -a node < NodeData1.txt
Length=${#node[@]}

dumpmotree() {



	echo ".open $1" >> $COMMAND_FILE
	
	for i in "${node[@]}"
    do
#	echo "nnCellFDDode is $i"	
        echo ".select ${i}" >> $COMMAND_FILE
        echo ".start" >> $COMMAND_FILE
        NODENAME="${i}"
	echo "dumpmotree:moid=\"1\",ker_out,outputfile=\"$CURRPATH/$NODENAME.mo\";" >> $COMMAND_FILE
 #       echo "**"
	done

	cat $COMMAND_FILE | $NETSIM_PIPE
}


countMO() {

        COUNT=0
        while IFS='' read -r line || [[ -n "$line" ]]; do

                if [[ "${1}" = *"NR"* ]]
                then
		   if [[ "${2}" = *"NRCellDU"* ]] || [[ "${2}" = *"NRSectorCarrier"*  ]]
		   then
			FIND="moType GNBDU:"
		   else
                        FIND="moType GNBCUCP:"
		   fi	
                    fi
             #   fi


           #      echo "line is $line and other \"${FIND}${2}\" $COUNT "

                if [[ $line = *"${FIND}${2}"* ]]; then
                        COUNT=$[COUNT+1]
                fi

        done < "$1"

        echo $COUNT
}



countNRCellCU() {

        NRCellCU_COUNT=0
        NRCellCU_COUNT=$(countMO ${1} NRCellCU)
        echo $NRCellCU_COUNT
}

countNRCellRelation() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} NRCellRelation)
        echo $EUtranCellFDD_COUNT
}

countExternalGNBCUCPFunction() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} ExternalGNBCUCPFunction)
        echo $EUtranCellFDD_COUNT
}

countExternalNRCellCU() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} ExternalNRCellCU)
        echo $EUtranCellFDD_COUNT
}


countTermPointToGNodeB() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} TermPointToGNodeB)
        echo $EUtranCellFDD_COUNT
}

countEUtranCellRelation() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} EUtranCellRelation)
        echo $EUtranCellFDD_COUNT
}

countEUtranFreqRelation() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} EUtranFreqRelation)
        echo $EUtranCellFDD_COUNT
}

countNRFreqRelation() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} NRFreqRelation)
        echo $EUtranCellFDD_COUNT
}

countNRCellDU() {

	NRCellDU_COUNT=0
	NRCellDU_COUNT=$(countMO ${1} NRCellDU)
	echo $NRCellDU_COUNT
}

countTermPointToENodeB() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} TermPointToENodeB)
        echo $EUtranCellFDD_COUNT
}

countExternalBroadcastPLMNInfo() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} ExternalBroadcastPLMNInfo)
        echo $EUtranCellFDD_COUNT
}

countExternalENodeBFunction() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} ExternalENodeBFunction)
        echo $EUtranCellFDD_COUNT
}

countExternalEUtranCell() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} ExternalEUtranCell)
        echo $EUtranCellFDD_COUNT
}

countEUtranFrequency() {

        EUtranCellFDD_COUNT=0
        EUtranCellFDD_COUNT=$(countMO ${1} EUtranFrequency)
        echo $EUtranCellFDD_COUNT
}

countNRSectorCarrier() {

	NRSectorCarrier_COUNT=0
	NRSectorCarrier_COUNT=$(countMO ${1} NRSectorCarrier)
	echo $NRSectorCarrier_COUNT
}
getNodeName() {

		NODE=`printf "$1" | awk -F "." '{print $1}'`
		echo $NODE
}


cleanUp() {
	echo ""
	rm -f *.mo *.cmd
	echo "##########################"
}

getTotalMO() {

		NODE=`printf "$2" | awk -F "." '{print $1}'`
		echo ".open $1" >> $COMMAND_FILE2
		echo ".select $NODE" >> $COMMAND_FILE2
		echo "dumpmotree:count;" >> $COMMAND_FILE2
		cat $COMMAND_FILE2 | $NETSIM_PIPE > tmp
		TotalMO_COUNT=`cat tmp | tail -n -2`
		rm -f tmp
		echo $TotalMO_COUNT

}

getPmMO() {
        NODE=`printf "$2" | awk -F "." '{print $1}'`
        MType=`echo 'e length(csmo:get_mo_ids_by_type(null, "RcsPm:MeasurementType")).' | $NETSIM_PIPE -sim $1 -ne $NODE | grep -v '>>'`
        MReader=`echo 'e length(csmo:get_mo_ids_by_type(null, "RcsPm:MeasurementReader")).' | $NETSIM_PIPE -sim $1 -ne $NODE | grep -v '>>'`
        MTotal=$[MType+MReader]
        echo $MTotal
}

########
# Main
########


#echo "SIMNUM=$SIMNUM------NUMOFNODES=$NUMOFNODES"
dumpmotree ${1} 

FILES=`ls | grep .mo`
counter=0


if [[ -f $summary_file ]]; then
	rm $summary_file
fi

echo "NodeName,NRCellCU,NRCellRelation,ExternalGNBCUCPFunction,ExternalNRCellCU,TermPointToGNodeB,EUtranCellRelation,EUtranFreqRelation,NRFreqRelation,NRCellDU,TermPointToENodeB,ExternalBroadcastPLMNInfo,ExternalENodeBFunction,ExternalEUtranCell,EUtranFrequency,NRSectorCarrier,TotalNonPmMO,TotalMO" | tee -a "$summary_file" 



for FILE in $FILES
do
NodeName[$counter]=$(getNodeName ${FILE})
NRCellCU[$counter]=$(countNRCellCU ${FILE})
NRCellRelation[$counter]=$(countNRCellRelation ${FILE})
ExternalGNBCUCPFunction[$counter]=$(countExternalGNBCUCPFunction ${FILE})
ExternalNRCellCU[$counter]=$(countExternalNRCellCU ${FILE})
TermPointToGNodeB[$counter]=$(countTermPointToGNodeB ${FILE})
EUtranCellRelation[$counter]=$(countEUtranCellRelation ${FILE})
EUtranFreqRelation[$counter]=$(countEUtranFreqRelation ${FILE})
NRFreqRelation[$counter]=$(countNRFreqRelation ${FILE})
NRCellDU[$counter]=$(countNRCellDU ${FILE})
TermPointToENodeB[$counter]=$(countTermPointToENodeB ${FILE})
ExternalBroadcastPLMNInfo[$counter]=$(countExternalBroadcastPLMNInfo ${FILE})
ExternalENodeBFunction[$counter]=$(countExternalENodeBFunction ${FILE})
ExternalEUtranCell[$counter]=$(countExternalEUtranCell ${FILE})
EUtranFrequency[$counter]=$(countEUtranFrequency ${FILE})
NRSectorCarrier[$counter]=$(countNRSectorCarrier ${FILE})

TotalMO[$counter]=$(getTotalMO $1 ${FILE})
TotalPmMO[$counter]=$(getPmMO $1 ${FILE})
TotalNonPmMO[$counter]=$[TotalMO[$counter]-TotalPmMO[$counter]]
echo "--------------TotalPmMO=${TotalPmMO[$counter]}---------------"
echo "--------------${TotalMO[$counter]}---------------"

echo "${NodeName[$counter]},${NRCellCU[$counter]},${NRCellRelation[$counter]},${ExternalGNBCUCPFunction[$counter]},${ExternalNRCellCU[$counter]},${TermPointToGNodeB[$counter]},${EUtranCellRelation[$counter]},${EUtranFreqRelation[$counter]},${NRFreqRelation[$counter]},${NRCellDU[$counter]},${TermPointToENodeB[$counter]},${ExternalBroadcastPLMNInfo[$counter]},${ExternalENodeBFunction[$counter]},${ExternalEUtranCell[$counter]},${EUtranFrequency[$counter]},${NRSectorCarrier[$counter]},${TotalNonPmMO[$counter]},${TotalMO[$counter]}" | tee -a "$summary_file" 

counter=$[counter+1]

done

NRCellCU=`echo "${NRCellCU[@]/%/+}0" | bc`
NRCellRelation=`echo "${NRCellRelation[@]/%/+}0" | bc`
ExternalGNBCUCPFunction=`echo "${ExternalGNBCUCPFunction[@]/%/+}0" | bc`
ExternalNRCellCU=`echo "${ExternalNRCellCU[@]/%/+}0" | bc`
TermPointToGNodeB=`echo "${TermPointToGNodeB[@]/%/+}0" | bc`
EUtranCellRelation=`echo "${EUtranCellRelation[@]/%/+}0" | bc`
EUtranFreqRelation=`echo "${EUtranFreqRelation[@]/%/+}0" | bc`
NRFreqRelation=`echo "${NRFreqRelation[@]/%/+}0" | bc`
NRCellDU=`echo "${NRCellDU[@]/%/+}0" | bc`
TermPointToENodeB=`echo "${TermPointToENodeB[@]/%/+}0" | bc`
ExternalBroadcastPLMNInfo=`echo "${ExternalBroadcastPLMNInfo[@]/%/+}0" | bc`
ExternalENodeBFunction=`echo "${ExternalENodeBFunction[@]/%/+}0" | bc`
ExternalEUtranCell=`echo "${ExternalEUtranCell[@]/%/+}0" | bc`
EUtranFrequency=`echo "${EUtranFrequency[@]/%/+}0" | bc`
NRSectorCarrier=`echo "${NRSectorCarrier[@]/%/+}0" | bc`
TotalMO=`echo "${TotalMO[@]/%/+}0" | bc`
TotalNonPmMO=`echo "${TotalNonPmMO[@]/%/+}0" | bc`

echo "Total,$NRCellCU,$NRCellRelation,$ExternalGNBCUCPFunction,$ExternalNRCellCU,$TermPointToGNodeB,$EUtranCellRelation,$EUtranFreqRelation,$NRFreqRelation,$NRCellDU,$TermPointToENodeB,$ExternalBroadcastPLMNInfo,$ExternalENodeBFunction,$ExternalEUtranCell,$EUtranFrequency,$NRSectorCarrier,$TotalNonPmMO,$TotalMO" | tee -a "$summary_file" 

cleanUp

