#!/bin/sh

#####################################################################################
#     Version     : 1.1
#
#     Revision    : CXP 903 6539-1-25
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-31826
#
#     Description : NRM6.2 45K PreSummary Generation Support
#
#     Date        : 8th Sep 2020
#
####################################################################################

if [ "$#" -ne 3 ]
then
 echo
 echo "Usage: $0 <SimBaseName> <sim StartNumber> <Sim endNumber>"
 echo
 echo "Example: $0 NR20-Q3-V3x40-gNodeBRadio-NRAT-NR 95 188"
 echo
 exit 1
fi

SimBase=$1
SimStartNum=$2
SimEndNum=$3
ENV="CONFIG.env"

PWD="/var/simnet/enm-simnet-5G/script/"
. $PWD/dat/$ENV

if [[ $SimStartNum -le 9 ]]
then
    SIMNAME=${SimBase}0${SimStartNum}
else
    SIMNAME=${SimBase}${SimStartNum}
fi

echo "**** $SIMNAME ****"

if [[ $SIMNAME == *"NRAT"* ]]
then
    SIMNUM=$(echo $SIMNAME | awk -F"NR" '{print $4}')
elif [[ $SIMNAME == *"MULTIRAT"* ]]
then
    SIMNUM=$(echo $SIMNAME | awk -F"NR" '{print $3}')
fi

nodeCount=`echo -e $SIMNAME | cut -d 'x' -f2 | cut -d '-' -f1`
COUNT=$(expr $SIMNUM + 0)
NTWKSCRIPTLIST=`ls $SIMDIR/bin/networkScripts | grep "create" | grep -v "csv"`
NTWKMOSCRIPTLIST=`ls $SIMDIR/bin/DG2 | grep "4*.pl" | grep "NR" | grep -v "mml" | grep -v "mo" | grep -v "MultiratNR.pl"`
NTWKSCRIPTS=(${NTWKSCRIPTLIST// / })
NTWKMOSCRIPTS=(${NTWKMOSCRIPTLIST// / })
###################################################################
## routine to kill the process using Ctrl + C
control_c()
{
  echo -en "\n*** Ouch! Exiting ***\n"
  /bin/ps -eaf | grep "create" | grep -v grep | awk '{print $2}' | xargs kill -9
  exit $?
}
###################################################################
## MAIN ##

trap control_c SIGINT
while [ $SimStartNum -le $SimEndNum ]
do
cd $SIMDIR/bin/networkScripts
ntwkNum=${#NTWKSCRIPTS[@]}
ntwkCount=0
while [ $ntwkCount -lt $ntwkNum ]
do
  echo '****************************************************'
  if [ $ntwkCount -eq 0 ]
  then
     echo "./${NTWKSCRIPTS[$ntwkCount]}"
     ./${NTWKSCRIPTS[$ntwkCount]}
  else
     echo "./${NTWKSCRIPTS[$ntwkCount]}"
     ./${NTWKSCRIPTS[$ntwkCount]} $SIMNUM &
  fi
  ntwkCount=$(expr $ntwkCount + 1)
done

wait

cd $SIMDIR/bin/DG2
if [[ $SimStartNum -le 9 ]]
then
    SIM=${SimBase}0${SimStartNum}
    SimNum=0${SimStartNum}
else
    SIM=${SimBase}${SimStartNum}
    SimNum=${SimStartNum}
fi
for script in ${NTWKMOSCRIPTS[@]}
do
   echo '****************************************************' 
   echo "./$script $SIM $ENV $SimStartNum" 
   echo '****************************************************' 
   ./$script $SIM $ENV $SimStartNum
done
echo "NodeName,NRCellRelation,ExternalGNBCUCPFunction,ExternalNRCellCU,TermPointToGNodeB,EUtranCellRelation,EUtranFreqRelation,NRFreqRelation" >> Mod2Summary.csv
find="moType GNBCUCP:"
count=1
totalNRCellRelationCount=0
totalExternalGNBCUCPFunctionCount=0
totalExternalNRCellCUCount=0
totalTermPointToGNodeBCount=0
totalEUtranCellRelationCount=0
totalEUtranFreqRelationCount=0
totalNRFreqRelationCount=0

while [ $count -le $nodeCount ]
do
    if [[ $count -le 9 ]]
    then
        baseName=NR${SimNum}gNodeBRadio0000
    else
        baseName=NR${SimNum}gNodeBRadio000
    fi    
   cat 4601createNRcells.pl.mo$count >> LogOf.mo$count
   cat 4602createNRInternalRelations.pl.mo$count >> LogOf.mo$count
   cat 4603setNRInternalcellRelations.pl.mo$count >> LogOf.mo$count
   cat 4604createExternalNRCells.pl.mo$count >> LogOf.mo$count
   cat 4605createExternalNRCellRelations.pl.mo$count >> LogOf.mo$count
   cat 4607createNRLteRelations.pl.mo$count >> LogOf.mo$count
   cat 4608setNRLteRelations.pl.mo$count >> LogOf.mo$count
   cat 4609createNRLteCellRelations.pl.mo$count >> LogOf.mo$count
   NRCellRelationCount=`cat LogOf.mo$count | grep "${find}NRCellRelation" | wc -l`
   ExternalGNBCUCPFunctionCount=`cat LogOf.mo$count | grep "${find}ExternalGNBCUCPFunction" | wc -l`
   ExternalNRCellCUCount=`cat LogOf.mo$count | grep "${find}ExternalNRCellCU" | wc -l`
   TermPointToGNodeBCount=`cat LogOf.mo$count | grep "${find}TermPointToGNodeB" | wc -l`
   EUtranCellRelationCount=`cat LogOf.mo$count | grep "${find}EUtranCellRelation" | wc -l`
   EUtranFreqRelationCount=`cat LogOf.mo$count | grep "${find}EUtranFreqRelation" | wc -l`
   NRFreqRelationCount=`cat LogOf.mo$count | grep "${find}NRFreqRelation" | wc -l`
   echo "${baseName}${count},${NRCellRelationCount},${ExternalGNBCUCPFunctionCount},${ExternalNRCellCUCount},${TermPointToGNodeBCount},${EUtranCellRelationCount},${EUtranFreqRelationCount},${NRFreqRelationCount}" >> Mod2Summary.csv
   totalNRCellRelationCount=`expr ${totalNRCellRelationCount} + ${NRCellRelationCount}`
   totalExternalGNBCUCPFunctionCount=`expr ${totalExternalGNBCUCPFunctionCount} + ${ExternalGNBCUCPFunctionCount}`
   totalExternalNRCellCUCount=`expr ${totalExternalNRCellCUCount} + ${ExternalNRCellCUCount}`
   totalTermPointToGNodeBCount=`expr ${totalTermPointToGNodeBCount} + ${TermPointToGNodeBCount}`
   totalEUtranCellRelationCount=`expr ${totalEUtranCellRelationCount} + ${EUtranCellRelationCount}`
   totalEUtranFreqRelationCount=`expr ${totalEUtranFreqRelationCount} + ${EUtranFreqRelationCount}`
   totalNRFreqRelationCount=`expr ${totalNRFreqRelationCount} + ${NRFreqRelationCount}`
   count=`expr $count + 1`
done

echo "Total,${totalNRCellRelationCount},${totalExternalGNBCUCPFunctionCount},${totalExternalNRCellCUCount},${totalTermPointToGNodeBCount},${totalEUtranCellRelationCount},${totalEUtranFreqRelationCount},${totalNRFreqRelationCount}" >> Mod2Summary.csv

rm -rf 46*.pl.mo* 46*.pl.mml LogOf.mo*
SimStartNum=`expr $SimStartNum + 1`
SIMNUM=$SimStartNum
done
