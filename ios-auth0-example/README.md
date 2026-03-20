# MetaMask Embedded Wallets — iOS Auth0 Custom Connection Example

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

Demonstrates integrating MetaMask Embedded Wallets (formerly Web3Auth) on iOS with **Auth0 as a custom authentication provider**. Users log in via Auth0 (which can front any identity provider — SAML, LDAP, social, enterprise SSO), and the resulting JWT is passed to the SDK to reconstruct their non-custodial wallet.

## What This Example Covers

- Creating a **custom connection** (formerly "custom verifier") on the Web3Auth dashboard for Auth0
- Passing a JWT from Auth0 to `W3ALoginParams` to authenticate with the SDK
- Configuring `loginConfig` with `TypeOfLogin.jwt` for JWT-based connections
- White-labelling the SDK UI
- MFA settings (device share, backup share, social backup, passkey, authenticator)
- Session management (custom session duration)

## How Custom Auth Works

1. User taps **Login with Auth0**.
2. Auth0 authenticates the user and returns an ID token (JWT).
3. The JWT is passed to `web3Auth.login(W3ALoginParams(loginProvider: .JWT, ...))`.
4. The SDK validates the JWT against your configured connection (JWKS endpoint) and reconstructs the user's private key.

The private key is always the same for the same user + same connection + same Client ID + same network.

## Prerequisites

- Xcode 14+
- iOS 14.0+ deployment target
- A **Web3Auth Client ID** from [dashboard.web3auth.io](https://dashboard.web3auth.io)
- An **Auth0 application** (Native type) with your bundle ID in the Allowed Callback URLs
- A **custom connection** configured on the Web3Auth dashboard for Auth0

### Setting Up the Custom Connection

1. On the dashboard, go to **Connections → Custom** and create a new connection.
2. Set the **Auth Connection ID** (e.g. `w3a-auth0-demo`).
3. Set the **JWKS endpoint** to `https://<your-auth0-domain>/.well-known/jwks.json`.
4. Set the **user ID field** to `sub` (default for Auth0).
5. Copy the connection ID — you'll use it as the `verifier` in `loginConfig`.

## Installation

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-auth0-example
open ios-auth0-example.xcodeproj
```

Uses **Swift Package Manager** — no CocoaPods needed. Dependencies (Web3Auth, Auth0.swift, web3.swift) resolve automatically.

## Configuration

Open `ViewModel.swift` and set your credentials:

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
            redirectUrl: "web3auth.ios-auth0-example://auth",
            loginConfig: [
                TypeOfLogin.jwt.rawValue: .init(
                    verifier: "YOUR_AUTH0_CONNECTION_ID", // custom connection ID from dashboard
                    typeOfLogin: .jwt,
                    clientId: "YOUR_AUTH0_CLIENT_ID"
                )
            ],
            whiteLabel: W3AWhiteLabelData(
                appName: "My App",
                defaultLanguage: .en,
                mode: .dark,
                theme: ["primary": "#d53f8c"]
            ),
            mfaSettings: MfaSettings(
                deviceShareFactor: MfaSetting(enable: true, priority: 1),
                backUpShareFactor: MfaSetting(enable: true, priority: 2),
                socialBackupFactor: MfaSetting(enable: true, priority: 3),
                passwordFactor: MfaSetting(enable: true, priority: 4),
                passkeysFactor: MfaSetting(enable: true, priority: 5),
                authenticatorFactor: MfaSetting(enable: true, priority: 6)
            ),
            sessionTime: 259200 // 3 days (default: 1 day)
        ))
    }
}
```

## Login Flow

```swift
func loginWithAuth0() {
    Task {
        let result = try await web3Auth?.login(
            W3ALoginParams(
                loginProvider: .JWT,
                extraLoginOptions: ExtraLoginOptions(
                    domain: "https://YOUR_AUTH0_DOMAIN",
                    verifierIdField: "sub"
                ),
                mfaLevel: .NONE,
                curve: .SECP256K1
            )
        )
        // result.privKey  → hex private key
        // result.userInfo → name, email, profile image, typeOfLogin
    }
}
```

The SDK opens the Auth0 login page in an in-app browser. Once Auth0 redirects back, the JWT is automatically handled and the private key is reconstructed.

## Project Structure

```
ios-auth0-example/
├── ios-auth0-example.xcodeproj
└── ios-auth0-example/
    ├── ContentView.swift         # Root navigation
    ├── LoginView.swift           # Auth0 login button
    ├── UserDetailView.swift      # Post-login user info + blockchain actions
    ├── ViewModel.swift           # Web3Auth init, login, logout
    ├── TorusWeb3Utils.swift      # EVM utility helpers
    └── web3RPC.swift             # Ethereum interactions via web3.swift
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Auth0 Custom Connection Guide](https://docs.metamask.io/embedded-wallets/authentication/custom-connections/auth0/)
- [Custom Connections Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [Dashboard](https://dashboard.web3auth.io)
- [Auth0 iOS Quickstart](https://auth0.com/docs/quickstart/native/ios-swift)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)

## License

MIT — see [LICENSE](../LICENSE) for details.
