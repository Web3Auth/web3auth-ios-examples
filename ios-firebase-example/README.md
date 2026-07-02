# MetaMask Embedded Wallets — iOS Firebase Custom Connection Example

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

Demonstrates integrating MetaMask Embedded Wallets (formerly Web3Auth) on iOS with **Firebase as a custom authentication provider**. The user authenticates with Firebase (Email/Password in this example) and the resulting Firebase ID token is passed to the SDK to reconstruct their non-custodial wallet.

This is the most feature-rich example in the repo — it also demonstrates **Wallet Services** (in-app wallet UI for send/receive/swap), **MFA setup**, and the **`request` method** for signing via Wallet Services confirmation modal.

## What This Example Covers

- Creating a **custom connection** for Firebase on the Web3Auth dashboard
- Fetching a fresh Firebase ID token and passing it via `ExtraLoginOptions`
- Launching **Wallet Services** — an in-app webview wallet UI with send, receive, swap, and WalletConnect
- Enabling **MFA** after initial login (`enableMFA`)
- Signing messages via the **`request` method** (routes through Wallet Services confirmation modal)
- Session management with custom session duration

## How Custom Auth Works

1. User signs in with Firebase (`Auth.auth().signIn(...)`).
2. A fresh ID token is fetched via `getIDTokenResult(forcingRefresh: true)`.
3. The token is passed to `web3Auth.connectTo(loginParams: LoginParams(authConnection: .CUSTOM, idToken: token, ...))`.
4. The SDK validates the JWT against your configured connection (Firebase JWKS endpoint) and reconstructs the private key.

**Important:** The Firebase ID token must be fetched fresh on every login call — it expires quickly and the SDK enforces a 60-second `iat` window.

## Prerequisites

- Xcode 14+
- iOS 15.5+ deployment target (SDK minimum is iOS 14.0)
- A **Web3Auth Client ID** from [dashboard.web3auth.io](https://dashboard.web3auth.io)
- A **Firebase project** with Email/Password authentication enabled
- A **custom connection** configured on the Web3Auth dashboard for Firebase
- A `GoogleService-Info.plist` added to the Xcode project

### Setting Up the Custom Connection

1. On the dashboard, go to **Connections → Custom** and create a new connection.
2. Set the **JWKS endpoint** to `https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com`.
3. Set the **user ID field** to `sub`.
4. Copy the connection ID and use it as the `authConnectionId` in `authConnectionConfig`.

## Installation

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-firebase-example
open ios-firebase-example.xcodeproj
```

Uses **Swift Package Manager** — dependencies (Web3Auth, Firebase) resolve automatically. Add your own `GoogleService-Info.plist` from the Firebase console.

## Configuration

Open `ViewModel.swift` and set your credentials:

```swift
import Web3Auth
import FirebaseAuth

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    private var clientId = "YOUR_WEB3AUTH_CLIENT_ID"

    func setup() async throws {
        web3Auth = try await Web3Auth(
            options: Web3AuthOptions(
                clientId: clientId,
                web3AuthNetwork: .SAPPHIRE_MAINNET,
                redirectUrl: "web3auth.ios-firebase-example://auth",
                authConnectionConfig: [
                    AuthConnectionConfig(
                        authConnectionId: "YOUR_FIREBASE_CONNECTION_ID",
                        authConnection: .CUSTOM,
                        clientId: clientId
                    )
                ],
                chains: [
                    Chains(
                        chainId: "0xaa36a7",
                        rpcTarget: "https://eth-sepolia.public.blastapi.io",
                        displayName: "Sepolia"
                    )
                ],
                defaultChainId: "0xaa36a7",
            mfaSettings: MfaSettings(
                deviceShareFactor: MfaSetting(enable: true, priority: 1),
                backUpShareFactor: MfaSetting(enable: true, priority: 2),
                socialBackupFactor: MfaSetting(enable: true, priority: 3),
                passwordFactor: MfaSetting(enable: true, priority: 4)
            ),
            sessionTime: 259200 // 3 days
        ))
    }
}
```

## Login Flow

```swift
func loginViaFirebase(email: String, password: String) async throws {
    // 1. Sign in with Firebase
    try await Auth.auth().signIn(withEmail: email, password: password)

    // 2. Fetch a fresh ID token
    let tokenResult = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)

    // 3. Pass the token to Web3Auth
    let result = try await web3Auth?.connectTo(
        loginParams: LoginParams(
            authConnection: .CUSTOM,
            authConnectionId: "YOUR_FIREBASE_CONNECTION_ID",
            idToken: tokenResult?.token,
            mfaLevel: .NONE,
            curve: .SECP256K1
        )
    )
    // result.privateKey → hex private key
}
```

## Wallet Services (In-App Wallet UI)

Wallet Services provides an in-app webview with a fully functional wallet — send, receive, swap, WalletConnect interoperability, and NFT display. It requires an active Web3Auth session.

```swift
func launchWalletServices() async throws {
    try await web3Auth?.showWalletUI()
}
```

## Signing via `request`

For EVM signing that routes through a Wallet Services confirmation modal:

```swift
func signMessage() async throws -> String? {
    var params = [Any]()
    params.append("Hello from iOS!")
    params.append(userAddress)

    let result = try await web3Auth?.request(
        method: "personal_sign",
        requestParams: params
    )
    return result?.success == true ? result?.result : result?.error
}
```

## Project Structure

```
ios-firebase-example/
├── ios-firebase-example.xcodeproj
└── ios-firebase-example/
    ├── ContentView.swift         # Root navigation
    ├── LoginView.swift           # Firebase login UI
    ├── UserDetailView.swift      # Post-login: user info, Wallet Services, MFA, request
    ├── ViewModel.swift           # Web3Auth init, login, logout, Wallet Services, MFA
    └── web3RPC.swift             # EVM interactions via web3.swift
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Firebase Custom Connection Guide](https://docs.metamask.io/embedded-wallets/authentication/custom-connections/firebase/)
- [Custom Connections Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)

## License

MIT — see [LICENSE](../LICENSE) for details.
