#!/bin/sh
#####################################################################################
#     Version      : 1.3
#
#     Revision    : CXP 903 6539-1-22
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-30445
#
#     Description  : Added topology support for NRCellDU
#
#     Date         : May 2020
#
#####################################################################################
#####################################################################################
#     Version      : 1.2
#
#     Revision    : CXP 903 6539-8-1
#
#     Author       : Harish Dunga
#
#     JIRA         : NSS-27672
#
#     Description  : Added topology support for External NR cells and LTE EutranCells
#
#     Date         : October 2019
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
TOPOLOGYPATH=$SIMDIR"/topology"
cellDistributionfile=$TOPOLOGYPATH"/cellTopology.csv"
nrCellDuDistributionfile=$TOPOLOGYPATH"/cellDuTopology.csv"
cellRelationFile=$TOPOLOGYPATH"/cellRelationTopology.csv"
nrfreqRelationFile=$TOPOLOGYPATH"/nrfreqRelationTopology.csv"
extcellRelationTopologyFile=$TOPOLOGYPATH"/ExternalcellRelationTopology.csv"
eUtranFreqRelationFile=$TOPOLOGYPATH"/eUtranFreqRelationTopology.csv"
termPointGNBTopologyFile=$TOPOLOGYPATH"/termPointGNBTopology.csv"
topologyFile=$TOPOLOGYPATH"/"$SIMNAME"_Topology.csv"
eUtranRelationTopologyFile=$TOPOLOGYPATH"/eUtranCellRelationTopology.csv"
SIMPATH="/netsim/netsimdir/"$SIMNAME
if [ -e $topologyFile ]
then
   rm $topologyFile
fi

cat >> $topologyFile << TOP
#########################################################
# TOPOLOGY DATA FOR $SIMNAME
#########################################################

#################################################################################################################
#                               NRCell Information
#################################################################################################################
TOP

cat $cellDistributionfile >> $topologyFile

cat >> $topologyFile << TOP
#################################################################################################################
#                               NRCellDU Information
#################################################################################################################
TOP

cat $nrCellDuDistributionfile >> $topologyFile

cat >> $topologyFile << TOP
#################################################################################################################
#                               NRCellRelation Information
#################################################################################################################
TOP

cat $cellRelationFile >> $topologyFile
cat $extcellRelationTopologyFile >> $topologyFile

cat >> $topologyFile << TOP
#################################################################################################################
#                               NRFreqRelation Information
#################################################################################################################
TOP

cat $nrfreqRelationFile >> $topologyFile

cat >> $topologyFile << TOP
#################################################################################################################
#                               TermPointGNodeB Information
#################################################################################################################
TOP

cat $termPointGNBTopologyFile >> $topologyFile

cat >> $topologyFile << TOP
#################################################################################################################
#                               EutranFreqRelation Information
#################################################################################################################
TOP

cat $eUtranFreqRelationFile >> $topologyFile

cat >> $topologyFile << TOP
#################################################################################################################
#                               EutranCellRelation Information
#################################################################################################################
TOP

cat $eUtranRelationTopologyFile >> $topologyFile
revisionDir=$SIMPATH"/SimNetRevision"
if [ -e $revisionDir ]
then 
   rm -rf $revisionDir
fi
mkdir $revisionDir
SIMTOPOLOGYFILE=$revisionDir"/TopologyData.txt"
cp $topologyFile $SIMTOPOLOGYFILE
