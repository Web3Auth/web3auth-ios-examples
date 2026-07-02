# MetaMask Embedded Wallets — iOS Playground

[![Web3Auth iOS SDK](https://img.shields.io/badge/MetaMask_Embedded_Wallets-iOS_SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/ios/)
[![Community](https://img.shields.io/badge/Builder_Hub-Community-cyan)](https://builder.metamask.io/c/embedded-wallets/5)

A sandbox app for experimenting with MetaMask Embedded Wallets on iOS. Users sign in with email passwordless, then interact with EVM chains using `web3.swift`.

## What This Example Covers

- Email passwordless login via `connectTo`
- Multi-chain EVM switching (Sepolia, Arbitrum Sepolia)
- Message signing and transaction sending
- ERC-20 balance checks and approval revocation

For Wallet Services, MFA, and custom JWT flows, see the [Firebase example](../ios-firebase-example) and [Auth0 example](../ios-auth0-example).

## Prerequisites

- Xcode 14+
- iOS 17.0+ deployment target (SDK minimum is iOS 14.0)
- A Client ID from [dashboard.web3auth.io](https://dashboard.web3auth.io)

## Installation

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-playground
open ios-playground.xcodeproj
```

## Configuration

Set your Client ID and redirect URL in `Helpers/Web3AuthHelper.swift`:

```swift
web3Auth = try await Web3Auth(
    options: Web3AuthOptions(
        clientId: "YOUR_CLIENT_ID",
        web3AuthNetwork: .SAPPHIRE_MAINNET,
        redirectUrl: "com.w3a.ios-playground://auth"
    )
)
```

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Dashboard](https://dashboard.web3auth.io)

## License

MIT — see [LICENSE](../LICENSE) for details.
