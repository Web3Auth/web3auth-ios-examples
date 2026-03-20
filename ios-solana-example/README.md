# MetaMask Embedded Wallets — iOS Solana Example

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

Demonstrates integrating MetaMask Embedded Wallets (formerly Web3Auth) on iOS with the **Solana blockchain**. The user authenticates with social login, and the resulting ed25519 private key is used to create a Solana account and interact with the network.

## What This Example Covers

- Social login on iOS using the Web3Auth PnP SDK
- Requesting an **ed25519 key** (Solana curve) via `SUPPORTED_KEY_CURVES.ED25519`
- Creating a Solana account from the exported private key using `solana-swift`
- Fetching SOL balance
- Sending SOL transfers
- Querying SPL token balances

## How the Private Key Works on Solana

The iOS SDK does not have a built-in Solana provider. After login, you export the private key and use it with a Swift-native Solana library:

```swift
// Request ed25519 key at login
let result = try await web3Auth?.login(
    W3ALoginParams(
        loginProvider: .GOOGLE,
        curve: .ED25519  // <-- Solana curve
    )
)
let privateKeyHex = result?.ed25519PrivKey ?? ""
```

The `ed25519PrivKey` field is the Solana-compatible private key. The `privKey` field (secp256k1) is the EVM key — do not use it for Solana.

## Prerequisites

- Xcode 14+
- iOS 14.0+ deployment target
- A **Web3Auth Client ID** from [dashboard.web3auth.io](https://dashboard.web3auth.io) with your bundle ID allowlisted
- Basic familiarity with Solana concepts (accounts, lamports, RPC endpoints)

## Installation

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-solana-example
open ios-solana-example.xcodeproj
```

Uses **Swift Package Manager** — Web3Auth and `solana-swift` are resolved automatically.

## Configuration

Open the ViewModel and set your Client ID and redirect URL:

```swift
import Web3Auth

// Initialise with Sapphire Mainnet
web3Auth = try await Web3Auth(W3AInitParams(
    clientId: "YOUR_CLIENT_ID",
    network: .sapphire_mainnet,
    redirectUrl: "web3auth.ios-solana-example://auth"
))
```

Set up a URL scheme in **Target → Info → URL Types** to match the `redirectUrl`.

## Key Operations

### Create a Solana Account

```swift
import Solana

func createSolanaAccount(privateKeyHex: String) throws -> Account {
    let keyData = Data(hex: privateKeyHex)
    let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: keyData)
    return Account(
        phrase: [],
        publicKey: PublicKey(data: Data(keyPair.publicKey))!,
        secretKey: Data(keyPair.secretKey)
    )
}
```

### Fetch SOL Balance

```swift
func getBalance(publicKey: PublicKey) async throws -> UInt64 {
    let result = try await solana.api.getBalance(account: publicKey.base58EncodedString)
    return result
}
```

### Send SOL

```swift
func sendSOL(to recipient: String, amount: UInt64, signer: Account) async throws -> String {
    let signature = try await solana.action.sendSOL(
        to: PublicKey(string: recipient)!,
        amount: amount,
        from: signer
    )
    return signature
}
```

## Project Structure

```
ios-solana-example/
├── ios-solana-example.xcodeproj
└── ios-solana-example/
    ├── ios_solana_exampleApp.swift   # App entry point, URL handling
    ├── Helpers/                       # Solana RPC helpers, key utilities
    ├── ViewModels/                    # Web3Auth init, login, logout, Solana logic
    └── Views/                         # Login UI, user info, Solana operations UI
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Authentication Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [solana-swift](https://github.com/metaplex-foundation/solana-swift)
- [Solana Documentation](https://docs.solana.com)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)

## License

MIT — see [LICENSE](../LICENSE) for details.
