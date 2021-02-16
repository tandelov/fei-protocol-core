---
description: "The guardian to halt Fei Protocol functionality in a crisis\U0001F6E1"
---

# Fei Guardian

The Fei Guardian is the single address to be granted the Guardian🛡role at Genesis. This will be initially held by the Fei Core Team in a multi-sig, with the intention of either renouncing the role or transitioning to a community held multi-sig within a few months of launch.

The rational behind having a Guardian is that there can be issues in the protocol which are time sensitive. The minimum 3 day window between proposal and execution for a fix coming through the [Fei DAO](fei-dao.md) is not fast enough. For instance if there is a bug in the incentive calculation where an attacker can systematically make a profit, this functionality should be shut down as quickly as possible. The Guardian would step in and revoke the Minter💰role from the [UniswapIncentive](../protocol/fei-stablecoin/uniswapincentive.md) contract.

The Guardian can only revoke or pause functionality, with the additional ability to force a reweight.

{% hint style="info" %}
The Governor⚖️ can revoke the Guardian🛡ability at any time
{% endhint %}

## Responsibilities

* revoke any role from any contract, except Governor⚖️
* toggle oracle kill switch
* force a reweight
* toggle allowlisted addresses from transferring to the ETH/FEI pair
* toggle staking rewards dripping
