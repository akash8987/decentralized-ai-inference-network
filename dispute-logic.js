const { ethers } = require("ethers");

/**
 * Logic for a Challenger node to verify an output and trigger a dispute if fraud is detected.
 */
async function verifyAndDispute(taskId, submittedOutput, expectedOutput) {
    if (submittedOutput !== expectedOutput) {
        console.error(`Fraud detected in task ${taskId}!`);
        console.log("Submitting dispute to smart contract...");
        // Call contract.challenge(taskId, proofOfFraud)
        return true;
    }
    console.log("Output verified. No dispute needed.");
    return false;
}

module.exports = { verifyAndDispute };
