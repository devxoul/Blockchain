# Blockchain

A blockchain simulator written in Swift. It simulates full nodes in a virtual network. The nodes mine blocks for about every 10 seconds and verify randomly created transactions.

⚠️ This project is not an actual blockchain implementation. I am very new to the blockchain and the purpose of this repository is to share what I've learned. Note that there might be a lot of wrong implementations.

## Getting Started

```console
$ git clone https://github.com/devxoul/Blockchain.git
$ cd Blockchain
$ swift run
```

Then you'll see:

```
Run server: Blockchain.Node on address 1.1.1.1
Run server: Blockchain.Node on address 2.2.2.2
Run server: Blockchain.Node on address 3.3.3.3
[Node@2.2.2.2] Connect node 1.1.1.1
[Node@3.3.3.3] Connect node 1.1.1.1
[Node@1.1.1.1] Connect node 2.2.2.2
[Node@3.3.3.3] Connect node 2.2.2.2
[Node@2.2.2.2] Connect node 3.3.3.3
[Node@1.1.1.1] Connect node 3.3.3.3
[Node@2.2.2.2] Create transaction: <Transaction (89.0) 7695f853dccd7c29 -> ed99e0099751256d>
[Node@1.1.1.1] Create transaction: <Transaction (89.0) 7695f853dccd7c29 -> ed99e0099751256d>
[Node@3.3.3.3] Create transaction: <Transaction (89.0) 7695f853dccd7c29 -> ed99e0099751256d>
[Node@3.3.3.3] Create transaction: <Transaction (5.0) 7695f853dccd7c29 -> 715e3b2f5d0dea50>
[Node@1.1.1.1] Create transaction: <Transaction (5.0) 7695f853dccd7c29 -> 715e3b2f5d0dea50>
[Node@2.2.2.2] Create transaction: <Transaction (5.0) 7695f853dccd7c29 -> 715e3b2f5d0dea50>
[Node@3.3.3.3] Submit block: <Block height=1 bits=E600FFFF nonce=1159 transactions=2>
[Node@2.2.2.2] Submit block: <Block height=1 bits=E600FFFF nonce=1159 transactions=2>
[Node@1.1.1.1] Submit block: <Block height=1 bits=E600FFFF nonce=1159 transactions=2>
[Node@1.1.1.1] Submit block: <Block height=1 bits=E600FFFF nonce=1159 transactions=2>
[Node@1.1.1.1] Create transaction: <Transaction (2.0) 8a7b4aa02b4169d3 -> e341e6db66aff49d>
[Node@2.2.2.2] Create transaction: <Transaction (2.0) 8a7b4aa02b4169d3 -> e341e6db66aff49d>
[Node@3.3.3.3] Create transaction: <Transaction (2.0) 8a7b4aa02b4169d3 -> e341e6db66aff49d>
[Node@3.3.3.3] Submit block: <Block height=2 bits=E600FFFF nonce=162 transactions=1>
[Node@2.2.2.2] Submit block: <Block height=2 bits=E600FFFF nonce=162 transactions=1>
[Node@1.1.1.1] Submit block: <Block height=2 bits=E600FFFF nonce=162 transactions=1>
[Node@1.1.1.1] Submit block: <Block height=2 bits=E600FFFF nonce=162 transactions=1>
```

## Development

```console
$ swift package generate-xcodeproj
```

## License

Blockchain is under MIT license. See the [LICENSE](LICENSE) file for more info.
