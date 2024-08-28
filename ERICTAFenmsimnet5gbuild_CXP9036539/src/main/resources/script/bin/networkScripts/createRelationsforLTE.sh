#!/bin/sh
#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-46
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-38085
#
#     Description : NRM6.3 45K Cells Design Support
#
#     Date        : 11th jan 2022
#
####################################################################################
#####################################################################################
#     Version     : 1.2
#
#     Revision    : CXP 903 6539-1-25
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-32261
#
#     Description : NRM6.2 45K Cells Design Support
#
#     Date        : 8th Sep 2020
#
####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23610
#
#     Description  : Create Entire LTE to 5G handover Data
#
#     Date         : April 2019
#
####################################################################################

. ../../dat/CONFIG.env
########################################
## Remove if old celldata file exists
CELLDATAFILE=$SIMDIR/customdata/cellDistribution.csv
LTEHANDOVERFILE=$SIMDIR/customdata/LTE_to_NR_handover.csv
if [ -e $LTEHANDOVERFILE ]
then
   echo "... removing Old LtehandOver.csv"
   rm $LTEHANDOVERFILE
fi

########################################
totalNumofNodes=$(expr $(expr $SIMEND - $SIMSTART + 1) \* $NUMOFRBS )
cellSegments=(${CELLRATIOS//,/ })
MAJORFREQ=$(echo $NRFREQRELATIONS | awk -F":" '{print $2}')
MINORFREQ=$(echo $NRFREQRELATIONS | awk -F":" '{print $1}')
minorBreak=$(echo $NETWORKBREAKDOWN | awk -F":" '{print $1}')
borderCell=$(expr $( expr $NETWORKCELLSIZE \* $minorBreak ) / 100 )
#borderNode=$(expr $(expr $( expr $NETWORKCELLSIZE \* $minorBreak ) / 100 ) / $CELLNUM )
borderNode=$(expr $(expr $(expr $(expr $(expr $SIMEND - $SIMSTART ) + 1 ) \* $DG2NUMOFRBS ) \* $minorBreak ) / 100 )
cellTypeArray=()
nodeNumArray=()
### Seggregating Cell segments ##########

for segment in ${cellSegments[@]}
do
   cellTypeArray+=($(echo $segment | awk -F":" '{print $1}'))
   nodeNumArray+=($(echo $segment | awk -F":" '{print $2}'))
done


###############################################
minorEnodeBShare=$(echo $EXTERNALENODEB | awk -F":" '{print $1}')
majorEnodeBShare=$(echo $EXTERNALENODEB | awk -F":" '{print $2}')
minorEutrafreqrel=$(echo $EUTRANFREQRELATIONS | awk -F":" '{print $1}')
majorEutrafreqrel=$(echo $EUTRANFREQRELATIONS | awk -F":" '{print $2}')
eutraFreqPerCell=$(expr $minorEutrafreqrel / $minorEnodeBShare)
### Distributing cells ########################
#cellDistribution=()
nodeCount=1
freqCount=1
cellTypePointer=0
cellnum=1

################################################
nrNodeCount=1
lteSimCount=1
lteNodeCount=1
while [ $nrNodeCount -le $totalNumofNodes ]
do
  if [ $nrNodeCount -gt $borderNode ]
  then
     eNodeNum=$majorEnodeBShare
  else
     eNodeNum=$minorEnodeBShare
  fi

  lteNodeStart=$(expr $(expr $nrNodeCount - 1 ) \* $eNodeNum + 1)
  lteNodeEnd=$(expr $nrNodeCount \* $eNodeNum )
  freqCount=1
  while [ $lteNodeStart -le $lteNodeEnd ]
  do
     simCheck=$(expr $lteNodeCount % 160)
     if [ $simCheck -eq 0 ]
     then
        dgltenum=160
     else
        dgltenum=$simCheck
     fi
     if [ $lteSimCount -lt 10 ]
     then
        LTE="LTE0"$lteSimCount
     else
        LTE="LTE"$lteSimCount
     fi
     if [ $dgltenum -lt 10 ]
     then
        LTENAME=$LTE"dg2ERBS0000"$dgltenum
     elif [ $dgltenum -lt 100 ] || [ $dgltenum -ge 10 ]
     then
        LTENAME=$LTE"dg2ERBS000"$dgltenum
     else
        LTENAME=$LTE"dg2ERBS00"$dgltenum
     fi
     if [ $freqCount -gt 4 ]
     then
        freqCount=1
     fi
     #echo "NRNODE=$nrNodeCount;LTENODE=$lteNodeCount;LTESIM=$lteSimCount;dg2ERBS=$dgltenum"
     nrNodeValue=`expr $STARTNODENUM + $nrNodeCount`
     echo "NRNODE=$nrNodeValue;LTENODE=$LTENAME;ENBID=$lteNodeCount;EARFCNDL=$freqCount;" >> $LTEHANDOVERFILE
     #simCheck=$(expr $lteNodeCount % 160)
     if [ $simCheck -eq 0 ]
     then
        lteSimCount=`expr $lteSimCount + 1`
     fi
     lteNodeCount=`expr $lteNodeCount + 1`
     freqCount=`expr $freqCount + 1`
     lteNodeStart=`expr $lteNodeStart + 1`
  done  
  nrNodeCount=`expr $nrNodeCount + 1`
done
