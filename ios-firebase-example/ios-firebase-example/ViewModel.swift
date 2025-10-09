import Foundation
import web3
import Web3Auth
import FetchNodeDetails
import FirebaseCore
import FirebaseAuth

class ViewModel: ObservableObject {
    var web3Auth: Web3Auth?
    @Published var loggedIn: Bool = false
    @Published var user: Web3AuthResponse?
    @Published var isLoading = false
    @Published var isAuthenticating = false
    @Published var navigationTitle: String = ""
    @Published var privateKey: String = ""
    @Published var ed25519PrivKey: String = ""
    @Published var userInfo: Web3AuthUserInfo?
    @Published var showError: Bool = false
    var errorMessage: String = ""
    private var clientID: String = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    private var redirectUrl: String = "web3auth.ios-firebase-example://auth"
    private var web3AuthNetwork: Web3AuthNetwork = .SAPPHIRE_MAINNET
    private var buildEnv: BuildEnv = .production
    private var useCoreKit: Bool = false
    private var loginParams: LoginParams?
    
    func setup() async throws {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
            navigationTitle = "Loading"
        })
        
        // Configure Firebase connection
        let authConfig = [
            AuthConnectionConfig(
                authConnectionId: "w3a-firebase-demo",
                authConnection: .CUSTOM,
                clientId: clientID
            )
        ]
        
        web3Auth = try await Web3Auth(options: .init(
            clientId: clientID,
            redirectUrl: redirectUrl,
            authBuildEnv: buildEnv,
            authConnectionConfig: authConfig,
            sessionTime: 259200,
            web3AuthNetwork: web3AuthNetwork,
            useSFAKey: useCoreKit
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
            ed25519PrivKey = web3Auth?.getEd25519PrivateKey() ?? ""
            userInfo = try web3Auth?.getUserInfo()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    @MainActor func launchWalletServices() {
        Task {
            do {
                try await web3Auth?.showWalletUI()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    @MainActor func enableMFA() {
        Task {
            do {
                _ = try await self.web3Auth?.enableMFA()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    @MainActor func manageMFA() {
        Task {
            do {
                _ = try await self.web3Auth?.manageMFA()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    @MainActor func request() {
        Task {
            do {
                let key = self.web3Auth!.getPrivateKey()
                let pk = try KeyUtil.generatePublicKey(from: Data(hexString: key) ?? Data())
                let pkAddress = KeyUtil.generateAddress(from: pk).asString()
                let checksumAddress = EthereumAddress(pkAddress).toChecksumAddress()
                var params = [Any]()
                params.append("Hello, Web3Auth from iOS!")
                params.append(checksumAddress)
                params.append("Web3Auth")
                let signResponse = try await self.web3Auth?.request(method: "personal_sign", requestParams: params)
                if let response = signResponse {
                    print("Sign response received: \(response)")
                } else {
                    print("No sign response received.")
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func loginViaFirebaseEP() {
        // Prevent concurrent logins which can cause continuation misuse
        guard !isAuthenticating else { return }
        isAuthenticating = true
        Task{
            do {
                // Firebase sign-in to obtain fresh ID token
                _ = try await Auth.auth().signIn(withEmail: "custom+id_token@firebase.login", password: "Welcome@W3A")

                // Build fresh login params per invocation
                let params = try await prepareLoginParams()

                // Ensure Web3Auth is initialized
                guard let web3Auth = web3Auth else {
                    throw NSError(domain: "Web3Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web3Auth not initialized"])
                }

                _ = try await web3Auth.login(loginParams: params)
                await handleUserDetails()
                
            } catch let error {
                print("Error: ", error)
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
            await MainActor.run {
                self.isAuthenticating = false
            }
        }
    }

    func loginWithGoogle() {
        // Prevent concurrent logins
        guard !isAuthenticating else { return }
        isAuthenticating = true
        Task {
            do {
                // Ensure Web3Auth is initialized
                guard let web3Auth = web3Auth else {
                    throw NSError(domain: "Web3Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web3Auth not initialized"])
                }
                // Direct Google login via Web3Auth
                _ = try await web3Auth.login(loginParams: LoginParams(
                    authConnection: .GOOGLE,
                    mfaLevel: .DEFAULT,
                    curve: .SECP256K1
                ))
                await handleUserDetails()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
            await MainActor.run {
                self.isAuthenticating = false
            }
        }
    }
    
    private func prepareLoginParams() async throws -> LoginParams {
        let idToken = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
        
        return LoginParams(
            authConnection: .CUSTOM,
            authConnectionId: "w3a-firebase-demo",
            mfaLevel: .DEFAULT,
            extraLoginOptions: ExtraLoginOptions(
                display: nil, prompt: nil, max_age: nil, ui_locales: nil,
                id_token_hint: nil, id_token: idToken?.token, login_hint: nil,
                acr_values: nil, scope: nil, audience: nil, connection: nil,
                domain: nil, client_id: nil, redirect_uri: nil, leeway: nil,
                userIdField: "sub", isUserIdCaseSensitive: nil, additionalParams: nil
            ),
            curve: .SECP256K1
        )
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
