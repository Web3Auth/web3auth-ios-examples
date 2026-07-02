import Foundation
import Web3Auth

class ViewModel: ObservableObject {
    lazy var web3Auth: Web3Auth? = nil
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
                redirectUrl: "web3auth.ios-aggregate-example://auth",
                authConnectionConfig: [
                    AuthConnectionConfig(
                        authConnectionId: "aggregate-sapphire",
                        groupedAuthConnectionId: "w3a-google",
                        authConnection: .GOOGLE,
                        name: "Web3Auth-Aggregate-Verifier-Google-Example",
                        clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com"
                    ),
                    AuthConnectionConfig(
                        authConnectionId: "aggregate-sapphire",
                        groupedAuthConnectionId: "w3a-a0-github",
                        authConnection: .CUSTOM,
                        name: "Web3Auth-Aggregate-Verifier-GitHub-Example",
                        clientId: "hiLqaop0amgzCC0AXo4w0rrG9abuJTdu"
                    )
                ],
                sessionTime: 259200
            )
        )
        await MainActor.run(body: {
            if self.web3Auth?.web3AuthResponse != nil {
                user = web3Auth?.web3AuthResponse
                loggedIn = true
            }
            isLoading = false
            navigationTitle = loggedIn ? "UserInfo" : "Agg-Verifier Example"
        })
    }

    func loginWithGoogle() {
        Task {
            do {
                let result = try await web3Auth?.connectTo(
                    loginParams: LoginParams(authConnection: .GOOGLE)
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

    func loginWithGitHub() {
        Task {
            do {
                let result = try await web3Auth?.connectTo(
                    loginParams: LoginParams(
                        authConnection: .CUSTOM,
                        extraLoginOptions: ExtraLoginOptions(
                            connection: "github",
                            domain: "https://web3auth.au.auth0.com",
                            userIdField: "email",
                            isUserIdCaseSensitive: false
                        )
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
