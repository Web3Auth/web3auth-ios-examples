import Foundation
import web3
import Web3Auth
import FetchNodeDetails

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
    private var clientID = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    private var redirectUrl: String = "web3auth.ios-auth0-example://auth"
    private var web3AuthNetwork: Web3AuthNetwork = .SAPPHIRE_MAINNET
    private var buildEnv: BuildEnv = .production
    func setup() async throws {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
            navigationTitle = "Loading"
        })
        
        // Configure Auth0 connection
        let authConfig = [
            AuthConnectionConfig(
                authConnectionId: "w3a-auth0-demo",
                authConnection: .CUSTOM,
                clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O"
            )
        ]
        
        web3Auth = try await Web3Auth(options: .init(
            clientId: clientID,
            redirectUrl: redirectUrl,
            authBuildEnv: buildEnv,
            authConnectionConfig: authConfig,
            sessionTime: 259200,
            web3AuthNetwork: web3AuthNetwork,
            useSFAKey: true
        ))
        
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
            privateKey = ((web3Auth?.getPrivateKey() != "") ? web3Auth?.getPrivateKey() : try web3Auth?.getWeb3AuthResponse().factorKey) ?? ""
            ed25519PrivKey = try web3Auth?.getEd25519PrivateKey() ?? ""
            userInfo = try web3Auth?.getUserInfo()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func loginWithAuth0() {
        Task{
            do {
                _ = try await web3Auth?.login(loginParams: LoginParams(
                    authConnection: .CUSTOM,
                    authConnectionId: "w3a-auth0-demo",
                    mfaLevel: .DEFAULT,
                    extraLoginOptions: ExtraLoginOptions(
                        display: nil, prompt: nil, max_age: nil, ui_locales: nil,
                        id_token_hint: nil, id_token: nil, login_hint: nil,
                        acr_values: nil, scope: nil, audience: nil, connection: nil,
                        domain: "https://web3auth.au.auth0.com", client_id: nil,
                        redirect_uri: nil, leeway: nil, userIdField: "sub",
                        isUserIdCaseSensitive: nil, additionalParams: nil
                    ),
                    curve: .SECP256K1
                ))
                await handleUserDetails()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    @MainActor func logout() {
        Task {
            do {
                try await web3Auth?.logout()
                loggedIn = false
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
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
                AuthConnection: \(result.userInfo?.authConnection ?? "")
        """)
    }
}
