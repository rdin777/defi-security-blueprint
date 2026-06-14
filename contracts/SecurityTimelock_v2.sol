// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title EnhancedSecurityTimelock
 * @dev Extended version of SecurityTimelock with checks.
 */
contract EnhancedSecurityTimelock is TimelockController {
    mapping(bytes32 => bool) private _executed; // For tracking

    // List of tokens for which we check the balance
    address[] public monitoredTokens;
    // Total balance for each token before execution
    mapping(address => uint256) public balanceBeforeExecution;

    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {}

    /**
     * @dev Add a monitoring token.
     */
    function addMonitoredToken(address token) external onlyRole(ADMIN_ROLE) {
        // Check that the token is not duplicated
        for(uint i = 0; i < monitoredTokens.length; i++) {
            if(monitoredTokens[i] == token) return; // Already have
        }
        monitoredTokens.push(token);
    }

    /**
     * @dev We override execute to add checks.
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual override {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);

        // --- NEW: Invariant Checking---
        _checkBalancesBeforeExecute();
        // -------------------------------

        super.execute(target, value, data, predecessor, salt);

        // --- NEW: Invariant check after ---
        _checkBalancesAfterExecute();
        // ---------------------------------------

        emit OperationExecuted(id);
    }

    function _checkBalancesBeforeExecute() private {
        for(uint i = 0; i < monitoredTokens.length; i++) {
            balanceBeforeExecution[monitoredTokens[i]] = IERC20(monitoredTokens[i]).balanceOf(address(this));
        }
    }

    function _checkBalancesAfterExecute() private {
        for(uint i = 0; i < monitoredTokens.length; i++) {
            uint256 balanceAfter = IERC20(monitoredTokens[i]).balanceOf(address(this));
            require(balanceBeforeExecution[monitoredTokens[i]] <= balanceAfter, "Invariant violated: Balance decreased unexpectedly!");
        }
    }
}
