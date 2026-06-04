
Audit Checklist: DeFi Smart Contracts
This checklist is used for an initial assessment of the project's security before a deep code analysis.

1. Access Control
[ ] Admin Privileges: Are there onlyOwner functions? What rights do they grant?

[ ] Concentration of Power: Can an admin withdraw all funds from a pool in one action?

[ ] Timelock: Is there a delay for critical operations?

2. Manipulation and Oracles
[ ] Price Source: Where does the asset's price come from? (Chainlink, Uniswap TWAP, or a custom oracle?)

[ ] Flash Loan Attack: Is the contract resistant to manipulation via flash loans? (Are TWAP oracles used?)

[ ] Data Freshness: Is the oracle data freshness checked?

3. Economic Invariants
[ ] Balance Checks: Is the contract balance always verified to match the total amount of obligations to users?

[ ] Slippage Protection: Is slippage limited when exchanging funds?

[ ] Liquidity Attacks: Is it possible to wipe out the pool's liquidity with a single transaction?

4. Code Security (Best Practices)
[ ] Reentrancy: Are nonReentrant modifiers used in all functions that make external calls?

[ ] Rounding Errors: Are there any issues with calculation accuracy (especially in DeFi formulas)?

[ ] ERC20 Compliance: Are tokens with "fees on transfer" handled correctly?

Advanced DeFi Specifics (Checking "under the hood")
[ ] ERC-20 Edge Cases:

[ ] Are tokens with "fees on transfer" supported? (If the contract expects to receive 100 and receives 98, an error may occur.)

[ ] How the contract handles tokens that do not return a boolean value (some older tokens, such as USDT, return `void` instead of `true`/`false`).

[ ] Staking/Reward Logic:

[ ] Precision Loss: Is there a loss of precision when calculating rewards per token? (It is important to use sufficient precision, such as 1e18).

[ ] Rounding Direction: In whose favor are the rewards rounded when dividing? (Usually in favor of the protocol, to avoid "dust attacks").

[ ] Liquidity Math:

[ ] Slippage & Price Impact: Is there protection against price manipulation when entering or exiting a position?

[ ] Oracle Staleness: Is it verified that the oracle data is not stale (e.g., by checking `updatedAt` in Chainlink)?

[ ] Administrative Misuse:

[ ] Can an admin alter parameters (e.g., the commission rate) in a way that leads to a catastrophic devaluation of users' positions?
