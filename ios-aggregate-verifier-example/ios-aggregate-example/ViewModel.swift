import Foundation
import Web3Auth
import web3
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
    private var redirectUrl = "web3auth.ios-aggregate-example://auth"
    private var web3AuthNetwork: Web3AuthNetwork = .SAPPHIRE_MAINNET
    private var buildEnv: BuildEnv = .production
    private var chainConfig: [Chains] = [
        Chains(
            chainNamespace: .eip155,
            chainId: "0x1",
            rpcTarget: "https://mainnet.infura.io/v3/79921cf5a1f149f7af0a0fef80cf3363",
            ticker: "ETH"
        )
    ]
    
    func setup() async throws {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
            navigationTitle = "Loading"
        })
        
        var authConfig: [AuthConnectionConfig] = []
        
        // Add Google configuration
        authConfig.append(
            AuthConnectionConfig(
                authConnectionId: "w3a-google",
                authConnection: .GOOGLE,
                name: "Web3Auth-Aggregate-Verifier-Google-Example",
                clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com",
                groupedAuthConnectionId: "aggregate-sapphire"
            )
        )
        
        // Add GitHub configuration
        authConfig.append(
            AuthConnectionConfig(
                authConnectionId: "w3a-a0-github",
                authConnection: .CUSTOM,
                name: "Web3Auth-Aggregate-Verifier-GitHub-Example",
                clientId: "hiLqaop0amgzCC0AXo4w0rrG9abuJTdu",
                groupedAuthConnectionId: "aggregate-sapphire"
            )
        )
        
        web3Auth = try await Web3Auth(options: .init(
            clientId: clientID,
            redirectUrl: redirectUrl,
            authBuildEnv: buildEnv,
            authConnectionConfig: authConfig,
            sessionTime: 259200, // 3 days authentication period
            web3AuthNetwork: web3AuthNetwork
        ))
        
        await MainActor.run(body: {
            print("user: ", self.web3Auth?.web3AuthResponse)
            print("conditional: ", self.web3Auth?.web3AuthResponse != nil)
            if let existingUser = self.web3Auth?.web3AuthResponse {
                user = existingUser
                handleUserDetails()
                loggedIn = true
            }
            isLoading = false
            navigationTitle = loggedIn ? "UserInfo" : "Agg-Verifier Example"
        })
    }
    
    @MainActor func handleUserDetails() {
        do {
            loggedIn = true
            privateKey = web3Auth?.getPrivateKey() ?? ""
            ed25519PrivKey = try web3Auth?.getEd25519PrivateKey() ?? ""
            userInfo = try web3Auth?.getUserInfo()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func loginWithGoogle() {
        Task {
            do {
                let loginResult = try await web3Auth?.login(
                    loginParams: LoginParams(
                        authConnection: .GOOGLE,
                        authConnectionId: "w3a-google",
                        groupedAuthConnectionId: "aggregate-sapphire",
                        mfaLevel: .DEFAULT,
                        curve: .SECP256K1
                    )
                )
                await MainActor.run {
                    user = loginResult
                }
                await handleUserDetails()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    func loginWithGitHub() {
        Task {
            do {
                let loginResult = try await web3Auth?.login(
                    loginParams: LoginParams(
                        authConnection: .CUSTOM,
                        authConnectionId: "w3a-a0-github",
                        groupedAuthConnectionId: "aggregate-sapphire",
                        mfaLevel: .DEFAULT,
                        extraLoginOptions: ExtraLoginOptions(
                            connection: "github",
                            domain: "https://web3auth.au.auth0.com",
                            userIdField: "email",
                            isUserIdCaseSensitive: false
                        ),
                        curve: .SECP256K1
                    )
                )
                await MainActor.run {
                    user = loginResult
                }
                await handleUserDetails()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    @MainActor func logout() {
        Task {
            do {
                try await web3Auth?.logout()
                loggedIn = false
                user = nil
                privateKey = ""
                ed25519PrivKey = ""
                userInfo = nil
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    @MainActor func showWalletUI() {
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
                _ = try await web3Auth?.enableMFA()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    @MainActor func manageMFA() {
        Task {
            do {
                _ = try await web3Auth?.manageMFA()
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
                params.append("Hello from Web3Auth!")
                params.append(checksumAddress)
                params.append("Web3Auth Aggregate Example")
                
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
