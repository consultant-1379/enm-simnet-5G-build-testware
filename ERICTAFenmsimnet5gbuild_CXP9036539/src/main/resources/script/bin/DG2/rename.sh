#!/bin/sh
SIM=$1
echo -e '.open '$SIM'\n.select network\n.stop' | ~/inst/netsim_shell
NODELIST=`echo -e '.open '$SIM'\n.show simnes' | ~/inst/netsim_shell | grep "LTE MSRBS-V2" | cut -d" " -f1`
NODES=(${NODELIST// / })
if [ -e rename.mml ]
then
   rm rename.mml
fi
cat >> rename.mml << MML
.open $SIM
MML
for NODENAME in ${NODES[@]}
do

SIMNUM=$(echo $NODENAME | awk -F"dg2ERBS" '{print $1}' | awk -F"LTE" '{print $2}')
INDEX=$(echo $NODENAME | awk -F"dg2ERBS" '{print $2}')
BASE="NR"$SIMNUM"gNodeBRadio"
nodeName=$BASE$INDEX
cat >> rename.mml << MML
.select $NODENAME
.rename -auto $BASE $INDEX
.set save
.start
setmoattribute:mo="1",attributes="managedElementId(string)=$nodeName";
.save
MML
done
~/inst/netsim_shell < rename.mml
rm rename.mml
#cat rename.mml
#rm rename.mml
