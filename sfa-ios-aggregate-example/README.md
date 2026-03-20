# [DEPRECATED] SFA iOS Aggregate Verifier Example

> **This example is deprecated.**
>
> The Single Factor Auth (SFA / CoreKit) iOS SDK is no longer actively maintained. These examples will be updated to use the **MetaMask Embedded Wallets iOS SDK** (formerly Web3Auth PnP SDK).
>
> For the current recommended approach to grouped logins, see the [iOS Grouped Connection example](../ios-aggregate-verifier-example).

---

## What Was This?

This example demonstrated how to use the **Web3Auth Single Factor Auth (SFA) iOS SDK** with an aggregate verifier — linking multiple login providers (e.g. Google + Email) so the same user always gets the same wallet address, regardless of which provider they signed in with.

### Why Was SFA Deprecated?

The PnP SDK covers aggregate verifiers (now called **grouped connections**) with a more complete feature set:

- Grouped connections work the same way but are configured entirely on the dashboard
- Supports Wallet Services, MFA, session management
- Actively maintained with ongoing feature additions

## Migrate to PnP

If you were using SFA aggregate verifiers, switch to the [iOS Grouped Connection example](../ios-aggregate-verifier-example). The concept is identical:
1. Configure a grouped connection on the dashboard with multiple sub-connections.
2. Set `loginConfig` in `W3AInitParams` to point both providers at the same grouped connection ID with their respective `verifierSubIdentifier`.
3. Users signing in with any of the linked providers always get the same wallet.

## Resources

- [iOS SDK Documentation](https://docs.metamask.io/embedded-wallets/sdk/ios/)
- [Grouped Connections Guide](https://docs.metamask.io/embedded-wallets/authentication/group-connections/)
- [Dashboard](https://dashboard.web3auth.io)
- [Builder Hub (Community & Support)](https://builder.metamask.io/c/embedded-wallets/5)
