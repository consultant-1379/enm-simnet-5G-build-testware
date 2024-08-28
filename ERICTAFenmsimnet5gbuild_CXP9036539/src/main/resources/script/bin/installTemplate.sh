#!/bin/sh

simName=$1
nodeName=`echo "$simName" | awk -F "FT-" '{print $2}' | awk -F "-LTE" '{print $1}'`
nodeRevision=`echo "$simName" | awk -F "-FT" '{print $1}' | awk -F "LTE" '{print $2}' | awk -F "x" '{print $1}' | awk -F "-V" '{print $1}'`
nodeVersion=`echo "$simName" | awk -F "-FT" '{print $1}' | awk -F "LTE" '{print $2}' | awk -F "x" '{print $1}' | awk -F "-" '{print $3}'`

echo "***************************************simulation Details*********************************"
echo "INFO:simName=$simName"
echo "INFO:nodeName=$nodeName"
echo "INFO:nodeVersion=$nodeVersion"
echo "INFO:nodeRevision=$nodeRevision"
echo "***************************************simulation Details*********************************"
template=`cat /netsim/simdepContents/nodeTemplate.content | grep "$nodeName" | grep "$nodeRevision" | grep "$nodeVersion" | sed -e 's/^"//' -e 's/"$//'`
wget -P /netsim/netsimdir/ $template
templateNode=`ls /netsim/netsimdir | grep "$nodeName" | grep ".zip"`
chmod 777 /netsim/netsimdir/$templateNode
su netsim -c "echo '.uncompressandopen $templateNode force' | /netsim/inst/netsim_shell"
rm -rf /netsim/netsimdir/$templateNode