// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/security/Pausable.sol"; // For Circuit Breaker
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // For Invariant Checks and TVL Guardrails

/**
 * @title EnhancedSecurityTimelock
 * @dev An improved version of SecurityTimelock that implements the principles of "Security by Design".
 * Includes:
 * - Infrastructure Protection: Delay (48h) and role separation (RBAC).
 * - Logical Code Protection: Possibility of pausing and checking invariants.
 * - Monitoring and Anomaly Protection: Protection against excessive outputs (TVL Guardrails).
 */
contract EnhancedSecurityTimelock is TimelockController, Pausable {
    // --- Storage для TVL Guardrails ---
    uint256 public maxTVLPerBlock; // The maximum amount that can be "called" per block
    uint256 public lastBlockNumber; // The number of the last block in which the call occurred
    uint256 public cumulativeTVLThisBlock; // The accumulated amount of calls in the current block

    // --- Storage для Invariant Checks ---
    mapping(address => uint256) public balanceBeforeExecution; // Token balance before execution
    address[] public monitoredTokens; // List of tokens whose balances are monitored

    // --- Events for monitoring ---
    event TVLThresholdExceeded(uint256 value, uint256 maxAllowed);
    event InvariantViolationDetected(address indexed token, uint256 balanceBefore, uint256 balanceAfter);
    event PausedByAdmin(address account);
    event UnpausedByAdmin(address account);
    event MonitoredTokenAdded(address indexed token);
    event MaxTVLPerBlockUpdated(uint256 newValue);

    /**
     * @dev Constructor, calls the parent TimelockController.
     * @param minDelay Minimum delay (in seconds).
     * @param proposers Addresses that may offer transactions.
     * @param executors Addresses that can perform operations.
     * @param admin Administrator address (usually for role management).
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {}

    /**
     * @dev Overriding the schedule function to integrate TVL Guardrails.
     * Checks if the amount (`value`) exceeds the accumulated limit in the current block.
     */
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public payable virtual override whenNotPaused returns (bytes32) { // whenNotPaused added for Circuit Breaker
        _checkTVL(value);
        return super.schedule(target, value, data, predecessor, salt, delay);
    }

    /**
     * @dev We override the execute function to integrate Invariant Checks.
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual override whenNotPaused { // whenNotPaused added for Circuit Breaker
        _checkTVL(value); // Check before execution
        _checkBalancesBeforeExecute(); // We check balances before execution

        super.execute(target, value, data, predecessor, salt);

        _checkBalancesAfterExecute(); // Check balances after execution
    }

    // --- Logical Code Protection: Circuit Breaker ---

    /**
     * @dev Pauses operations. Can be called by an administrator.
     */
    function pause() public onlyRole(TIMELOCK_ADMIN_ROLE) {
        _pause();
        emit PausedByAdmin(_msgSender());
    }

    /**
     * @dev Resumes operations. Can be called by an administrator.
     */
    function unpause() public onlyRole(TIMELOCK_ADMIN_ROLE) {
        _unpause();
        emit UnpausedByAdmin(_msgSender());
    }

    // --- Monitoring and Anomaly Protection: TVL Guardrails ---

    /**
     * @dev Sets the maximum TVL that can be "called" in a single block.
     * Can be called by administrator.
     */
    function setMaxTVLPerBlock(uint256 newValue) public onlyRole(TIMELOCK_ADMIN_ROLE) {
        maxTVLPerBlock = newValue;
        emit MaxTVLPerBlockUpdated(newValue);
    }

    /**
     * @dev Checks if `value` exceeds the accumulated limit in the current block.
     */
    function _checkTVL(uint256 value) private {
        if (block.number != lastBlockNumber) {
            // New block, reset the counter
            lastBlockNumber = block.number;
            cumulativeTVLThisBlock = 0;
        }

        if (cumulativeTVLThisBlock + value > maxTVLPerBlock && maxTVLPerBlock > 0) {
            emit TVLThresholdExceeded(value, maxTVLPerBlock);
            revert("EnhancedSecurityTimelock: TVL threshold exceeded for this block");
        }
        cumulativeTVLThisBlock += value;
    }

    // --- Logical Code Protection: Invariant Checks ---

    /**
     * @dev Adds a token to the list of invariants to be monitored.
     * Can be called by administrator.
     */
    function addMonitoredToken(address token) public onlyRole(TIMELOCK_ADMIN_ROLE) {
        // Simple duplicate check (can be optimized)
        for(uint i = 0; i < monitoredTokens.length; i++) {
            if(monitoredTokens[i] == token) {
                return; // Already being tracked
            }
        }
        monitoredTokens.push(token);
        emit MonitoredTokenAdded(token);
    }

    /**
     * @dev Saves the balances of monitored tokens before performing an operation.
     */
    function _checkBalancesBeforeExecute() private {
        for(uint i = 0; i < monitoredTokens.length; i++) {
            balanceBeforeExecution[monitoredTokens[i]] = IERC20(monitoredTokens[i]).balanceOf(address(this));
        }
    }

    /**
     * @dev Checks the balances of monitored tokens after performing an operation.
     * It is assumed that the balance should not decrease without a corresponding call.
     * This is a simplified check and may require adjustments for your specific scenario.
     */
    function _checkBalancesAfterExecute() private {
        for(uint i = 0; i < monitoredTokens.length; i++) {
            address token = monitoredTokens[i];
            uint256 balanceAfter = IERC20(token).balanceOf(address(this));
            uint256 balanceBefore = balanceBeforeExecution[token];
            // An example of an invariant: the balance should not drop unexpectedly.
            // This may be too strict for some tokens (e.g. with fee-on-transfer).
            // In reality, the verification logic may be more complex.
            if (balanceBefore > balanceAfter) {
                 // Here you can simply log the violation or roll back the transaction.
                 // In this example, a rollback is used for demonstration purposes.
                 emit InvariantViolationDetected(token, balanceBefore, balanceAfter);
                 revert("EnhancedSecurityTimelock: Invariant violation detected!");
            }
        }
    }

    // --- View Functions for monitoring ---
    function getMonitoredTokens() external view returns (address[] memory) {
        return monitoredTokens;
    }

    function getCumulativeTVLThisBlock() external view returns (uint256) {
        return cumulativeTVLThisBlock;
    }

    function getLastBlockNumber() external view returns (uint256) {
        return lastBlockNumber;
    }
}
