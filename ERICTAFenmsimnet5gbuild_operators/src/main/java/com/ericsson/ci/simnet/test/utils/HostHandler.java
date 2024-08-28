/**
  * -----------------------------------------------------------------------
  *     Copyright (C) 2016 LM Ericsson Limited.  All rights reserved.
  * -----------------------------------------------------------------------
  */
 package com.ericsson.ci.simnet.test.utils;
 
 import java.util.List;
 
 import org.slf4j.Logger;
 import org.slf4j.LoggerFactory;
 
 import com.ericsson.cifwk.taf.data.DataHandler;
 import com.ericsson.cifwk.taf.data.Host;
 import com.ericsson.oss.testware.hostconfigurator.HostConfigurator;
 
 /**
  * Handles different type hosts to be captured.
  *
  * @author xkatmri
  *
  */
 public class HostHandler {
 
     /** Logging utility */
     private static final Logger logger = LoggerFactory.getLogger(HostHandler.class);
 
     private static final String VAPP_MASTER_SERVER_IP = "192.168.0.42";
 
     /** List of the hosts connected to DMT */
     private static List<Host> hosts = HostConfigurator.getAllNetsimHosts();
 
     /**
      * Returns the correspondence available host by checking jenkins and properties args.
      *
      * @return available host by in order of MV job, cluster-id and physical-or-vm-netsim
      */
     public static Host getTargetHost() {
 
         for (final Host host : hosts) {
             logger.debug("DMT-host:{}", host.toString());
         }
 
         String serverName = null;
         try {
             serverName = DataHandler.getAttribute("serverName").toString();
         } catch (final NullPointerException e) {
             logger.debug("HostSetup::noServerNames");
         }
 
         if (serverName != null && !serverName.isEmpty()) {
             final Host host = DataHandler.getHostByName(serverName);
             logger.debug("HostSetup::serverName= {}", serverName);
             return host;
         }
 
 /*        if (HostConfigurator.getNetsim() != null) {
             final Host host = HostConfigurator.getNetsim();
             logger.debug("HostSetup::hostConfigurator={}", host.toString());
             return host;
         }*/
 
         final Host host = DataHandler.getHostByName("physical-or-vm-netsim");
         logger.debug("HostSetup::LocalProperties= {}", host.toString());
 
         return host;
     }
 
     public static String getMasterServerIp() {
         if (HostConfigurator.isPhysicalEnvironment()) {
             final Host host = HostConfigurator.getMS();
             logger.debug("getMasterServerIp::HostSetup::hostConfigurator={}", host.toString());
             return host.getIp();
         } else {
             logger.debug("getMasterServerIp::HostSetup::staticVappMSIP={}", VAPP_MASTER_SERVER_IP);
             return VAPP_MASTER_SERVER_IP;
         }
     }
 }
