// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract InferenceCoordinator is Ownable, ReentrancyGuard {
    struct InferenceTask {
        address requester;
        string modelId;
        string prompt;
        bytes output;
        address node;
        uint256 disputeDeadline;
        bool finalized;
    }

    mapping(uint256 => InferenceTask) public tasks;
    uint256 public taskCount;
    uint256 public constant DISPUTE_PERIOD = 1 hours;

    event TaskCreated(uint256 indexed taskId, string modelId, string prompt);
    event OutputSubmitted(uint256 indexed taskId, address indexed node, bytes output);
    event TaskFinalized(uint256 indexed taskId);

    constructor() Ownable(msg.sender) {}

    function requestInference(string calldata _modelId, string calldata _prompt) external payable {
        require(msg.value > 0, "Bounty required");
        
        uint256 taskId = taskCount++;
        tasks[taskId].requester = msg.sender;
        tasks[taskId].modelId = _modelId;
        tasks[taskId].prompt = _prompt;
        
        emit TaskCreated(taskId, _modelId, _prompt);
    }

    function submitOutput(uint256 _taskId, bytes calldata _output) external {
        InferenceTask storage task = tasks[_taskId];
        require(task.node == address(0), "Output already submitted");
        
        task.output = _output;
        task.node = msg.sender;
        task.disputeDeadline = block.timestamp + DISPUTE_PERIOD;

        emit OutputSubmitted(_taskId, msg.sender, _output);
    }

    function finalizeTask(uint256 _taskId) external {
        InferenceTask storage task = tasks[_taskId];
        require(block.timestamp > task.disputeDeadline, "Dispute window open");
        require(!task.finalized, "Already finalized");

        task.finalized = true;
        // Logic to pay the node the bounty
        emit TaskFinalized(_taskId);
    }
}
