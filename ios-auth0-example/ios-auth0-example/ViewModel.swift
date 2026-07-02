import Foundation
import Web3Auth

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    @Published var loggedIn: Bool = false
    @Published var user: Web3AuthResponse?
    @Published var isLoading = false
    @Published var navigationTitle: String = ""
    private var clientId = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"

    func setup() async throws {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
            navigationTitle = "Loading"
        })
        web3Auth = try await Web3Auth(
            options: Web3AuthOptions(
                clientId: clientId,
                web3AuthNetwork: .SAPPHIRE_MAINNET,
                redirectUrl: "web3auth.ios-auth0-example://auth",
                authConnectionConfig: [
                    AuthConnectionConfig(
                        authConnectionId: "w3a-auth0-demo",
                        authConnection: .CUSTOM,
                        clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O"
                    )
                ],
                whiteLabel: WhiteLabelData(
                    appName: "Web3Auth Stub",
                    logoLight: "https://images.web3auth.io/web3auth-logo-w.svg",
                    logoDark: "https://images.web3auth.io/web3auth-logo-w.svg",
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
                sessionTime: 259200
            )
        )
        await MainActor.run(body: {
            if self.web3Auth?.web3AuthResponse != nil {
                user = web3Auth?.web3AuthResponse
                loggedIn = true
            }
            isLoading = false
            navigationTitle = loggedIn ? "UserInfo" : "SignIn"
        })
    }

    func loginWithAuth0() {
        Task {
            do {
                let result = try await web3Auth?.connectTo(
                    loginParams: LoginParams(
                        authConnection: .CUSTOM,
                        mfaLevel: .NONE,
                        extraLoginOptions: ExtraLoginOptions(
                            domain: "https://web3auth.au.auth0.com",
                            userIdField: "sub"
                        ),
                        curve: .SECP256K1
                    )
                )
                await MainActor.run(body: {
                    user = result
                    loggedIn = true
                })

            } catch {
                print("Error")
            }
        }
    }

    func logout() async throws {
        try await web3Auth?.logout()

        await MainActor.run(body: {
            loggedIn = false
        })

    }

}

extension ViewModel {
    func showResult(result: Web3AuthResponse) {
        print("""
        Signed in successfully!
            Private key: \(result.privateKey ?? "")
                Ed25519 Private key: \(result.ed25519PrivateKey ?? "")
            User info:
                Name: \(result.userInfo?.name ?? "")
                Profile image: \(result.userInfo?.profileImage ?? "N/A")
                Auth connection: \(result.userInfo?.authConnection ?? "")
        """)
    }
}
