#!/bin/sh

#
##############################################################################
##     File Name    : Script_to_UpdatIp.sh
##     Author       : Siva Mogilicharla
##     Description  : This will update the ips count in simulation folder
##     Date Created : 10 February 2022
##     Usage        : sh Script_to_UpdatIp.sh <Sim name>
####################################################################################

sim=$1

echo "   "
echo "Running python script for Updating IP values on $sim : "

PWD=`pwd`

source "$PWD/../dat/CONFIG.env"
RV=$SWITCHTORV

switchRV="$(tr [A-Z] [a-z] <<< "$RV")"
echo "Switch To RV is given as $switchRV"

cd ../bin/Updating_IPs/

chmod 777 *

python new_updateip.py -deploymentType mediumDeployment -release 22.03 -simLTE $sim -simWRAN NO_NW_AVAILABLE -simCORE NO_NW_AVAILABLE  -switchToRv $switchRV -IPV6Per yes -docker no

echo "  "
echo "Script_to_UpdateIp.sh script is Completed..."
echo "  "

