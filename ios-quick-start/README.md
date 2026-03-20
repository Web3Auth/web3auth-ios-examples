# MetaMask Embedded Wallets — iOS Quick Start

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

The simplest integration of MetaMask Embedded Wallets (formerly Web3Auth) on iOS. Users log in with social providers (Google, Apple, Discord, etc.) and get a self-custodied Ethereum wallet — no seed phrase, no external app.

## What This Example Covers

- Initialising the Web3Auth iOS SDK with Sapphire Mainnet
- Social login (Google, Apple, Discord, Email passwordless, and more)
- Fetching the user's private key and deriving an Ethereum address
- Signing messages and sending transactions with `web3.swift`
- Logout and session restoration across app launches

## Prerequisites

- Xcode 14+
- iOS 14.0+ deployment target
- Swift 5.7+
- A Client ID from [dashboard.web3auth.io](https://dashboard.web3auth.io)

> **Important:** After creating a project on the dashboard, go to **Allowlist** and add your app's bundle identifier (e.g. `com.example.myapp`). Without this, logins will be rejected.

## Installation

Clone this repository and open the Xcode project directly — it uses **Swift Package Manager**. Dependencies resolve automatically.

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-quick-start
open ios-example.xcodeproj
```

## Configuration

### 1. Set up a URL scheme

Add a URL scheme in Xcode under **Target → Info → URL Types**. Use the format `$(PRODUCT_BUNDLE_IDENTIFIER)` or a custom string (e.g. `web3auth.ios-example`). This is the `redirectUrl` you pass to the SDK.

### 2. Register the URL scheme on the dashboard

In your dashboard project, go to **iOS** under **Allowlist** and add the same scheme + bundle identifier.

### 3. Add your Client ID

Open `ViewModel.swift` and replace the `clientId` with your own:

```swift
import Web3Auth

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    private var clientId = "YOUR_CLIENT_ID"
    private var network: Network = .sapphire_mainnet

    func setup() async {
        web3Auth = try await Web3Auth(W3AInitParams(
            clientId: clientId,
            network: network,
            redirectUrl: "web3auth.ios-example://auth"
        ))
    }
}
```

Use `.sapphire_devnet` while testing locally, and switch to `.sapphire_mainnet` for production. **Never switch the network in production** — it permanently changes all user wallet addresses.

## Logging In

```swift
func login(provider: Web3AuthProvider) {
    Task {
        let result = try await web3Auth?.login(
            W3ALoginParams(loginProvider: provider)
        )
        // result.privKey  → hex private key (secp256k1)
        // result.userInfo → name, email, profile image
    }
}
```

After login, the private key is available via `result.privKey`. Pass it to `web3.swift` (or any Swift EVM library) to sign transactions and interact with any EVM chain.

## Logging Out

```swift
try await web3Auth?.logout()
```

Sessions are cached by default. On the next cold start, `web3Auth.state` is non-nil if the session is still valid — no login prompt is shown.

## Project Structure

```
ios-quick-start/
├── ios-example.xcodeproj
└── ios-example/
    ├── ContentView.swift      # Root view, navigation
    ├── LoginView.swift        # Social login button UI
    ├── UserDetailView.swift   # Post-login user info + blockchain actions
    ├── ViewModel.swift        # Web3Auth init, login, logout logic
    └── web3RPC.swift          # EVM interactions via web3.swift
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Authentication Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-ios-examples/issues)

## License

MIT — see [LICENSE](../LICENSE) for details.
