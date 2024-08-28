#!/usr/bin/python

import os,sys
CONFIG="/var/nssSingleSimulationBuild/CONFIG.env"
simsArg=sys.argv[1]
ENV=sys.argv[2]
simsList=simsArg.split(":")


def nodeCount(simName):
    nodes=int((simName.split("x")[1]).split("-")[0])
    return nodes

###########################################Preparing Config ENV###############################################
def modifyConf(simName):
    fh=open(CONFIG,"r+")
    if ENV == "MT":
       print "INFO: Modifing CONFIG.env file"
       for line in fh.readlines():
           if( "NUMOFRBS=" in line ):
                cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"="+str(nodeCount(simName))+"/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
           if( "DG2NUMOFRBS=" in line ):
                cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"="+str(nodeCount(simName))+"/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
           if( "SWITCHTORV=" in line ):
                cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"=NO/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
           if( "RelateWithLTE26=" in line ):
                if "NR02" in simName:
                    cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"=NO/' "+ CONFIG
                else:
                    cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"=YES/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
           if( "MULTIRATNR=" in line ):
                if "NR02" in simName:
                    cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"=YES/' "+ CONFIG
                else:
                    cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"=NO/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
    elif ENV == "RV":
        print "INFO: Modifing CONFIG.env file"
        for line in fh.readlines():
            if( "SWITCHTORV=" in line ):
                 cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"=YES/' "+ CONFIG
                 print "INFO: Executing %s Command "%(cmd)
                 os.system(cmd)
            if( "NUMOFRBS=" in line ):
                cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"="+str(nodeCount(simName))+"/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
            if( "DG2NUMOFRBS=" in line ):
                cmd="sed -i 's/"+line.rstrip('\n')+"/"+(line.rstrip('\n')).split("=")[0]+"="+str(nodeCount(simName))+"/' "+ CONFIG
                print "INFO: Executing %s Command "%(cmd)
                os.system(cmd)
 
for simName in simsList:
    modifyConf(simName)
    print "INFO: Starting Build of %s"%(simName)
    cmd1="./buildSims5G.pl %s"%(simName)
    os.system(cmd1)
    print "INFO: %s Simulation build was done"%(simName)
print "INFO: END of Simulations Build"
