import Foundation
import web3
// IMP START - Quick Start
import Web3Auth
import FetchNodeDetails
// IMP END - Quick Start

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    @Published var loggedIn: Bool = false
    @Published var user: Web3AuthResponse?
    @Published var isLoading = false
    @Published var navigationTitle: String = ""
    @Published var privateKey: String = ""
    @Published var ed25519PrivKey: String = ""
    @Published var userInfo: Web3AuthUserInfo?
    @Published var showError: Bool = false
    var errorMessage: String = ""
    // IMP START - Get your Web3Auth Client ID from Dashboard
    private var clientID = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    // IMP END - Get your Web3Auth Client ID from Dashboard
    // IMP START - Whitelist bundle ID
    private var redirectUrl: String = "web3auth.ios-example://auth"
    private var web3AuthNetwork: Web3AuthNetwork = .SAPPHIRE_MAINNET
    private var buildEnv: BuildEnv = .production
    // IMP END - Whitelist bundle ID
    func setup() async throws {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
            navigationTitle = "Loading"
        })
        
        // IMP START - Initialize Web3Auth
        web3Auth = try await Web3Auth(options: .init(
            clientId: clientID,
            redirectUrl: redirectUrl,
            authBuildEnv: buildEnv,
            web3AuthNetwork: web3AuthNetwork
        ))
        // IMP END - Initialize Web3Auth
        await MainActor.run(body: {
            if self.web3Auth?.web3AuthResponse != nil {
                handleUserDetails()
                loggedIn = true
            }
            isLoading = false
            navigationTitle = loggedIn ? "UserInfo" : "SignIn"
        })
    }

    @MainActor func handleUserDetails() {
        do {
            loggedIn = true
            user = try web3Auth?.getWeb3AuthResponse()
            privateKey = web3Auth?.getPrivateKey() ?? ""
            ed25519PrivKey = try web3Auth?.getEd25519PrivateKey() ?? ""
            userInfo = try web3Auth?.getUserInfo()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func login(authConnection: AuthConnection) {
        Task {
            do {
                // IMP START - Login
                _ = try await web3Auth?.login(loginParams: LoginParams(
                    authConnection: authConnection,
                    mfaLevel: .DEFAULT,
                    curve: .SECP256K1
                ))
                // IMP END - Login
                await handleUserDetails()
            } catch {
                print("Error")
            }
        }
    }
    
    @MainActor func logout() {
        Task {
            do {
                // IMP START - Logout
                try await web3Auth?.logout()
                // IMP END - Logout
                loggedIn = false
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func loginEmailPasswordless(email: String) {
        Task {
            do {
                // IMP START - Login
                _ = try await web3Auth?.login(loginParams: LoginParams(
                    authConnection: .EMAIL_PASSWORDLESS,
                    mfaLevel: .DEFAULT,
                    extraLoginOptions: ExtraLoginOptions(
                        display: nil, prompt: nil, max_age: nil, ui_locales: nil,
                        id_token_hint: nil, id_token: nil, login_hint: email,
                        acr_values: nil, scope: nil, audience: nil, connection: nil,
                        domain: nil, client_id: nil, redirect_uri: nil, leeway: nil,
                        userIdField: nil, isUserIdCaseSensitive: nil, additionalParams: nil
                    ),
                    curve: .SECP256K1
                ))
                // IMP END - Login
                await handleUserDetails()
            } catch {
                print("Error")
            }
        }
    }
}
