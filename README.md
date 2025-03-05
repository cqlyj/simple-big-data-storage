# Simple Big Data Storage NFT Demo

The demo loosely implements an NFT which can be minted with a user-provided image that's stored permanently on-chain. The `mint()` function will trigger code storage of a base64-encoded PNG image. `tokenURI()` will later read the code data at the deployed address and will embed the image in the URI using [RFC3986](https://www.rfc-editor.org/rfc/rfc3986) semantics.

## Use Case

When contracts need to store arbitrary data they will usually declare a `bytes` or `string` storage variable and write to it. This uses contract storage, which is straightforward and intuitive but can become prohibitively expensive for larger data. Contract storage is slot-based, charging 20k gas per word (32 bytes) of data to initialize for the first time. To store 256 bytes this way would cost 160k gas.

But if you **don't need the ability to change the data**, there's a cheaper on-chain location to store arbitrary data that contracts can still access. => `Contract Bytecode`

## Contract Bytecode

The bytecode for a contract also lives on-chain, in a separate code storage location. This location is intended to hold the contract's executable bytecode, along with any compile-time `constants` and `immutable` variables. But there is a way to store arbitrary data in this code storage location as well.

Unlike normal contract storage, data in code storage can only be set **once**, during contract initialization/creation. It is also limited to ~24KB. However, gas costs can be much lower when storing large data (several words). The cost to initialize data in code storage is a more complex formula and depends on your exact implementation, but you can roughly approximate it with:

```bash
total_cost = 32k + mem_expansion_cost + code_deposit_cost
mem_expansion_cost = size * 3 + (size ** 2) / 512
code_deposit_cost = 200 * size
```

So, to store 256 bytes of data in contract bytecode would cost only `84k`, compared to the `160k` for conventional contract storage, which is almost half the cost! The savings go up as the size of the data increases.

## How It Works

During contract deployment, the constructor runs first. The constructor is part of a contract's initialization process, often setting up state variables. But what solidity abstracts away from you is that after the constructor runs, **it also returns data that will make up the contract's permanent bytecode.** This data is exactly what will get stored in the contract's code storage.

By dropping into assembly, you can preempt the compiler's built-in `return` to return whatever data you want stored in code storage.

```javascript
contract BigDataStore {
    constructor(bytes memory data) {
        // Store the data in the contract's code storage.
        assembly {
            return(
                add(data, 0x20), // start of return data
                mload(data) // size of return data
            )
        }
    }
}
```

Afterwards, if you tried to access the deployed address' code data, you would get back the arbitrary data stored there. So to access that data again, you just need to remember the deployed address.

```javascript
address(new BigDataStore(bytes("Hello, world"))).code; // bytes of "Hello, world"
```

## Preventing Accidental Execution

Even though the data you're storing in code storage with this method is probably not actual bytecode, the EVM can't tell the difference. So _any_ calls to the address will attempt to execute the data stored there as bytecode, starting with the first byte. It is possible that a sequence of starting arbitrary bytes is, intentionally or unintentionally, valid bytecode and could cause some meaningful interaction if executed. For example, if the data started with `33FF`, anyone could call the contract and it would self-destruct, taking the data with it. For this reason, it's a good idea to prefix the data with something that causes execution to halt. The `00` byte is a good candidate because it is also the `STOP` opcode, which ends execution immediately, but `FE` (`INVALID`) also works well.

But don't forget to discard this prefix when reading the data back later!

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.3.0 (5a8bd89 2024-12-19T17:17:10.245193696Z)`

## Quickstart

```
git clone https://github.com/cqlyj/simple-big-data-storage
cd simple-big-data-storage
make
```

# Usage

Simply run `forge test --mt testBigNftSavesGas -vvvv` to check how much gas you saved by storing data in contract bytecode.

## Contact

Luo Yingjie - [luoyingjie0721@gmail.com](luoyingjie0721@gmail.com)
