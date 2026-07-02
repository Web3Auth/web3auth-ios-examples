import Foundation
import Web3Auth
import FirebaseCore
import FirebaseAuth

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    @Published var loggedIn: Bool = false
    @Published var user: Web3AuthResponse?
    @Published var isLoading = false
    @Published var navigationTitle: String = ""
    private var clientId = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    private var loginParams: LoginParams!

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
                redirectUrl: "web3auth.ios-firebase-example://auth",
                authConnectionConfig: [
                    AuthConnectionConfig(
                        authConnectionId: "w3a-firebase-demo",
                        authConnection: .CUSTOM,
                        clientId: self.clientId
                    )
                ],
                chains: [
                    Chains(
                        chainId: "0xaa36a7",
                        rpcTarget: "https://eth-sepolia.public.blastapi.io",
                        displayName: "Sepolia"
                    ),
                    Chains(
                        chainId: "0x89",
                        rpcTarget: "https://polygon.llamarpc.com",
                        displayName: "Polygon"
                    )
                ],
                defaultChainId: "0xaa36a7",
                mfaSettings: MfaSettings(
                    deviceShareFactor: MfaSetting(enable: true, priority: 1),
                    backUpShareFactor: MfaSetting(enable: true, priority: 2),
                    socialBackupFactor: MfaSetting(enable: true, priority: 3),
                    passwordFactor: MfaSetting(enable: true, priority: 4)
                ),
                sessionTime: 259200
            )
        )

        loginParams = try await prepareLoginParams()
        await MainActor.run(body: {
            if self.web3Auth?.web3AuthResponse != nil {
                user = web3Auth?.web3AuthResponse
                loggedIn = true
            }
            isLoading = false
            navigationTitle = loggedIn ? "UserInfo" : "SignIn"
        })
    }

    func launchWalletServices() {
        Task {
            do {
                try await web3Auth!.showWalletUI()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func enableMFA() {
        Task {
            do {
                loginParams = try await prepareLoginParams()
                _ = try await self.web3Auth?.enableMFA(loginParams)

            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func request(signature: @escaping(String) -> ()) {
        Task {
            do {
                var params = [Any]()
                let address: String? = Web3RPC(
                    user: web3Auth!.web3AuthResponse!
                )?.address.toChecksumAddress()
                params.append("Hello, Web3Auth from iOS!")
                params.append(
                    address!
                )

                params.append("Web3Auth")

                let result = try await self.web3Auth?.request(
                    method: "personal_sign",
                    requestParams: params,
                    path: "wallet/request"
                )

                if result!.success {
                    signature(result!.result!)
                } else {
                    signature(result!.error!)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func loginViaFirebaseEP() {
        Task {
            do {
                let _ = try await Auth.auth().signIn(withEmail: "custom+id_token@firebase.login", password: "Welcome@W3A")
                self.loginParams = try await prepareLoginParams()
                let result = try await web3Auth?.connectTo(loginParams: loginParams)
                await MainActor.run(body: {
                    user = result
                    loggedIn = true
                })

            } catch let error {
                print("Error: ", error)
            }
        }
    }

    private func prepareLoginParams() async throws -> LoginParams {
        let idToken = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)

        return LoginParams(
            authConnection: .CUSTOM,
            authConnectionId: "w3a-firebase-demo",
            mfaLevel: .NONE,
            idToken: idToken?.token,
            curve: .SECP256K1
        )
    }

    func logout() async throws {
        try await web3Auth?.logout()

        await MainActor.run(body: {
            loggedIn.toggle()
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
