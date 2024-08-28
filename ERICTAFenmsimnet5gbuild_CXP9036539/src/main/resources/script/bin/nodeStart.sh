#!/bin/sh

#VERSION History
######################################################################################
##     Version     : 1.1
##
##     Revision    : CXP 903 6539-1-40
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : No-JIRA
##
##     Description : Setting managedElementId for NR nodes
##
##     Date        : 14th Dec 2021
##
######################################################################################
##     Version     : 1.0
##
##     Revision    : CXP 903 6539-1-39
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : No-JIRA
##
##     Description : Script for starting the node
##
##     Date        : 06th Dec 2021
##
######################################################################################
SIM=$1
Path=`pwd`
NodesList=`echo -e ".open $SIM \n .show simnes" | /netsim/inst/netsim_shell | grep -vE ">>|OK|NE" | cut -d' ' -f1`

lsof -nl >/tmp/lsof.log;rm -rf ~/freeIPs.log; for ip in `ip add list|grep -v "127.0.0\|::1\|0.0.0.0\|00:00:"|cut -d" " -f6|cut -d"/" -f1|grep -v qdisc|awk 'NF'`;do grep $ip /tmp/lsof.log > /dev/null; if [ $? != 0 ]; then echo $ip >> ~/freeIPs.log; fi; done; rm -rf /tmp/lsof.log;echo "Total IPs:`ip add list|grep -v "127.0.0\|::1\|0.0.0.0\|00:00:"|cut -d" " -f6|cut -d"/" -f1|grep -v qdisc|awk 'NF'|wc -l`"; echo "Free IPs:`wc -l ~/freeIPs.log`";

cat >> abcd.mml << ABC
.open $SIM
ABC

for NODE in ${NodesList[@]}
do
     ipAddr=`cat "/netsim/freeIPs.log" | grep -vi ":" | head -n+1`
     sed -i "/${ipAddr}/d" /netsim/freeIPs.log
cat >> abcd.mml << ABC
.select $NODE
.set taggedaddr subaddr $ipAddr 1
.set save
.start
ABC
done

/netsim/inst/netsim_pipe < $Path/abcd.mml

rm -rf $Path/abcd.mml
echo -e ".open $SIM" >> $Path/setId.mml
for NODE in ${NodesList[@]}
do
    echo -e ".select $NODE \n .start" >> $Path/setId.mml
    LDN=`echo -e ".open $SIM \n .select $NODE \n e: csmo:mo_id_to_ldn(null, 1)." | /netsim/inst/netsim_shell | sed -n '/csmo:mo_id_to_ldn/{n;p}' | sed 's/[][]//g' | sed 's/ComTop://g'`

    echo -e "setmoattribute:mo=$LDN, attributes=\"managedElementId(String)=$NODE\"; " >> $Path/setId.mml
    echo -e ".restart" >> $Path/setId.mml
done

/netsim/inst/netsim_pipe < $Path/setId.mml
rm -rf $Path/setId.mml
