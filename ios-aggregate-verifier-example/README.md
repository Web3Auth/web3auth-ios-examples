# MetaMask Embedded Wallets — iOS Grouped Connection (Aggregate Verifier) Example

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

Demonstrates how to use **grouped connections** (formerly "aggregate verifiers") with MetaMask Embedded Wallets on iOS. A grouped connection links multiple login providers under a single connection so the same user always gets the **same wallet address** regardless of which provider they use to sign in.

In this example, a user can log in with **Google** or **GitHub (via Auth0)** and both paths resolve to the same wallet.

## What This Example Covers

- Configuring a **grouped connection** on the Web3Auth dashboard
- Setting up `loginConfig` with multiple sub-connections (sub-verifiers) pointing to the same aggregate connection
- Logging in via Google (native OAuth) and GitHub (via Auth0 JWT)
- Understanding how grouped connections ensure address consistency across providers

## Why Grouped Connections Matter

Without a grouped connection, `Google login` and `GitHub login` produce **different wallet addresses** for the same user — because each connection independently derives the key. A grouped connection solves this by combining multiple identity sources into one deterministic key derivation.

Use this whenever users might sign in via different providers but you want one consistent wallet.

> For more on how this works: [Grouped Connections Documentation](https://docs.metamask.io/embedded-wallets/authentication/group-connections/)

## Prerequisites

- Xcode 14+
- iOS 14.0+ deployment target
- A **Web3Auth Client ID** from [dashboard.web3auth.io](https://dashboard.web3auth.io)
- A **grouped connection** configured on the dashboard with at least two sub-connections

### Setting Up the Grouped Connection on the Dashboard

1. Go to **Connections → Grouped** and create a new grouped connection.
2. Add sub-connections: e.g. a Google sub-connection and a GitHub (via Auth0 JWT) sub-connection.
3. Each sub-connection gets its own **Auth Connection ID** (sub-verifier ID).
4. The **grouped connection ID** is what you set as `verifier` in `loginConfig`.

## Installation

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-aggregate-verifier-example
open ios-aggregate-example.xcodeproj
```

Uses **Swift Package Manager** — dependencies resolve automatically.

## Configuration

Open `ViewModel.swift` and set your credentials. The key part is `loginConfig`, which maps each provider to the same parent `verifier` (grouped connection ID) while specifying a unique `verifierSubIdentifier` per sub-connection:

```swift
import Web3Auth

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    private var clientId = "YOUR_WEB3AUTH_CLIENT_ID"
    private var network: Network = .sapphire_mainnet

    func setup() async throws {
        web3Auth = try await Web3Auth(W3AInitParams(
            clientId: clientId,
            network: network,
            redirectUrl: "web3auth.ios-aggregate-example://auth",
            loginConfig: [
                TypeOfLogin.google.rawValue: .init(
                    verifier: "YOUR_GROUPED_CONNECTION_ID",  // the parent grouped connection ID
                    typeOfLogin: .google,
                    name: "Google Login",
                    clientId: "YOUR_GOOGLE_CLIENT_ID",
                    verifierSubIdentifier: "YOUR_GOOGLE_SUB_CONNECTION_ID"
                ),
                TypeOfLogin.jwt.rawValue: .init(
                    verifier: "YOUR_GROUPED_CONNECTION_ID",  // same parent ID
                    typeOfLogin: .jwt,
                    name: "GitHub Login",
                    clientId: "YOUR_AUTH0_CLIENT_ID",
                    verifierSubIdentifier: "YOUR_GITHUB_SUB_CONNECTION_ID"
                )
            ],
            sessionTime: 259200 // 3 days
        ))
    }
}
```

## Login Flow

**Google:**
```swift
func loginWithGoogle() {
    Task {
        let result = try await web3Auth?.login(
            W3ALoginParams(loginProvider: .GOOGLE)
        )
        // result.privKey → same key regardless of which provider was used
    }
}
```

**GitHub via Auth0:**
```swift
func loginWithGitHub() {
    Task {
        let result = try await web3Auth?.login(
            W3ALoginParams(
                loginProvider: .JWT,
                extraLoginOptions: ExtraLoginOptions(
                    connection: "github",
                    domain: "https://YOUR_AUTH0_DOMAIN",
                    verifierIdField: "email",
                    isVerifierIdCaseSensitive: false
                )
            )
        )
    }
}
```

## Project Structure

```
ios-aggregate-verifier-example/
├── ios-aggregate-example.xcodeproj
└── ios-aggregate-example/
    ├── ContentView.swift         # Root navigation
    ├── LoginView.swift           # Google + GitHub login buttons
    ├── UserDetailView.swift      # Post-login user info + blockchain actions
    ├── ViewModel.swift           # Web3Auth init, login, logout
    ├── TorusWeb3Utils.swift      # EVM utility helpers
    └── web3RPC.swift             # Ethereum interactions via web3.swift
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Grouped Connections Guide](https://docs.metamask.io/embedded-wallets/authentication/group-connections/)
- [Authentication Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)

## License

MIT — see [LICENSE](../LICENSE) for details.
