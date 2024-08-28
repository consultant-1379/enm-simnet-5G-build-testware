#!/bin/sh
#####################################################################################
#     Version     : 1.4
#
#     Revision    : CXP 903 6539-1-42
#
#     Author      : Nainesha Chilakala
#
#     JIRA        : NSS-38085
#
#     Description : Support for Multi Cell Type
#
#     Date        : Dec 2021
#
#####################################################################################
#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-36
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-34405
#
#     Description : design changes for CELLID values in csv files
#
#     Date        : 06th Oct 2021
#
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
#     Description  : Create Entire 5G Network Cell Distribution Data
#
#     Date         : April 2019
#
####################################################################################
SIMDIR=$1

. ../../dat/CONFIG.env
########################################
## Remove if old celldata file exists
CELLDATAFILE=$SIMDIR/customdata/cellDistribution.csv
if [ -e $CELLDATAFILE ]
then
   echo "... removing Old CellDistribution.csv"
   rm $CELLDATAFILE
fi
########################################
totalNumofNodes=$(expr $(expr $SIMEND - $SIMSTART + 1) \* $NUMOFRBS )
cellSegments=(${CELLRATIOS//,/ })
MAJORFREQ=$(echo $NRFREQRELATIONS | awk -F":" '{print $2}')
MINORFREQ=$(echo $NRFREQRELATIONS | awk -F":" '{print $1}')
minorBreak=$(echo $NETWORKBREAKDOWN | awk -F":" '{print $1}')
borderCell=$(expr $( expr $NETWORKCELLSIZE \* $minorBreak ) / 100 )
cellTypeArray=()
nodeNumArray=()
### Seggregating Cell segments ##########

for segment in ${cellSegments[@]}
do
   cellTypeArray+=($(echo $segment | awk -F":" '{print $1}'))
   nodeNumArray+=($(echo $segment | awk -F":" '{print $2}'))
done

### Distributing cells ########################
#cellDistribution=()
nodeCount=1
freqCount=1
cellTypePointer=0
cellnum=1
while [ $nodeCount -le $totalNumofNodes ]
do
   if [ $cellTypePointer -ge ${#cellTypeArray[@]} ]
   then
      cellTypePointer=0
   fi
   cellType=${cellTypeArray[$cellTypePointer]}
   nodeNum=${nodeNumArray[$cellTypePointer]}
   if [ $nodeNum -ne 0 ]
   then
      cellCount=1
      while [ $cellCount -le $cellType ]
      do
         if [ $cellnum -gt $borderCell ]
         then
            NUMOFFREQUENCIES=$MAJORFREQ
         else
            NUMOFFREQUENCIES=$MINORFREQ
         fi
         if [ $freqCount -gt $NUMOFFREQUENCIES ]
         then
            freqCount=1
         fi
         NODE_NUM=`expr $nodeCount + $STARTNODENUM`
#         CELL_NUM=`expr $cellnum + $STARTCELLNUM`
         CELL_NUM=`expr $cellnum + 0`
         #echo "NODE=$nodeCount;CELLTYPE=$cellType;CELL=$cellCount;NRFREQUENCY=$freqCount;CID=$cellnum;" >> $CELLDATAFILE
         echo "NODE=$NODE_NUM;CELLTYPE=$cellType;CELL=$cellCount;NRFREQUENCY=$freqCount;CID=$CELL_NUM;" >> $CELLDATAFILE
         freqCount=`expr $freqCount + 1`
         cellCount=`expr $cellCount + 1`
         cellnum=`expr $cellnum + 1`
      done 
       nodeNum=$(expr $nodeNum - 1)
      nodeNumArray[$cellTypePointer]=$nodeNum
      nodeCount=`expr $nodeCount + 1`   
   fi
   if [[ $nodeNum -eq 0 ]]
   then
   cellTypePointer=`expr $cellTypePointer + 1`
   fi
done
