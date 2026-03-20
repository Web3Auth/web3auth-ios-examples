# MetaMask Embedded Wallets — iOS Examples

[MetaMask Embedded Wallets](https://docs.metamask.io/embedded-wallets/) (formerly Web3Auth) lets you add non-custodial social login wallets to your app. Users sign in with Google, Apple, Auth0, Firebase, or any OAuth provider and get a deterministic, self-custodied private key — no seed phrases, no extension required.

This repository contains iOS (Swift/SwiftUI) examples covering social login, custom authentication, and blockchain integrations.

## iOS Examples

### Core Examples

| Example | Description |
|---|---|
| [Quick Start](./ios-quick-start) | Basic social login (Google, Apple, etc.) + EVM wallet on Ethereum |
| [Grouped Connection (Aggregate Verifier)](./ios-aggregate-verifier-example) | Multiple OAuth providers sharing one wallet address |
| [Auth0 Custom Connection](./ios-auth0-example) | Custom JWT authentication via Auth0 |
| [Firebase Custom Connection](./ios-firebase-example) | Custom JWT authentication via Firebase, with Wallet Services and MFA |

### Blockchain Examples

| Example | Description |
|---|---|
| [Solana](./ios-solana-example) | Solana wallet creation, SOL transfers, SPL token interactions |
| [Aptos](./ios-aptos-example) | Aptos wallet creation and Move module interactions |

### Advanced

| Example | Description |
|---|---|
| [Playground](./ios-playground) | Full-featured sandbox: all login providers, MFA, Wallet Services, chain switching |

> **Note:** The `sfa-ios-*` examples used the deprecated Single Factor Auth (SFA/CoreKit) SDK and are no longer maintained. Use the PnP iOS SDK examples above instead.

## Getting Started

1. **Get a Client ID** — Create a project at [dashboard.web3auth.io](https://dashboard.web3auth.io) and copy the Client ID.
2. **Allowlist your bundle identifier** — In the dashboard, add your app's bundle ID under the iOS allowlist.
3. **Configure a URL scheme** — Add a custom URL scheme in your `Info.plist` (e.g. `com.your.app://auth`) to handle OAuth redirects. Use the same value for `redirectUrl` in your `W3AInitParams`.
4. **Clone and open** — Each example has its own README with step-by-step setup instructions.

```bash
git clone https://github.com/Web3Auth/web3auth-ios-examples.git
cd web3auth-ios-examples/ios-quick-start
open ios-example.xcodeproj
```

All examples use **Swift Package Manager** — no CocoaPods required. Dependencies resolve automatically when you open the project in Xcode.

## Key SDK Concepts

- **No built-in blockchain provider** — iOS SDK exports the private key directly. Use it with `web3.swift`, `solana-swift`, or any Swift-native library.
- **Sapphire Devnet vs. Mainnet** — Use `sapphire_devnet` for local development. Switch to `sapphire_mainnet` for production. Changing the network changes all user wallet addresses permanently.
- **Social logins** — Default connections (Google, Apple, Discord, etc.) work out of the box. Custom OAuth providers require creating a connection on the dashboard.
- **Grouped connections** — Link multiple login methods (e.g. Google + GitHub) so the same user always gets the same wallet address.

## Documentation

- [iOS SDK Docs](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Authentication Overview](https://docs.metamask.io/embedded-wallets/authentication/)
- [Grouped Connections](https://docs.metamask.io/embedded-wallets/authentication/group-connections/)
- [Dashboard](https://dashboard.web3auth.io)

## Support

- [Builder Hub (Community)](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-ios-examples/issues)

## License

MIT — see [LICENSE](./LICENSE) for details.
