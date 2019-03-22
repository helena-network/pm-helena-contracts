[![Solidity version](https://img.shields.io/badge/dynamic/json.svg?style=flat-square&maxAge=3600&label=Solidity&url=https%3A%2F%2Fraw.githubusercontent.com%2F0xjac%2FERC777%2Fmaster%2Fpackage-lock.json&query=%24.dependencies.solc.version&colorB=ff69b4&prefix=v)](https://solidity.readthedocs.io/en/v0.4.21/installing-solidity.html)
[![logo](https://img.shields.io/badge/-logo-C99D66.svg?style=flat-square&maxAge=3600&colorA=grey&logo=data:image/svg+xml;utf8,%253Csvg%2520xmlns='http://www.w3.org/2000/svg'%2520viewBox='0%25200%2520595.3%2520841.9'%253E%253Cpath%2520d='M410.1%2520329.9c20%25200%252039.1.1%252058.3-.1%25204.2%25200%25205.6.4%25204.8%25205.3-2.5%252014.1-4.4%252028.3-6.3%252042.5-.5%25203.6-2%25204.5-5.5%25204.5-28.3-.1-56.7%25200-85-.2-4%25200-6.2%25201.3-8.3%25204.6-9.6%252014.8-18.6%252030-26.7%252045.6-.5%25201-.9%25202.1-1.6%25203.7h5.9c35.5%25200%252071%2520.1%2520106.5-.1%25204.5%25200%25206.3.2%25205.3%25205.8-2.7%252014.2-4.6%252028.6-6.4%252043-.6%25204.4-2.1%25205.6-6.6%25205.6-41.2-.2-82.3-.1-123.5-.2-3.6%25200-5.1%25201.1-6.2%25204.5-13.7%252038.9-22.8%252078.9-28.7%2520119.6-2.8%252019.1-5.9%252038.2-8.6%252057.3-.5%25203.4-1.8%25203.8-4.7%25203.8-31.8-.1-63.7%25200-95.5-.1-1.5%25200-4.1%25201.4-3.5-2.6%25207.5-48.5%252013-97.3%252027.4-144.5%25203.8-12.5%25208-24.9%252012.8-37.9h-21.8c-14.7%25200-29.3-.2-44%2520.1-4.1.1-4.6-1.3-4.1-4.9%25202.5-15.4%25204.9-30.9%25207-46.4.5-3.4%25202.3-3%25204.5-3h79c2.2%25200%25204.1%25200%25205.4-2.5%25209.2-17.5%252020-34.1%252031.5-51.4h-5.8c-33.7%25200-67.3-.1-101%2520.1-4.4%25200-5.3-1.2-4.6-5.2%25202.3-14%25204.6-27.9%25206.3-42%2520.6-4.6%25202.5-5%25206.4-5%252044.2.1%252088.3%25200%2520132.5.2%25203.7%25200%25206-1.1%25208.3-4%252023.2-28.6%252048.2-55.6%252074.4-81.6%25201.2-1.2%25202.9-2%25204.4-3-.3-.5-.7-1-1-1.5h-5.3c-83.5%25200-167%25200-250.5.1-3.9%25200-5.7.1-4.8-5.2%25203.8-23.5%25207.1-47.1%252010.3-70.6.5-4.1%25202.5-4.1%25205.7-4.1%252082.3.1%2520164.7%25200%2520247%25200%252035.2%25200%252070.3.1%2520105.5-.1%25203.8%25200%25205%2520.5%25204.3%25204.8-3.7%252023.7-7.1%252047.4-10.4%252071.1-.4%25203-1.8%25205.2-3.9%25207.2-27.1%252026.8-53%252054.8-77.3%252084.3-.5.6-.9%25201.1-1.9%25202.5z'%2520fill='%2523fff'/%253E%253C/svg%253E)](logo)

# Helena Contracts


Contracts related to Helena Network competitions. Helena uses a sidechain infrastructure, where different instance of tokens are deployed (same as Dai/xDai)


The mainnet **P+** token can be found here:
  - Mainnet:
    - Address: [0xCFC64d8eAEB4E6a68860e415f55DFe9057dA7d2D]('https://etherscan.io/address/0xCFC64d8eAEB4E6a68860e415f55DFe9057dA7d2D#writeContract)
    - Creator: `0x629573ad5A234A921628bF6BFD545949CA8b6eEd`

This is the **xP+** token implementation:
  - xDai:
    - Address: [0x10a6ea9cfccb215a2f7126a9f8ce57c039680f1f]('https://blockscout.com/poa/dai/address/0x10a6ea9cfccb215a2f7126a9f8ce57c039680f1f/transactions')
    - Creator: `0x47e681cB751F80B9d5ac771Dfd4D0c7f85937289`


# Contracts Overview

## PlayToken

Beyond the bare minimum necessary to implement the ERC20 interface sanely, this contract also implements two other mechanics: issuing new tokens to addresses, and determining a whitelist for token transfers.

The ability to issue new tokens to addresses, or minting tokens, is restricted to the creator of the contract instance. This action can be performed with a call to the `issue` function, which takes an array of recipient addresses and credits them a newly minted amount of token. The token issuance may, for example, be tied into a registration process for an event.

The creator of the contract instance is also required to specify accounts which will be administrators of this contract. The creator and these administrators are, in turn, required to specify a whitelist for token transfers. This prevents arbitrary transfers of token value from one account to another. PlayTokens can be transferred only to or from the whitelisted addresses. You may use this mechanic to ensure that users can only perform transactions with the token on authorized contracts in an event.

## P+ Token

Same as the PlayToken, except the optional [ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) fields `name`, `symbol`, and `decimals` have also been specified.

## AddressRegistry

A registry of mainnet addresses for tournaments which run on a testnet like Rinkeby.

## RewardClaimHandler

A contract which stores rewards for winners, allowing them to claim the rewards by a deadline.

# Operations Overview

## Redeploying the Contracts

See [this deployment guide](https://gnosis.github.io/lil-box/deployment-guide.html). You will need to execute `npm run migrate -- --reset --network rinkeby` with the `--reset` flag.

## Designating Admins

Administrator accounts can whitelist addresses for token addresses, as discussed above in the [PlayToken](#playtoken) section. These administrator accounts may be designated during migration by supplying them comma-separated to an `--admins` option:

```js
npm run migrate -- --reset --network rinkeby --admins=<comma separated addresses>
```

They may also be provided after deployment by the deployer with the following script:

```sh
npm run add-admin -- --addresses=<comma separated addresses>
```

The deployer may also remove admins with the following script:

```sh
npm run remove-admin -- --addresses=<comma separated addresses>
```

## Transfer Whitelist Management

The deployer and administrators can use the following script to allow transfers on a set of provided addresses:

```sh
npm run allow-transfers -- --addresses=<comma separated addresses>
```

They can similarly revoke arbitrary transfer capabilities with the following:

```sh
npm run disallow-transfers -- --addresses=<comma separated addresses>
```

## Issue tokens

The deployer can use the following script to have each address in a list issued PlayToken:

```sh
npm run issue-tokens -- --amount <units of token> --to <comma separated addresses>
```

The `--amount` is expressed "in wei," or in the smallest units of the token. Thus, for most tokens, which have a `decimals` value of 18, one whole token would be expressed as `1e18` (scientific notation) of that token, e.g. `1e18 wei == 1 ether`.

## Burn tokens

In order to make possible bridges between networks, a burn function was created (only callable by admin), to be forwarded to the bridge:

```sh
npm run burn-tokens -- --amount <units of token> --to <comma separated addresses>
```

The `--amount` is expressed "in wei," or in the smallest units of the token. Thus, for most tokens, which have a `decimals` value of 18, one whole token would be expressed as `1e18` (scientific notation) of that token, e.g. `1e18 wei == 1 ether`.

## `--from` and `--network`

The `add-admin`, `remove-admin`, `allow-transfers`, `disallow-transfers`, and `issue-tokens` tokens also support `--from`, `--network`, and `--play-token-name` options (be sure to specify these after the first bare `--`).

The `--from <account>` specifies an account with which to do the transaction.

If you have deployments on multiple networks, you can specify the network you mean the script to interact with via the `--network <network name>` option.

Finally, if you have happened to rename the PlayToken from OlympiaToken to something else, you can specify that name via the `--play-token-name <new case-sensitive name>` option.
