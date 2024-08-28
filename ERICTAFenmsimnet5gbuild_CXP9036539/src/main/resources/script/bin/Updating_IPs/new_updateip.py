#!/usr/bin/python

from multiprocessing import Pool
import time,subprocess,os,sys,warnings
warnings.filterwarnings("ignore")

input_args = sys.argv[1:]
deploymentType, release, switchToRv ,IPV6Per , docker = input_args[input_args.index("-deploymentType")+1], input_args[input_args.index("-release")+1], input_args[input_args.index("-switchToRv")+1], input_args[input_args.index("-IPV6Per")+1], input_args[input_args.index("-docker")+1]

default_args =  input_args[0:input_args.index("-simLTE")]
default_args1 = input_args[input_args.index("-simCORE")+2:]
default_item,default_item1="",""
for item in default_args:
        default_item = default_item + " " + item
for item in default_args1:
        default_item1 = default_item1 + " " + item

def getData(simName):
     if "no" in docker:
         createMML = "touch MML.mml; chmod 777 MML.mml"
         os.system(createMML)
#         for simLoc in simLocList:
#                 if simName+"-" in simLoc:
#                         simZip = simLoc.split("/")[-1].split('"')[0]
#                         runFetchOpen= "su netsim -c './fetchOpenSim.pl " + simName + " " + simLoc.strip("\n") + " " + simName + ".zip no'"
#                         runFetchOpenOutput=os.popen(runFetchOpen).read()
#         if "Conflicts with already installed files" in runFetchOpenOutput:
#                 runFetchOpen= "su netsim -c './fetchOpenSim.pl " + simName + " " + simLoc.strip("\n") + " " + simName + ".zip yes'"
#                 os.system(runFetchOpen)
     neType=getNeType(simName)       
     return neType

def getNeType(simName):
     simInfoFile = simName + ".txt"
     
     clearMML = "rm -rf MML.mml; touch MML.mml; chmod 777 MML.mml; touch dumpNeName.txt dumpNeType.txt listNeName.txt listNeType.txt; chmod 777 dumpNeName.txt dumpNeType.txt listNeName.txt listNeType.txt"
     os.system(clearMML)
    
     runReadSimData = "su netsim -c './readSimData.pl " + simName + ".zip " + docker + "' > " + simInfoFile
     readSimDataOutput=os.popen(runReadSimData).read()
     if "Error" in readSimDataOutput:
         print "ERROR:Error while reading Sim. Retrying..."
         readSimDataOutput=os.popen(runReadSimData).read()
         if "Error" in readSimDataOutput:
                    sys.exit(1)
     if simName not in WRAN_simsList:
         getNeType = "chmod 777 %s; cat %s | grep 'neType' | sort -nk 4|head -1"%(simInfoFile, simInfoFile)
         result = os.popen(getNeType).read()
         neType = '"' + result.split("neName = ")[1].split(" neTypeFull = ")[1].split("\n")[0] + '"'
     else:
         getNeType1 = "chmod 777 %s; cat %s | grep 'neType' | sort -nk 4| sed -n '1p'"%(simInfoFile, simInfoFile)
         getNeType2 = "chmod 777 %s; cat %s | grep 'neType' | sort -nk 4| sed -n '2p'"%(simInfoFile, simInfoFile)
         result = os.popen(getNeType1).read()
         neType1 = '"' + result.split("neName = ")[1].split(" neTypeFull = ")[1].split("\n")[0] + '"'
         try:
                result = os.popen(getNeType2).read()
                neType2 = '"' + result.split("neName = ")[1].split(" neTypeFull = ")[1].split("\n")[0] + '"'
                neType = neType1 + ":" + neType2
         except:
                neType = neType1
                removeMML = "rm -rf ../dat/MML.mml; touch ../dat/MML.mml; chmod 777 ../dat/MML.mml"
                os.system(removeMML)
     print neType
     return neType

def fetchipcount(simName, neType):
        global release, switchToRv
        #createDatFiles = "touch ipVars.dat dumpDecisionParams.txt; chmod 777 ipVars.dat dumpDecisionParams.txt"
        createDatFiles = "touch IP_Details.txt; chmod 777 IP_Details.txt"
	os.system(createDatFiles)
        runDecisionModule = "su netsim -c './decisionModule.pl %s %s %s off %s %s'" %(simName,neType, release, IPV6Per, switchToRv)
        print simName,neType, release, IPV6Per, switchToRv
	decisionModuleOutput = os.popen(runDecisionModule).read()
        if "Error" in decisionModuleOutput:
                print "ERROR:Error while running decisionModule. Retrying..."
                decisionModuleOutput = os.popen(runDecisionModule).read()
                if "Error" in decisionModuleOutput:
                        sys.exit(1)
        ipv4_count = int(decisionModuleOutput.split("numOfIpv4Nes= ")[1].split(" \n")[0])
        ipv6_count = int(decisionModuleOutput.split("numOfIpv6Nes= ")[1].split(" \n")[0])
        removeDatFiles = "rm -rf MML.mml; touch MML.mml; chmod 777 MML.mml; rm -rf dumpNeName.txt dumpNeType.txt listNeName.txt listNeType.txt"
        os.system(removeDatFiles)
        return ipv4_count,ipv6_count


simsList, CORE_simsList, LTE_simsList, WRAN_simsList=[], [], [], []


if "-simCORE" in input_args:
        CORE_sims=input_args[(input_args.index("-simCORE"))+1]
        CORE_simsList=CORE_sims.split(':')
        CORE_simsList=filter(lambda a: a != "NO_NW_AVAILABLE", CORE_simsList)
        simsList+=CORE_simsList
if "-simLTE" in input_args:
        LTE_sims = input_args[(input_args.index("-simLTE"))+1]
        LTE_simsList = LTE_sims.split(':')
        LTE_simsList=filter(lambda a: a != "NO_NW_AVAILABLE", LTE_simsList)
        simsList+=LTE_simsList
if "-simWRAN" in input_args:
        WRAN_sims = input_args[(input_args.index("-simWRAN"))+1]
        WRAN_simsList = WRAN_sims.split(':')
        WRAN_simsList=filter(lambda a: a != "NO_NW_AVAILABLE", WRAN_simsList)
        simsList+=WRAN_simsList

for sim in CORE_simsList:
                print "INFO:Fetching info for ",sim
                neType = getData(sim)
                ip_count = fetchipcount(sim, neType)
#               fetchips(sim,ip_count[0],ip_count[1],"CORE")
for sim in LTE_simsList:
                print "INFO:Fetching info for ",sim
                neType = getData(sim)
                ip_count = fetchipcount(sim, neType)
#               fetchips(sim,ip_count[0],ip_count[1], "LTE")
for sim in WRAN_simsList:
                print "INFO:Fetching info for ",sim
                neType = getData(sim)
                ip_count = fetchipcount(sim, neType)
#               fetchips(sim,ip_count[0],ip_count[1], "WRAN")
