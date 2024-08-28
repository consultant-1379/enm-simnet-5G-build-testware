#!/bin/sh
#####################################################################################
#     Version      : 1.7
#
#     Revision     : CXP 903 6539-1-42
#
#     Author       : zhainic
#
#     JIRA         : NSS-38085
#
#     Description  : Support for Multi Cell Type
#
#     Date         : Dec 2021
#
####################################################################################
#####################################################################################
#     Version      : 1.6
#
#     Revision     : CXP 903 6539-1-29
#
#     Author       : zyamkan
#
#     JIRA         : NSS-33963
#
#     Description  : Correcting code for MULTIRAT NR sims
#
#     Date         : 12th Jan 2021
#
####################################################################################
#####################################################################################
#     Version     : 1.5
#
#     Revision    : CXP 903 6539-1-25
#
#     Author      : Yamuna Kanchireddygari
#
#     JIRA        : NSS-32261
#
#     Description : Deleting System Created HCRule Mos align it to  22 MOs
#
#     Date        : 8th Sep 2020
#
####################################################################################
#####################################################################################
#     Version      : 1.4
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
#     Version      : 1.3
#
#     Revision     : CXP 903 6539-1-19
#
#     Author       : zsujmad
#
#     JIRA         : NSS-28747
#
#     Description  : Adding support to run through nssSingleSimulationBuild Job. Modified $PWD
#
#     Date         : 22nd Apr 2020
#
####################################################################################
#####################################################################################
#     Version      : 1.2
#
#     Revision     : CXP 903 6539-1-13
#
#     Author       : zyamkan
#
#     JIRA         : NSS-27849
#
#     Description  : Adding script to relate between LTE26 and NR01
#
#     Date         : 13th Nov 2019
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
PWD="/var/simnet/enm-simnet-5G/script/"
. $PWD/dat/$ENV
if [[ $SIMNAME == *"NRAT"* ]]
then
    SIMNUM=$(echo $SIMNAME | awk -F"NR" '{print $4}')
elif [[ $SIMNAME == *"MULTIRAT"* ]]
then
    SIMNUM=$(echo $SIMNAME | awk -F"NR" '{print $3}')
fi

Instpath=/netsim/inst
LOGSPATH=`pwd`
neType=`echo -e $SIMNAME | cut -d 'x' -f1 | awk -F "NR" '{print $2}'`
echo -e ".open $SIMNAME \n .show simnes" | $Instpath/netsim_shell -q | awk '/OK/{f=0;};f{print $1;};/NE Name/{f=1;}' > $Instpath/nodelist.txt

for nename in `cat $Instpath/nodelist.txt`
do
     echo -e ".open $SIMNAME \n .selectnocallback $nename \n.start \n e case simneenv:get_netype() of {\"LTE\", \"MSRBS-V2\", \"$neType\",_} -> SId = cs_session_factory:create_internal_session(\"MoDelete\", infinity), HcRuleMOs = csmo:get_mo_ids_by_type(null,\"RcsHcm:HcRule\"), lists:map(fun(HcRuleMOId) -> case HcRuleMOId of HcRuleMOId when is_integer(HcRuleMOId) -> csmodb:delete_mo_by_id(SId, HcRuleMOId);_Any-> OK end end, HcRuleMOs), cs_session:commit_chk(SId),cs_session_factory:end_session(SId);_AnyValue -> OK end." | $Instpath/netsim_shell
done

rm -rf $Instpath/nodelist.txt

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

cd $SIMDIR/bin/networkScripts
   echo "****************************************************"
   echo "Running createCellInformation.sh script to get celltype of node"
   echo "./createCellInformation.sh"
   ./createCellInformation.sh

cd $SIMDIR/bin/DG2
   echo '****************************************************' 
   echo "./runBasicScripts.sh $SIMNAME $ENV" 
   echo '****************************************************' 
   ./runBasicScripts.sh $SIMNAME $ENV &

cd $SIMDIR/bin/networkScripts
ntwkNum=${#NTWKSCRIPTS[@]}
ntwkCount=0
while [ $ntwkCount -lt $ntwkNum ]
do
  echo '****************************************************'
  if [ $ntwkCount -eq 0 ]
  then
    echo "*****created cell distribution already skiping createCellInformation.sh script**************"
    # echo "./${NTWKSCRIPTS[$ntwkCount]}"
    # ./${NTWKSCRIPTS[$ntwkCount]}
  else
     echo "./${NTWKSCRIPTS[$ntwkCount]}"
     ./${NTWKSCRIPTS[$ntwkCount]} $SIMNUM &
  fi
  ntwkCount=$(expr $ntwkCount + 1)
done

wait
cd $SIMDIR/bin/DG2
for script in ${NTWKMOSCRIPTS[@]}
do
   echo '****************************************************' 
   echo "./$script $SIMNAME $ENV $COUNT" 
   echo '****************************************************' 
   ./$script $SIMNAME $ENV $COUNT
done

if [ "$RelateWithLTE26" == "YES" ]
then
    echo '*****************************************************'
    echo "./RelateWithLTE26.sh $SIMNAME $ENV"
    echo '*****************************************************'
    ./RelateWithLTE26.sh $SIMNAME $ENV
fi
if [ "$MULTIRATNR" == "YES" ]
then
    echo '*****************************************************'
    echo "./MultiratNR.sh $SIMNAME $SIMNUM"
    echo '*****************************************************'
    ./MultiratNR.sh $SIMNAME $SIMNUM
fi

echo " ./createTopology.sh $SIMNAME $ENV"
./createTopology.sh $SIMNAME $ENV
echo "*****************************************************"
echo "running generateSummary.sh ...."
./generateSummary.sh $SIMNAME $ENV
echo "ended generateSummary.sh script execution"
echo "*****************************************************"
