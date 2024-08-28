#!/bin/sh
#####################################################################################
#     Version 	  : 1.3
#
#     Revision	  : CXP 903 6539-1-67
#
#     JIRA	  : NSS-46327
#
#     Description : Updating the eNBPlmnId attribute for supported versions.
#
#     Date 	  : 27th Nov 2022
#
#####################################################################################
#####################################################################################
#     Version 	  : 1.2
#
#     Revision	  : CXP 903 6539-1-51
#
#     JIRA	  : NSS-39377
#
#     Description : Adding the attribute values for mcc and mnc mo's 
#
#     Date 	  : 28th April 2022
#
#####################################################################################
#####################################################################################
#     Version      : 1.1
#
#     Revision    : CXP 903 6539-1-13
#
#     JIRA         : NSS-27849
#
#     Description  : This script is only used to create relations in NR01MT sim with LTE26
#
#     Date         : 13th Nov 2019
#
####################################################################################

SIM=$1
NODELIST=`echo -e '.open '$SIM'\n.show simnes' | ~/inst/netsim_shell | grep "LTE MSRBS-V2" | cut -d" " -f1 | head -n 10`
NODES=(${NODELIST// / })
count=0
lteCount=0
MOTYPE="GNBCUCP"
PWD=`pwd`
NodeVersion=`echo -e $SIM | cut -d 'x' -f1 | sed 's/[A-Z]//g' | sed 's/[a-z]//g' | sed 's/-//g'`
LTENODELIST=`cat ltenodes.txt`
LTENODES=(${LTENODELIST// / })
MMLSCRIPT=$SIM"_updateLTE.mml"
if [ -e $MMLSCRIPT ]
then
   rm $MMLSCRIPT
fi
cat >> $MMLSCRIPT << MML
.open $SIM
MML
while [ $count -lt ${#NODES[@]} ]
do
  nodeCount=`expr $count + 1`
  #echo "${NODES[$count]}:$MOTYPE;${LTENODES[$lteCount]}"
  LTENODENAME=`echo ${LTENODES[$lteCount]} | awk -F";" '{print $1}'`
  NODE=${NODES[$count]}
  MOSCRIPT=$NODE"_lteEnb.mo"
  if [ -e $MOSCRIPT ]
  then
     rm $MOSCRIPT
  fi
  PLMN=`echo ${LTENODES[$lteCount]} | awk -F"=" '{print $2}'`
  enbId=`echo ${LTENODES[$lteCount]} | awk -F";" '{print $2}'`
  check=`expr $nodeCount % 2`
  if [ $check -eq 0 ]
  then
     lteCount=`expr $lteCount + 1`
  fi
  if [[ $MOTYPE == "GNodeB" ]]
  then
     MOTYPE="GNBCUCP"
     cat >> $MOSCRIPT << MOSC
CREATE
(
    parent "ComTop:ManagedElement=$NODE,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:EUtraNetwork
    exception none
    nrOfAttributes 2
    "eUtraNetworkId" String "1"
)
MOSC
  if [[ $NodeVersion -lt 2342 ]]
  then
     cat >> $MOSCRIPT << MOSC
CREATE
(
    parent "ComTop:ManagedElement=$NODE,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "$LTENODENAME"
    moType GNBCUCP:ExternalENodeBFunction
    exception none
    nrOfAttributes 4
    "eNBPlmnId" String "$PLMN"
    "eNodeBId" Int32 $enbId
    "externalENodeBFunctionId" String "$LTENODENAME"
    "pLMNId" Struct
       nrOfElements 2
         "mcc" String "353"
         "mnc" String "57"
)
MOSC
  else
  cat >> $MOSCRIPT << MOSC
CREATE
(
    parent "ComTop:ManagedElement=$NODE,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "$LTENODENAME"
    moType GNBCUCP:ExternalENodeBFunction
    exception none
    nrOfAttributes 4
    "eNodeBId" Int32 $enbId
    "externalENodeBFunctionId" String "$LTENODENAME"
    "pLMNId" Struct
       nrOfElements 2
         "mcc" String "353"
         "mnc" String "57"
)
MOSC
  fi
  elif [[ $MOTYPE == "GNBCUCP" ]]
  then
     MOTYPE="GNodeB"
     cat >> $MOSCRIPT << MOSC
CREATE
(
    parent "ComTop:ManagedElement=$NODE,GNBCUCP:GNBCUCPFunction=1"
    identity "1"
    moType GNBCUCP:EUtraNetwork
    exception none
    nrOfAttributes 2
    "eUtraNetworkId" String "1"
)
MOSC
  if [[ $NodeVersion -lt 2342 ]]
  then
     cat >> $MOSCRIPT << MOSC
CREATE
(
    parent "ComTop:ManagedElement=$NODE,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "$LTENODENAME"
    moType GNBCUCP:ExternalENodeBFunction
    exception none
    nrOfAttributes 4
    "eNBPlmnId" String "$PLMN"
    "eNodeBId" Int32 $enbId
    "externalENodeBFunctionId" String "$LTENODENAME"
    "pLMNId" Struct
       nrOfElements 2
         "mcc" String "353"
         "mnc" String "57"
)
MOSC
  else
  cat >> $MOSCRIPT << MOSC
CREATE
(
    parent "ComTop:ManagedElement=$NODE,GNBCUCP:GNBCUCPFunction=1,GNBCUCP:EUtraNetwork=1"
    identity "$LTENODENAME"
    moType GNBCUCP:ExternalENodeBFunction
    exception none
    nrOfAttributes 4
    "eNodeBId" Int32 $enbId
    "externalENodeBFunctionId" String "$LTENODENAME"
    "pLMNId" Struct
       nrOfElements 2
         "mcc" String "353"
         "mnc" String "57"
)
MOSC
  fi
  fi
  
  cat >> $MMLSCRIPT << MML
.select $NODE
.start
kertayle:file="$PWD/$MOSCRIPT";
MML
  count=`expr $count + 1`
done

/netsim/inst/netsim_shell < $PWD/${SIM}_updateLTE.mml
rm -rf *.mo *.mml

