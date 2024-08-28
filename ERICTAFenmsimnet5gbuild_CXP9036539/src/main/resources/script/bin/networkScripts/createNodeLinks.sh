#!/bin/sh

#####################################################################################
#     Version     : 1.3
#
#     Revision    : CXP 903 6539-1-42
#
#     Author      : Nainesha Chilakala
#
#     JIRA        : NSS-38085
#
#     Description : NRM6.2 Multi cell Type
#
#     Date        : Dec 2021
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
#     Version     : 1.1
#
#     Revision    : <CXP 903 6539-1-25>
#
#     Author      : Harish Dunga
#
#     JIRA        : <NSS-32261>
#
#     Description : <NRM6.1 15K Cells Design Support>
#
#     Date        : <8th Sept 2020>
#
####################################################################################
declare -A extOneCellNodeArray
. ../../dat/CONFIG.env

CELL_DIST_FILE=$SIMDIR/customdata/cellDistribution.csv
NODELINKSFILE=$SIMDIR/customdata/nodeLinks.csv
SIMNUM=$1
NODES=$(expr $(expr $SIMEND - $SIMSTART + 1 ) \* $NUMOFRBS)
NODENUM=$EXTERNALGNB

if [ -e $NODELINKSFILE ]
then
   echo "Removing  old nodeLinks file .."
   rm $NODELINKSFILE
fi

if [ ! -f  $CELL_DIST_FILE ]
then
   echo "cellDistribution File doesnot exists ... !!"
   exit 1
fi

##############################################################################
MAJOREXTGNB=`echo $EXTERNALGNB | awk -F":" '{print $2}'`
MINOREXTGNB=`echo $EXTERNALGNB | awk -F":" '{print $1}'`

### NETWORKBREAKDOWN= ####

MAJORSHARE=`echo $NETWORKBREAKDOWN | awk -F":" '{print $2}'`
MINORSHARE=`echo $NETWORKBREAKDOWN | awk -F":" '{print $1}'`

#BORDERCELL=$(expr $(expr $NETWORKCELLSIZE \* $MINORSHARE) / 100)
#DIV_CHECK=$(expr $(expr $NETWORKCELLSIZE \* $MINORSHARE) % 100)

#if [ $DIV_CHECK -ne 0 ]
#then
#   BORDERCELL=$(expr $BORDERCELL + 1)
#fi
#BORDERCELL=`expr $STARTCELLNUM + $BORDERCELL`
#BORDERLINE=`cat $CELL_DIST_FILE | grep "CID=$BORDERCELL;"`
#BORDERNODE=`echo $BORDERLINE | awk -F"NODE=" '{print $2}' | awk -F";" '{print $1}'`

BORDERNODE=$(expr $(expr $(expr  $( expr $(expr $SIMEND - $SIMSTART + 1 ) \* $NUMOFRBS ) \* $MINORSHARE ) / 100) + $STARTNODENUM )

################################################################################

checkCellTypeOfNode() {
node=$1
check=`cat $CELL_DIST_FILE | grep -w "NODE=$node" | head -1 | cut -d ';' -f2 | cut -d '=' -f2`
if [[ $check -eq 1 ]]
then
   echo 0
else
   echo 1
fi
}

COUNT=1

rm extNodeFile.txt
while [ $COUNT -le $NODES ]
do
  extNODE=`expr $STARTNODENUM + $COUNT`
  #echo "$COUNT" >> extNodeFile.txt
  echo "$extNODE" >> extNodeFile.txt
  COUNT=`expr $COUNT + 1`
done

## Network File
################################################################################
NODENUM=$(expr $(expr $(expr $SIMNUM - 1) \* $NUMOFRBS) + 1)
ENDNODE=$(expr $SIMNUM \* $NUMOFRBS)
while [ $NODENUM -le $ENDNODE ]
do
   if [[ $NODENUM -gt $BORDERNODE ]]
   then
       EXTGNB=$MAJOREXTGNB
   else
       EXTGNB=$MINOREXTGNB
   fi
   EXTNODEFILE="ext_node_"$NODENUM".txt"
   TOTALEXTNODEFILE="total_ext_node_"$NODENUM".txt"
   if [ -e $TOTALEXTNODEFILE ]
   then
      rm $TOTALEXTNODEFILE
   fi
   if [ -e $EXTNODEFILE ]
   then
      rm $EXTNODEFILE
   fi
################################################################################
   cat extNodeFile.txt | grep -wv $NODENUM >> $TOTALEXTNODEFILE
   if [ $NODENUM -le $BORDERNODE ]
   then
      while read -r line
      do
         if [ $line -le $BORDERNODE ]
         then
            nodeCheck=`checkCellTypeOfNode $line`
            if [[ $nodeCheck -eq 0 ]]
            then
#               echo "********Skiping 1 cell nodetype*************"
               extOneCellNodeArray[$line]=1
            else
               echo $line >> $EXTNODEFILE
            fi
         fi
      done < $TOTALEXTNODEFILE
   else
      while read -r line
      do
         if [ $line -gt $BORDERNODE ]
         then
            nodeCheck=`checkCellTypeOfNode $line`
            if [[ $nodeCheck -eq 0 ]]
            then
#               echo "********Skiping 1 cell nodetype*************"
               extOneCellNodeArray[$line]=1
            else
               echo $line >> $EXTNODEFILE
            fi
         fi
      done < $TOTALEXTNODEFILE
   fi
   #RANGE=$(expr $NODES - 1)
   RANGE=`cat $EXTNODEFILE | wc -l`
   List=`awk -v loop=$EXTGNB -v range=$RANGE 'BEGIN{
  srand()
  do {
    numb = 1 + int(rand() * range)
    if (!(numb in prev) && !(numb in extOneCellNodeArray)) {
       print numb
       prev[numb] = 1
       count++
    }
  } while (count<loop)
}'`

   Rels=(${List// / })
   REL="NODE="$NODENUM"-->"
   for relnum in ${Rels[@]}
   do
      RELATION=`awk 'NR=='$relnum $EXTNODEFILE`
      if [[ $RELATION == "" ]]
      then
         echo "NODE=$NODENUM;REL=$relnum"
      fi
      REL=$REL$RELATION","
   done
   echo $REL >> $NODELINKSFILE
   rm $EXTNODEFILE
   rm $TOTALEXTNODEFILE
   NODENUM=`expr $NODENUM + 1`
done
