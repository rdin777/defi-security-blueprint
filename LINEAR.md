⚠️ LINEAR Protocol — Rounding-Based Share Inflation (June 2026, *Out of Scope for HackerProof*)

- **Platform**: HackerProof (for LINEAR Protocol)
- **Report**: `LINEAR-405`
- **Substance**: A vulnerability in `internal_stake` due to `num_shares_from_staked_amount_rounded_down` leads to share inflation during microstakes (e.g., 1 yoctoNEAR → 1 share, although the actual payment is 0).
- **Vulnerability Type**: Arithmetic Rounding Flaw (`dup-32` family)
- **Status**: Closed as *Out of Scope* by program policy (`dup-32` vulnerabilities are excluded).
- **Lessons**:
- Even technically correct vulnerabilities may not receive a bounty if they fall under the "excluded categories" in the program policy.
- Always carefully review the **Scope** and **Exclusions** of the bounty program before submitting a report.
- However, such issues represent **architectural risks** that teams should consider as *defense-in-depth* improvements, even if they are not considered bounty-valid.
