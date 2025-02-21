# BitcoinKit.Swift

### Initialization

```swift
import HdWalletKit

let words = ["mnemonic", "phrase", "words"]
let passphrase: String = ""
        
let seed = Mnemonic.seed(mnemonic: words, passphrase: passphrase)!
```

Then you can pass a seed to initialize an instance of *BitcoinKit.Kit*

```swift
let bitcoinKit = try BitcoinKit.Kit(
        seed: seed,
        purpose: Purpose.bip84,
        walletId: "unique_wallet_id",
        syncMode: BitcoinCore.SyncMode.full,
        networkType: BitcoinKit.Kit.NetworkType.mainNet,
        confirmationsThreshold: 3,
        logger: nil
)
```


```swift
let extendedKey = try! HDExtendedKey(extendedKey: "xprvA1BgyAq84AiAsrMm6DKqwCXDwxLBXq76dpUfuNXNziGMzDxYLjE9AkuYBAQTpt6aJu4nFYamh6BbrRkys5fJcxGd7qixNrpVpPBxui9oYyF")

let bitcoinKit = try BitcoinKit.Kit(
    extendedKey: extendedKey,
    walletId: "unique_wallet_id",
    syncMode: BitcoinCore.SyncMode.full,
    networkType: BitcoinKit.Kit.NetworkType.mainNet,
    confirmationsThreshold: 3,
    logger: nil
)
```

If you restore with a public extended key, then you only will be able to watch the wallet. You won't be able to send any transactions. This is how the **watch account** feature is implemented.

### Starting and Stopping

*BitcoinKit.Kit* require to be started with `start` command. It will be in synced state as long as it is possible. You can call `stop` to stop it

```swift
bitcoinKit.start()
bitcoinKit.stop()
```

### Getting wallet data

#### Balance

Balance is provided in `Satoshis`:

```swift
let balance = bitcoinKit.balance

print(balance.spendable)
print(balance.unspendable)
```

Unspendable balance is non-zero if you have UTXO that is currently not spendable due to some custom unlock script. These custom scripts can be implemented as a plugin, like [Hodler](https://github.com/horizontalsystems/Hodler.Swift)

#### Last Block Info

```swift
let blockInfo = bitcoinKit.lastBlockInfo!

print(blockInfo.headerHash)
print(blockInfo.height)
print(blockInfo.timestamp)
```

#### Receive Address

Get an address which you can receive coins to. Receive address is changed each time after you actually get some coins in that address

```swift
bitcoinKit.receiveAddress()   // "mgv1KTzGZby57K5EngZVaPdPtphPmEWjiS"
```

#### Transactions

You can get your transactions using `transactions(fromUid: String? = nil, type: TransactionFilterType?, limit: Int? = nil)` method of the *BitcoinKit.Kit* instance. It returns *Single<[TransactionInfo]>*. You'll need to subscribe and get transactions asynchronously. See [RX Single Observers](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Traits.md#single) for more info.


```swift
let disposeBag = DisposeBag() // This must be retained

bitcoinKit.transactions(type: nil)
    .subscribe(
        onSuccess: { transactionInfos in
            for transactionInfo in transactionInfos {
                print("Hash: \(transactionInfo.uid)")
                print("Hash: \(transactionInfo.transactionHash)")
            }
        }
    )
    .disposed(by: disposeBag)
```

- `fromUid` and `limit` parameters can be used for pagination. 
- `type` parameter enables to filter transactions by coins flow. You can pass *incoming* OR *outgoing* to get filtered transations


#### TransactionInfo

A sample dump:

```swift
//    (BitcoinCore.TransactionInfo) {
//        uid = "CD2BCD61-49E1-419C-AFF2-E4FF5D28E375"
//        transactionHash = "e1ef748cf68a73a59cddad4dde1251d043eed7e3543907be6a635fba4522bc97"
//        transactionIndex = 1
//        inputs = 2 values {
//            [0] = (TransactionInputInfo) {
//                mine = true
//                address = "36k1UofZ2iP2NYax9znDCsksajfKeKLLMJ"
//                value = 69988
//            }
//            [1] = (TransactionInputInfo) {
//                mine = true
//                address = "3QYxvoQHKipha2H3U8yeNh5cfutZK8qBPb"
//                value = 5976
//            }
//        }
//        outputs = 2 values {
//            [0] = (TransactionOutputInfo) {
//                mine = true
//                changeOutput = true
//                value = 69217
//                address = "38Ckn9tueUqTB8oy7UBWe1Gzy6uJpLZNep"
//                pluginId = nil
//                pluginData = nil
//                pluginDataString = nil
//            }
//            [1] = (TransactionOutputInfo) {
//                mine = true
//                changeOutput = false
//                value = 5976
//                address = "3N5r5te5617JcBftWt34nTC9sJ7ofL3rmS"
//                pluginId = nil
//                pluginData = nil
//                pluginDataString = nil
//            }
//        }
//        amount = 5976
//        type = sentToSelf
//        fee = 771
//        blockHeight = 770158
//        timestamp = 1672742140
//        status = relayed
//        conflictingHash = nil
//    }
```

`uid`

A local unique ID

`type` 

- *incoming*
- *outgoing*
- *sentToSelf*

`status`

- *new* -> transaction is in mempool
- *relayed* -> transaction is in block
- *invalid* -> transaction is not included in block due to an error OR replaced by another one (RBF).


### Sending BTC


```swift
try! bitcoinKit.send(to: "36k1UofZ2iP2NYax9znDCsksajfKeKLLMJ", value: 100000000, feeRate: 10, sortType: .bip69)
```

This first validates a given address and amount, creates new transaction, then sends it over the peers network. If there's any error with given address/amount or network, it raises an exception.

#### Validate address

```swift
try bitcoinKit.validate(address: "mrjQyzbX9SiJxRC2mQhT4LvxFEmt9KEeRY")
```

#### Evaluate fee

```swift
try bitcoinKit.fee(to: "36k1UofZ2iP2NYax9znDCsksajfKeKLLMJ", value: 100000000, feeRate: 10, sortType: .bip69)
```


### Parsing BIP21 URI

You can use `parse` method to parse a BIP21 URI:

```swift
bitcoinKit.parse(paymentAddress: "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz")

// ▿ BitcoinPaymentData
//   - address : "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W"
//   - version : nil
//   ▿ amount : Optional<Double>
//     - some : 50.0
//   ▿ label : Optional<String>
//     - some : "Luke-Jr"
//   ▿ message : Optional<String>
//     - some : "Donation for project xyz"
//   - parameters : nil

```

### Subscribing to BitcoinKit data

Balance, transactions, last blocks synced and kit state are available in real-time. `BitcoinCoreDelegate` protocol must be implemented and set to *BitcoinKit.Kit* instance to receive that.

```swift
class Manager {
    let bitcoinKit: BitcoinKit.Kit
    
    init(kit: BitcoinKit.Kit) {
        bitcoinKit = kit
        bitcoinKit.delegate = self
    }
    
}

extension Manager: BitcoinCoreDelegate {
    
    func transactionsUpdated(inserted: [TransactionInfo], updated: [TransactionInfo]) {
    }
    
    func transactionsDeleted(hashes: [String]) {
    }
    
    private func balanceUpdated(balance: Int) {
    }
    
    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) {
    }
    
    public func kitStateUpdated(state: BitcoinCore.KitState) {
        // BitcoinCore.KitState can be one of 3 following states:
        //
        // synced
        // apiSyncing(transactions: Int)
        // syncing(progress: Double)
        // notSynced(error: Error)
        //
        // These states can be used to implement progress bar, etc
    }
    
}
```

## Prerequisites

* Xcode 10.0+
* Swift 5+
* iOS 13+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/curdicu/BitcoinKit.git", .upToNextMajor(from: "1.0.0"))
]
```

