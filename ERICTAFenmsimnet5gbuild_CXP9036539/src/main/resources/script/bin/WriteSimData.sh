#!/bin/sh

#VERSION HISTORY
######################################################################################
##     Version     : 1.2
##     Revision    : CXP 903 6539-1-57
##     Author      : Saikrishna tulluri
##     JIRA        : NSS-41458
##     Description : Copying NrEtcm ,NrFtem , NrPm Events files to SimNetRevision.
##     Date        : 23rd Nov 2022
######################################################################################
##     Version     : 1.1
##     Revision    : CXP 903 6539-1-47
##     Author      : Saivikas Jaini
##     JIRA        : NSS-38914
##     Description : Adding cbrs_config.txt in SimNetRevision
##     Date        : 09th Mar 2022
#####################################################################################
##     Version     : 1.0
##
##     Revision    : CXP 903 6539-1-39
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : No-JIRA
##
##     Description : Adding logs and config details to SimNetRevision
##
##     Date        : 06th Dec 2021
##
######################################################################################

SIMNAME=$1
MSRBS_Template_WithoutZIP=$2

if [[ $# -ne 2 ]]
then
   echo "ERROR: Invalid arguments"
   echo "INFO: ./$0 simname templateName_withoutzip"
fi

PWD=`pwd`
#BINPATH=/netsim/enm-simnet-5G-build-testware/ERICTAFenmsimnet5gbuild_CXP9036539/src/main/resources/script

if [ -d /netsim/netsimdir/$SIMNAME/SimNetRevision ]
then
cp $PWD/../README /netsim/netsimdir/$SIMNAME/SimNetRevision/

cp $PWD/../log/$SIMNAME.log /netsim/netsimdir/$SIMNAME/SimNetRevision/

cp $PWD/DG2/cbrs_config.txt /netsim/netsimdir/$SIMNAME/SimNetRevision/
else
mkdir /netsim/netsimdir/$SIMNAME/SimNetRevision
cp $PWD/../README /netsim/netsimdir/$SIMNAME/SimNetRevision/

cp $PWD/../log/$SIMNAME.log /netsim/netsimdir/$SIMNAME/SimNetRevision/

cp $PWD/DG2/cbrs_config.txt /netsim/netsimdir/$SIMNAME/SimNetRevision/
fi

if [[ $SIMNAME == *"gNodeBRadio"* ]]
then
    cp $PWD/../dat/CONFIG.env /netsim/netsimdir/$SIMNAME/SimNetRevision/
    if [ -d /netsim/netsimdir/$SIMNAME/SimNetRevision/NrEtcm ]
    then
       chmod 777 /netsim/netsimdir/$SIMNAME/SimNetRevision/NrEtcm
       rm -rf /netsim/netsimdir/$SIMNAME/SimNetRevision/NrEtcm/*
       cp /netsim/netsimdir/$MSRBS_Template_WithoutZIP/Events/etcm_* /netsim/netsimdir/$SIMNAME/SimNetRevision/NrEtcm/
    else
       mkdir /netsim/netsimdir/$SIMNAME/SimNetRevision/NrEtcm
       cp /netsim/netsimdir/$MSRBS_Template_WithoutZIP/Events/etcm_* /netsim/netsimdir/$SIMNAME/SimNetRevision/NrEtcm/
    fi

    if [ -d /netsim/netsimdir/$SIMNAME/SimNetRevision/NrFtem ]
    then
      chmod 777 /netsim/netsimdir/$SIMNAME/SimNetRevision/NrFtem
      rm -rf /netsim/netsimdir/$SIMNAME/SimNetRevision/NrFtem/*
      cp /netsim/netsimdir/$MSRBS_Template_WithoutZIP/Events/ftem_* /netsim/netsimdir/$SIMNAME/SimNetRevision/NrFtem/
    else
      mkdir /netsim/netsimdir/$SIMNAME/SimNetRevision/NrFtem
      cp /netsim/netsimdir/$MSRBS_Template_WithoutZIP/Events/ftem_* /netsim/netsimdir/$SIMNAME/SimNetRevision/NrFtem/
    fi

    if [ -d /netsim/netsimdir/$SIMNAME/SimNetRevision/NrPmEvents ]
    then
      chmod 777 /netsim/netsimdir/$SIMNAME/SimNetRevision/NrPmEvents
      rm -rf /netsim/netsimdir/$SIMNAME/SimNetRevision/NrPmEvents/*
      cp /netsim/netsimdir/$MSRBS_Template_WithoutZIP/Events/pm_event_package_* /netsim/netsimdir/$SIMNAME/SimNetRevision/NrPmEvents/
    else
      mkdir /netsim/netsimdir/$SIMNAME/SimNetRevision/NrPmEvents
      cp /netsim/netsimdir/$MSRBS_Template_WithoutZIP/Events/pm_event_package_* /netsim/netsimdir/$SIMNAME/SimNetRevision/NrPmEvents/
    fi
fi

cat >> abcd.mml << ABC
.open $SIMNAME
.select network
.stop -parallel
.saveandcompress force nopmdata
ABC

/netsim/inst/netsim_pipe < abcd.mml

rm abcd.mml
