# 📘 Case Study: Recent DeFi Protocol Hacks (2024–2026)

## 1. 🔥 Aurora Finance (June 2026)

- **Network**: Avalanche
- **Stolen**: $14.2 million (AVAX, USDC, wETH)
- **Vulnerability Type**: Reentrancy + Oracle Manipulation + Mock Mode in Production
- **How ​​It Happened**:
1. The `AuroraOracleV3` contract retained `mockMode = true`.
2. The attacker created a malicious token with a reentrancy function.
3. A call to `swapAndRepay` resulted in a callback that set a fake price via `setMockPrice`.
4. This fake price was then used to borrow huge sums.
- **Lessons**:
- Check your CI/CD configuration.
- Don't place `setPrice` in the same contract where financial transactions occur.
- Use the `nonReentrant` guard for all external calls.
---

## 2. ⚖️ Morpho (April 2024)

- **Network**: Ethereum
- **Stolen**: $23 million
- **Vulnerability type**: Permissionless pool creation + price oracle bypass
- **How ​​it happened**:
1. Any user could create a `pool` via `createPool(asset, oracle)`.
2. The attacker deployed a `MockOracle` with an inflated price.
3. Created a pool with this oracle and took out a loan secured by the fake price.
- **Lessons**:
- Whitelisting oracles is mandatory.
- Add "brakes": stake, verification, time limit for new pools.
- Permissionless doesn't mean unlimited.
---

## 3. 🌪️ Radiant Capital (March 2025)

- **Network**: Ethereum + Polygon
- **Stolen**: $89 million
- **Vulnerability type**: Cross-chain sync logic error
- **How ​​it happened**:
1. The `withdraw()` function on Polygon triggered an event, but the L1 balance was updated with a delay.
2. The attacker used `repay()` on L1 before the balance was updated, borrowing "irrevocable" collateral.
- **Lessons**:
- Cross-chain operations must be atomic or have a `pending` status.
- Parallel operations between L1/L2 must be blocked.
- Check balance synchronization.
