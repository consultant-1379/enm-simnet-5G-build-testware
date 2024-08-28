#!/bin/sh
#####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-24
#
#     Author       : zyamkan
#
#     JIRA         : NSS-31649
#
#     Description  : Implementing code for MULTIRAT NR sims
#
#     Date         : 27th Jul 2020
#
####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-23738
#
#     Description  : Runs all the DG2 Scripts
#
#     Date         : March 2019
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


SIMNAME=$1
ENV=$2
PWD=`pwd`
. ../../dat/$ENV
if [[ $SIMNAME == *"NRAT"* ]]
then
    SIMNUM=$(echo $SIMNAME | awk -F"NR" '{print $4}')
elif [[ $SIMNAME == *"MULTIRAT"* ]]
then
    SIMNUM=$(echo $SIMNAME | awk -F"NR" '{print $3}')
fi
COUNT=$(expr $SIMNUM + 0)
BASICSCRIPTLIST=`ls $PWD | grep "4*.pl" | grep -v "NR" | grep -v "mml" | grep -v "mo"`
BASICSCRIPTS=(${BASICSCRIPTLIST// / })
for script in ${BASICSCRIPTS[@]}
do

   echo '****************************************************'
   echo "./$script $SIMNAME $ENV $COUNT" 
   echo '****************************************************'
   ./$script $SIMNAME $ENV $COUNT
done
