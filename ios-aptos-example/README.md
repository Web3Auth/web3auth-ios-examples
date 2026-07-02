# MetaMask Embedded Wallets — iOS Aptos Example

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

Demonstrates integrating MetaMask Embedded Wallets (formerly Web3Auth) on iOS with the **Aptos blockchain**. The user authenticates with social login, and the resulting ed25519 private key is used to create an Aptos account and interact with the network.

## What This Example Covers

- Social login on iOS using the Web3Auth PnP SDK
- Requesting an **ed25519 key** (Aptos curve) via `SUPPORTED_KEY_CURVES.ED25519`
- Creating an Aptos account from the exported private key
- Fetching APT balance
- Sending APT transfers
- Executing Move module functions

## How the Private Key Works on Aptos

The iOS SDK does not have a built-in Aptos provider. After login, you export the private key and use it with a Swift-native Aptos library:

```swift
// Request ed25519 key at login
let result = try await web3Auth?.connectTo(
    loginParams: LoginParams(
        authConnection: .EMAIL_PASSWORDLESS,
        loginHint: "user@example.com",
        curve: .ED25519
    )
)
let privateKeyHex = result?.ed25519PrivateKey ?? ""
```

The `ed25519PrivateKey` field is the Aptos-compatible private key. The `privateKey` field (secp256k1) is the EVM key — do not use it for Aptos.

## Prerequisites

- Xcode 14+
- iOS 16.0+ deployment target (SDK minimum is iOS 14.0)
- A **Web3Auth Client ID** from [dashboard.web3auth.io](https://dashboard.web3auth.io) with your bundle ID allowlisted
- Basic familiarity with Aptos concepts (accounts, Move modules, gas)

## Installation

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-aptos-example
open ios-aptos-example.xcodeproj
```

Uses **Swift Package Manager** — Web3Auth and the Aptos Swift SDK are resolved automatically.

## Configuration

Open the ViewModel and set your Client ID and redirect URL:

```swift
import Web3Auth

web3Auth = try await Web3Auth(
    options: Web3AuthOptions(
        clientId: "YOUR_CLIENT_ID",
        web3AuthNetwork: .SAPPHIRE_MAINNET,
        redirectUrl: "com.w3a.ios-aptos-example://auth"
    )
)
```

Set up a URL scheme in **Target → Info → URL Types** to match the `redirectUrl`.

## Key Operations

### Create an Aptos Account

```swift
func createAptosAccount(privateKeyHex: String) throws -> AptosAccount {
    let keyData = Data(hex: privateKeyHex)
    return try AptosAccount(privateKey: keyData)
}
```

### Fetch APT Balance

```swift
func getBalance(address: String) async throws -> UInt64 {
    let resource = try await aptosClient.getAccountResource(
        address: address,
        resourceType: "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
    )
    return resource.data.coin.value
}
```

### Send APT

```swift
func sendAPT(to recipient: String, amount: UInt64, signer: AptosAccount) async throws -> String {
    let payload = TransferPayload(recipient: recipient, amount: amount)
    let txHash = try await aptosClient.transfer(
        sender: signer,
        payload: payload
    )
    return txHash
}
```

### Execute a Move Function

```swift
func executeMoveFunction(
    moduleAddress: String,
    moduleName: String,
    functionName: String,
    args: [Any],
    signer: AptosAccount
) async throws -> String {
    let payload = EntryFunctionPayload(
        function: "\(moduleAddress)::\(moduleName)::\(functionName)",
        typeArguments: [],
        arguments: args
    )
    return try await aptosClient.submitTransaction(sender: signer, payload: payload)
}
```

## Project Structure

```
ios-aptos-example/
├── ios-aptos-example.xcodeproj
└── ios-aptos-example/
    ├── ios_aptos_exampleApp.swift   # App entry point, URL handling
    ├── Helper/                       # Aptos RPC helpers, key utilities
    ├── ViewModels/                   # Web3Auth init, login, logout, Aptos logic
    └── Views/                        # Login UI, user info, Aptos operations UI
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Authentication Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [Aptos Swift SDK](https://github.com/ALCOVE-LAB/aptos-swift-sdk)
- [Aptos Documentation](https://aptos.dev)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)

## License

MIT — see [LICENSE](../LICENSE) for details.
