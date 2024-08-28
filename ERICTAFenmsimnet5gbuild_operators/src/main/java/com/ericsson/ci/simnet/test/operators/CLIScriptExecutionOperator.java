package com.ericsson.ci.simnet.test.operators;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.ericsson.ci.simnet.test.utils.HostHandler;
import com.ericsson.ci.simnet.test.utils.TafFileUtils;
import com.ericsson.ci.simnet.test.utils.ZipUtility;
//import com.ericsson.cifwk.taf.annotations.Context;
import com.ericsson.cifwk.taf.annotations.Operator;
import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.data.Host;
import com.ericsson.cifwk.taf.data.User;
import com.ericsson.cifwk.taf.data.UserType;
import com.ericsson.cifwk.taf.tools.cli.handlers.impl.RemoteObjectHandler;
import com.ericsson.cifwk.taf.tools.cli.CLICommandHelper;
import com.google.inject.Singleton;

/**
 * @author xkatmri
 *
 */
//@Operator(context = Context.CLI)
@Singleton
public class CLIScriptExecutionOperator implements ScriptExecutionOperator {

    /** Remote host where scripts going to be executed */
    private static final Host host = HostHandler.getTargetHost();
    private static final String hostName = host.toString();
    private static final String masterServerIp = HostHandler.getMasterServerIp();

    /** Remote file location in unix format */
    private static final String REMOTE_FOLDER_TAF_SCRIPTS_LOCATION = "/var/simnet/enm-simnet-5G/";

    /** Local folder for embedded scripts */
    private static final String LOCAL_FOLDER_SCRIPTS_LOCATION = "scripts";

    /** Local zip folder for zipped embedded scripts */
    private static final String LOCAL_FOLDER_ZIP_FILES_LOCATION = "zips";

    /** Regular expression search term to find jar file list in Jenkins */
    private static final String JENKINS_JAR_FILE_SEARCH_TERM = ".jar";

    /** Regular expression search term to find enm_ni_simnet jar file in Jenkins */
    private static final String JENKINS_ENM_NI_SIMNET_JAR_FILE_SEARCH_TERM = "lib.*CXP9036539";

    /** Local zip file name for zipped embedded scripts */
    private static final String ZIP_FILE_NAME = "enm-simnet-5G.zip";

    /** Logging utility */
    private static final Logger logger = LoggerFactory.getLogger(CLIScriptExecutionOperator.class);

    /** Taf command handler instance */
    private CLICommandHelper cliCmdHelper;

    /**
     * Constructs a CLIScriptExecutionOperator instance
     */
    public CLIScriptExecutionOperator() {
        cliCmdHelper = new CLICommandHelper(host);
    }

    /**
     * Prepare prerequisite test execution environment before test execution start.
     *
     * @return true if initial setup is successful, otherwise false
     */
    public static boolean initialise() {

        logger.info("host:" + host.toString());
        logger.info("Master hostname is {}", masterServerIp);

        try {
            // Setup cmd and file handlers
            CLICommandHelper.DEFAULT_COMMAND_TIMEOUT_VALUE = 3600L * 4;
            final CLICommandHelper cliComandHelper = new CLICommandHelper(host);

            try {
                return setUpRemoteServerFolder(cliComandHelper) && copyScriptsFolderToRemoteServer(cliComandHelper)
                        && setUpRemoteFolderPermission(cliComandHelper) && convertRemoteFolderFilesDosToUnix(cliComandHelper);
            } finally {
                cliComandHelper.disconnect();
            }
        } catch (final Exception e) {
            logger.error("Error occured while initialising the TAF env. \n", e);
            return false;
        }

    }

    private static boolean setUpRemoteServerFolder(final CLICommandHelper cliComandHelper) {
        // Set up remote folder
        final String remoteFolderSetupOutput;
        final User user = host.getUsers(UserType.ADMIN).get(0);
        user.setUsername("root");
        user.setPassword("shroot");
        cliComandHelper.newHopBuilder().hop(user).build();
        cliComandHelper.execute("mkdir -v -p /var/simnet/; chmod -R 777 /var/simnet/; chown -v netsim:netsim /var/simnet");
        final String changeOwnerSetupOutput = cliComandHelper.getStdOut();
        logger.info("changeOwnerSetupOutput={}", changeOwnerSetupOutput);
        final int changeOwnerSetupCmdExitCode = cliComandHelper.getCommandExitValue();
        logger.info("changeOwnerSetupCmdExitCode={} ", changeOwnerSetupCmdExitCode);
        //cliComandHelper.disconnect(); // disconnect from the hop shell
        if (changeOwnerSetupCmdExitCode != 0) {
            return false;
        }

        cliComandHelper.newHopBuilder().hop(user).build();
        final String cmd01 = "rm -rf " + REMOTE_FOLDER_TAF_SCRIPTS_LOCATION + "; mkdir -p " + REMOTE_FOLDER_TAF_SCRIPTS_LOCATION;
        remoteFolderSetupOutput = cliComandHelper.execute(cmd01);
        logger.info("remoteFolderSetupOutput={}", remoteFolderSetupOutput);
        final int remoteFolderSetupCmd01ExitCode = cliComandHelper.getCommandExitValue();
        logger.info("remoteFolderSetupCmd01ExitCode={}", remoteFolderSetupCmd01ExitCode);
        if (remoteFolderSetupCmd01ExitCode != 0) {
            return false;
        }
        return true;
    }

    private static boolean copyScriptsFolderToRemoteServer(final CLICommandHelper cliComandHelper) {
        final User user = host.getUsers(UserType.ADMIN).get(0);
        user.setUsername("root");
        user.setPassword("shroot");
        final RemoteObjectHandler remoteFileHandler = new RemoteObjectHandler(host, user);

        // Create a zip file to pack all the local scripts
        String zipFile;
        String localFolderScriptsLocation;
        String currentPath;
        try {

            final Path currentRelativePath = Paths.get("");
            currentPath = currentRelativePath.toAbsolutePath().toString();
            logger.debug("currentPath: {}", currentPath);

            if (Pattern.compile("testware").matcher(currentPath).find()) {
                zipFile = TafFileUtils.getNewFilePath(LOCAL_FOLDER_ZIP_FILES_LOCATION, ZIP_FILE_NAME);
                localFolderScriptsLocation = TafFileUtils.getFilePath(LOCAL_FOLDER_SCRIPTS_LOCATION);
                logger.debug("1-localFolderScriptsLocation: {}", localFolderScriptsLocation);

            } else {
                zipFile = TafFileUtils.getNewFilePath(currentPath, ZIP_FILE_NAME);

                // Search all jar files and return a file name contains lib and CXP9036539 words.
                final String simnetJarFile = TafFileUtils.getFilePath(JENKINS_JAR_FILE_SEARCH_TERM, JENKINS_ENM_NI_SIMNET_JAR_FILE_SEARCH_TERM);
                logger.debug("simnetJarFile:{}", simnetJarFile);

                final String destUnzipFolderName = "ENM-SIMNET-5G";
                final String destUnzipFolder = TafFileUtils.getNewFilePath(currentPath, destUnzipFolderName);
                logger.debug("destUnzipFolder: {}", destUnzipFolder);
                ZipUtility.unzip(simnetJarFile, destUnzipFolder);
                logger.debug("Unzipping completed for file: {} |", simnetJarFile);

                localFolderScriptsLocation = destUnzipFolder + "/script";
                logger.debug("1-localFolderScriptsLocation: {}", localFolderScriptsLocation);
            }
            logger.debug("zipFile: {}", zipFile);
            ZipUtility.zip(zipFile, localFolderScriptsLocation);

        } catch (final IOException e) {
            logger.error("Unable to to zip/unzip the file: ", e);
            return false;
        }

        // Copy local files to remote location
        try {
            logger.debug("Start copying zipFile:{} to remote server", zipFile);
            final boolean filesCopied = remoteFileHandler.copyLocalFileToRemote(zipFile, REMOTE_FOLDER_TAF_SCRIPTS_LOCATION, currentPath);
            logger.info("filesCopied={}", filesCopied);
            if (!filesCopied) {
                return false;
            }

        } catch (final Exception e) {
            logger.error("Unable to locate scripts path ", e);
            return false;
        }

        // Unzip the zip file remotely
        final String cmd02 = "whoami; cd " + REMOTE_FOLDER_TAF_SCRIPTS_LOCATION + "; unzip " + ZIP_FILE_NAME + "; unzip -t " + ZIP_FILE_NAME;
        final String unzipOutput = cliComandHelper.execute(cmd02);

        logger.info("convertionOutput3={}", unzipOutput);
        final int unzipCmd02ExitCode = cliComandHelper.getCommandExitValue();
        logger.info("unzipCmd02ExitCode={}", unzipCmd02ExitCode);

        if (unzipCmd02ExitCode != 0) {
            return false;
        }

        return true;
    }

    private static boolean setUpRemoteFolderPermission(final CLICommandHelper cliComandHelper) {
        // Set up the remote file||folder permissions under unix
        final User user = host.getUsers(UserType.ADMIN).get(0);
        user.setUsername("root");
        user.setPassword("shroot");
        final String cmd03 = "whoami; cd " + REMOTE_FOLDER_TAF_SCRIPTS_LOCATION + "; chmod -R +x * ";
        logger.info("Switching to admin user {}", user.toString());
        cliComandHelper.newHopBuilder().hop(user).build();
        cliComandHelper.execute(cmd03);
        final String filePermissionSetupOutput = cliComandHelper.getStdOut();
        logger.info("filePermissionSetupOutput={}", filePermissionSetupOutput);
        final int filePermissionSetupCmd03ExitCode = cliComandHelper.getCommandExitValue();
        logger.info("filePermissionSetupCmd03ExitCode={}", filePermissionSetupCmd03ExitCode);
        // cliComandHelper.disconnect(); // disconnect from the hop shell
        if (filePermissionSetupCmd03ExitCode != 0) {
            return false;
        }
        return true;
    }

    private static boolean convertRemoteFolderFilesDosToUnix(final CLICommandHelper cliComandHelper) {
        // Convert dos files into unix format on remote server
        final String convertionOutput;
        final String cmd04 = "whoami ; cd " + REMOTE_FOLDER_TAF_SCRIPTS_LOCATION + "; perl -i -pe 's/\\r//g' `find . -print | egrep -i 'sh|pl|txt'`";
        convertionOutput = cliComandHelper.execute(cmd04);
        logger.info("convertionOutput= {}", convertionOutput);
        final int convertionCmd04ExitCode = cliComandHelper.getCommandExitValue();
        logger.info("convertionCmd04ExitCode = {}", convertionCmd04ExitCode);
        if (convertionCmd04ExitCode != 0) {
            return false;
        }
        return true;
    }

    @Override
    public int verifyScriptExecution(final String command) {

        final User user = host.getUsers(UserType.ADMIN).get(0);
        user.setUsername("root");
        user.setPassword("shroot");
        final String debugCommandsOutput;
        
        
        String simName = convertToPerlCmdArg(DataHandler.getAttribute("simName").toString());
        String ENV;
        try {
            ENV = convertToPerlCmdArg(DataHandler.getAttribute("ENV").toString());
            if (ENV.isEmpty()) {
                 ENV = "RV";
            }
        } catch (final NullPointerException npe) {
            logger.debug("Switch to default ENV=RV");
            ENV = "RV";
        }
        String simnetParam = "";
        try {
            cliCmdHelper = new CLICommandHelper(host, user);

            if (logger.isDebugEnabled()) {
                final String debugCommands = "whoami";
                logger.debug("debugCommands to be executed: {}", debugCommands);
                if (!hostName.equals("UNKNOWN development-netsim") && !hostName.equals("UNKNOWN physical-or-vm-netsim")) {
                    debugCommandsOutput = cliCmdHelper.execute(debugCommands);
                } else {
                    debugCommandsOutput = cliCmdHelper.simpleExec(debugCommands);
                }
                logger.debug("debugCommandsOutput: {}", debugCommandsOutput);
            }
            // workAround to relative path within script
            // if script has a relative path reference within script
            // it will fail due to script is checking reference where the
            // script is executed
            if (command.contains("/")) {
                String tmpCommand = command;
                if (command.contains(" ")) {
                    final int endIndex = command.indexOf(" ");
                    tmpCommand = command.substring(0, endIndex);
                }
                final int endIndex = tmpCommand.lastIndexOf("/");
                logger.debug(tmpCommand,endIndex);
                final String commandPath = tmpCommand.substring(0, endIndex);
                final String cdToScriptLocationCmd = "cd " + commandPath;
                logger.debug("cdToScriptLocationCmd to be executed: {}", cdToScriptLocationCmd);
                // To leave the current shell open, here, execute command is used.
                // Hence, the script will be executed from the commandPath rather than a relative path.
                // In others words, the initial location for the next command will be the commandPath.
                cliCmdHelper.execute(cdToScriptLocationCmd);
                final String commandPathOutput = cliCmdHelper.getStdOut();
                logger.debug("commandPathOutput: {}", commandPathOutput);
            }
            
            if (command.contains("simnet") && command.contains("installTemplate.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                simnetParam = " " + simName;
                logger.info("simnetParam is " + simnetParam);
                logger.info("Command to be executed: {}", command.concat(simnetParam));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simnetParam)));
            } 
            else if (command.contains("simnet") && command.contains("simBuild.py")) {
                String tmpCommand = command;
                //String productNumber = convertToPerlCmdArg(DataHandler.getAttribute("productNumber").toString());
                //String productRevision = convertToPerlCmdArg(DataHandler.getAttribute("productRevision").toString());
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                simnetParam = " " + simName + " " + ENV;
                logger.info("simnetParam is " + simnetParam);
                logger.info("Command to be executed: {}", command.concat(simnetParam));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simnetParam)));
            }   
            else if (command.contains("simnet") && command.contains("ProductdataTest.pl")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("BackupDataUnitTest.pl")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("PmGroupCheck.pl")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("CheckCipherUnitTest.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
			else if (command.contains("simnet") && command.contains("CheckEnbIdonNR.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("pmFileLocation.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("SimSizeCheck.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("TopologyCheck.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
            else if (command.contains("simnet") && command.contains("EbsFeaturesCheck.sh")) {
                 String tmpCommand = command;
                 final int endIndex=tmpCommand.length();
                 final int lastIndex = tmpCommand.lastIndexOf("/");
                 final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                 logger.info("Command to be executed: {}", command.concat(simName));
                 cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
	   else if (command.contains("simnet") && command.contains("Check_UT_NR03_CBRS_LL_sim.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
	   else if (command.contains("simnet") && command.contains("Check_UT_NR04_CBRS_LL_sim.sh")) {
                String tmpCommand = command;
                final int endIndex=tmpCommand.length();
                final int lastIndex = tmpCommand.lastIndexOf("/");
                final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
                logger.info("Command to be executed: {}", command.concat(simName));
                cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
           else if (command.contains("simnet") && command.contains("Check_UT_NR06_CBRS_LL_sim.sh")) {
               String tmpCommand = command;
               final int endIndex=tmpCommand.length();
               final int lastIndex = tmpCommand.lastIndexOf("/");
               final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
               logger.info("Command to be executed: {}", command.concat(simName));
               cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
           }
           else if (command.contains("simnet") && command.contains("Check_UT_NR15_CBRS_LL_sim.sh")) {
               String tmpCommand = command;
               final int endIndex=tmpCommand.length();
               final int lastIndex = tmpCommand.lastIndexOf("/");
               final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
               logger.info("Command to be executed: {}", command.concat(simName));
               cliCmdHelper.execute(("./").concat(scriptCommand.concat(simName)));
            }
           else if (command.contains("simnet") && command.contains("BrmBackupManager.sh")){
               String tmpCommand = command;
               final int endIndex=tmpCommand.length();
               final int lastIndex = tmpCommand.lastIndexOf("/");
               final String scriptCommand=tmpCommand.substring(lastIndex+1,endIndex);
               simnetParam = " " + simName;
               logger.info("Command to be executed: {}", command.concat(simnetParam));
               cliCmdHelper.execute(("./").concat(scriptCommand.concat(simnetParam)));
           }
            else {
                logger.info("Command to be executed: {}", command);
                cliCmdHelper.simpleExec(command);
            }

            final String output = cliCmdHelper.getStdOut();
            logger.info("Command output: {}", output);

            final int exitCode = cliCmdHelper.getCommandExitValue();
            logger.info("ExitCode:{}, command:\"{}\" ", exitCode, command);

            cliCmdHelper.disconnect();

            return exitCode;

        } catch (final Exception e) {
            logger.error("Error occured while executing command:{} \n", command, e);
            return Integer.MIN_VALUE;
        }

    }

    private String convertToPerlCmdArg(final String arg) {
        return arg.isEmpty() ? "\"\"" : arg;
    }
}

