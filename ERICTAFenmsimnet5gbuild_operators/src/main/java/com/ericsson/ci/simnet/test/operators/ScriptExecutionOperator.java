package com.ericsson.ci.simnet.test.operators;

/**
 * The user of this interface can execute scripts remotely and check the exit code.
 *
 * <p>
 * The user of this interface, while implement the interface should handle all prerequisite such as scripts to be executed 
 * should be placed under src/main/resources/scripts folder.
 *
 * @author xkatmri
 *
 */
public interface ScriptExecutionOperator {

    /**
     * Executes user defined command||script and return its exit code.
     *
     * Example:
     *
     * <pre>
     *      verifyScriptExecution(/var/simnet/enm-simnet/scripts/initiateCheck.pl);
     * </pre>
     *
     * @param command
     *            the full path of either script, or command
     * @return the exit code of either script, or command
     */
    int verifyScriptExecution(String command);

}
