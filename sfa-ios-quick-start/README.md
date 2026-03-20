# [DEPRECATED] SFA iOS Quick Start

> **This example is deprecated.**
>
> The Single Factor Auth (SFA / CoreKit) iOS SDK is no longer actively maintained. These examples will be updated to use the **MetaMask Embedded Wallets iOS SDK** (formerly Web3Auth PnP SDK).
>
> For the current recommended approach, see the [iOS Quick Start example](../ios-quick-start) or any other example in this repository.

---

## What Was This?

This example demonstrated how to use the **Web3Auth Single Factor Auth (SFA) iOS SDK** — a headless SDK that allowed custom JWT-based authentication (via Firebase) without a built-in login modal. Developers had to implement their own authentication UI and pass a JWT directly to the SDK.

### Why Was SFA Deprecated?

The PnP SDK (used in all other examples in this repo) covers the same use case — custom JWT authentication via Firebase, Auth0, or any other provider — and additionally provides:

- A built-in login modal (optional, can be hidden)
- Session management and MFA support
- Wallet Services (in-app wallet UI)
- Active maintenance and new features

## Migrate to PnP

If you were using SFA for custom Firebase authentication, switch to the [Firebase Custom Connection example](../ios-firebase-example). The core flow is the same:
1. Sign in with Firebase.
2. Fetch a fresh ID token.
3. Pass the token to the Web3Auth SDK.

All new features (Wallet Services, MFA, grouped connections) are available in the PnP SDK.

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Firebase Custom Connection Guide](https://docs.metamask.io/embedded-wallets/authentication/custom-connections/firebase/)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)
