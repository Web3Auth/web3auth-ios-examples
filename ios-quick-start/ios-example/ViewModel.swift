import Foundation
// IMP START - Quick Start
import Web3Auth
// IMP END - Quick Start

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    @Published var loggedIn: Bool = false
    @Published var user: Web3AuthResponse?
    @Published var isLoading = false
    @Published var navigationTitle: String = ""
    // IMP START - Get your Web3Auth Client ID from Dashboard
    private var clientId = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    // IMP END - Get your Web3Auth Client ID from Dashboard
    func setup() async {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
            navigationTitle = "Loading"
        })

        // IMP START - Initialize Web3Auth
        do {
            web3Auth = try await Web3Auth(
                options: Web3AuthOptions(
                    clientId: clientId,
                    web3AuthNetwork: .SAPPHIRE_MAINNET,
                    redirectUrl: "web3auth.ios-example://auth"
                )
            )
        } catch {
            print("Something went wrong")
        }
        // IMP END - Initialize Web3Auth
        await MainActor.run(body: {
            if self.web3Auth?.web3AuthResponse != nil {
                user = web3Auth?.web3AuthResponse
                loggedIn = true
            }
            isLoading = false
            navigationTitle = loggedIn ? "UserInfo" : "SignIn"
        })
    }

    func login(provider: AuthConnection) {
        Task {
            do {
                // IMP START - Login
                let result = try await web3Auth?.connectTo(
                    loginParams: LoginParams(authConnection: provider)
                )
                // IMP END - Login
                await MainActor.run(body: {
                    user = result
                    loggedIn = true
                })

            } catch {
                print("Error")
            }
        }
    }

    func logout() throws {
        Task {
            // IMP START - Logout
            try await web3Auth?.logout()
            // IMP END - Logout
            await MainActor.run(body: {
                loggedIn = false
            })
        }
    }

    func loginEmailPasswordless(provider: AuthConnection, email: String) {
        Task {
            do {
                // IMP START - Login
                let result = try await web3Auth?.connectTo(
                    loginParams: LoginParams(
                        authConnection: provider,
                        loginHint: email
                    )
                )
                // IMP END - Login
                await MainActor.run(body: {
                    user = result
                    loggedIn = true
                    navigationTitle = "UserInfo"
                })

            } catch {
                print("Error")
            }
        }
    }
}
