# ✅ Checklist: Permissionless Protocol Audit (2026)

## 1. 🔐 **Access Control and Entity Creation**

| Item | Check | Note |
|-------|----------|------------|
| 1.1 | Who can create new pools/markets/tokens? | Should there be an `isAuthorizedCreator()` check or stake. |
| 1.2 | Are there limits on the number of entities per wallet? | Protection against spam creation. |
| 1.3 | Does entity creation require a deposit (stake)? | Stake as a guarantee of integrity. |
| 1.4 | A "voting" mechanism for the creation of new entities? | DAO governance as an additional layer. |
| 1.5 | Are pools/markets created only with whitelisted oracles? | MockOracle is prohibited. |
| 1.6 | Is there a cooling-off period before activating a new pool? | Allows you to track suspicious activity. |

## 2. 📊 **Oracles and Pricing**

| Item | Check | Note |
|-------|----------|-----------|
| 2.1 | Are all oracles validated (e.g., Chainlink, Python, RedStone)? | No `setPrice` in user-controlled contracts. |
| 2.2 | Is TWAP/median used for price smoothing? | Flash manipulation protection. |
| 2.3 | Do oracles check `roundId`, `updatedAt`? | Protection against stale/fake prices. |
| 2.4 | Does the new oracle pass a "health check"? | Test call response check. |
| 2.5 | Are there fallback oracles in case of primary failure? | DoS risk mitigation. |
| 2.6 | Does the LTV/liquidation ratio adapt to the oracle type? | Less reliable oracles have more conservative limits. |

## 3. 💰 **Financial Logic and Risks**

| Item | Check | Note |
|-------|----------|------------|
| 3.1 | Are `check-effects-interactions` used? | Prevent reentrancy. |
| 3.2 | Are all external calls protected by `nonReentrant`? | Especially `transferFrom`, `approve`. |
| 3.3 | Are interest rates/debts/collateral calculated correctly? | Especially with partial repayments. |
| 3.4 | Is there a `msg.sender == tx.origin` check if needed? | Bot protection. |
| 3.5 | Are commissions/fee-on-transfer tokens taken into account? | Otherwise, the balance may go into the negative. |
| 3.6 | Is `underflow/overflow` checked (e.g., with SafeMath)? | Deprecated, but still important in older solidity versions. |

## 4. 🌐 **Cross-chain and Sync**

| Item | Check | Note |
|-------|----------|-----------|
| 4.1 | Is an atomic cross-chain bridge used? | Or is there a `pending` status between the networks? |
| 4.2 | Are L1/L2 transactions blocked when `pending`? | Can't I withdraw to L2 and immediately return to L1? |
| 4.3 | Is the validator signature verified during sync? | Protection against forged messages. |
| 4.4 | Is a `nonce` used to prevent replay attacks? | Each transaction must be unique. |
| 4.5 | Is there a "timeout" for cross-chain messages? | If the validators don't confirm, the operation is canceled. |

## 5. 🧪 **Configuration and Environment**

| Item | Check | Note |
|-------|----------|-----------|
| 5.1 | Are all `mockMode`, `testMode`, and `devKeys` disabled in production? | Automate in CI/CD. |
| 5.2 | Are `require(env != 'production')` used for test functions? | Example: `setMockPrice`. |
| 5.3 | Are all admin keys stored in multisig? | Or better yet, in a DAO. |
| 5.4 | Is there an Emergency Pause at the protocol level? | For quick response. |
| 5.5 | Is `Ownable` used only in tests? | In production - only `TimelockController` or `Governor`. |

## 6. 📈 **Monitoring and Protection**

| Item | Check | Note |
|-------|----------|-----------|
| 6.1 | Are Guardian bots installed? | To monitor anomalous behavior. |
| 6.2 | Are metrics sent to Prometheus/CloudWatch? | Including: `totalSupply`, `borrowed`, `utilizationRate`. |
| 6.3 | Are there alerts for: sharp increase in TVL, unusual oracle, mass borrowing? | Via ChainEye, Tenderly, Blocknative. |
| 6.4 | Is Immunefi/HackerOne bounty used? | For external audit. |
| 6.5 | Is there an "insurance fund" or "safety module"? | For compensation in case of losses. |

## 7. 📄 **Documentation and Testing**

| Item | Check | Note |
|-------|----------|-----------|
| 7.1 | Are all functions covered by unit tests (Hardhat/Foundry)? | Including edge cases. |
| 7.2 | Are there fuzz tests (e.g., using echidna or foundry fuzzer)? | To find unexpected states. |
| 7.3 | Are integration tests performed between all modules? | Not just in isolation. |
| 7.4 | Are there adversarial tests (attacks in tests)? | For example, attack_reentrancy, oracle_manipulation_test. |
| 7.5 | Does the documentation accurately reflect the logic? | Especially for new permissionless features. |
