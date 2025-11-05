//
//  Web3AuthHelper.swift
//  ios-playground
//
//  Created by Ayush B on 25/04/24.
//

import Foundation
import Web3Auth
import FetchNodeDetails

class Web3AuthHelper {
    
    var web3Auth: Web3Auth!
    
    private let clientID = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    private let redirectUrl = "com.w3a.ios-playground://auth"
    private let web3AuthNetwork: Web3AuthNetwork = .SAPPHIRE_MAINNET
    private let buildEnv: BuildEnv = .production
    
    func initialize() async throws {
        web3Auth = try await Web3Auth(
            options: .init(
                clientId: clientID,
                redirectUrl: redirectUrl,
                authBuildEnv: buildEnv,
                web3AuthNetwork: web3AuthNetwork
            )
        )
    }
    
    func isUserAuthenticated() -> Bool {
        return web3Auth.web3AuthResponse != nil
    }
    
    func logOut() async throws {
        return try await web3Auth.logout()
    }
    
    func getUserDetails() throws -> Web3AuthUserInfo {
        return try web3Auth.getUserInfo()
    }
    
    func getPrivateKey() -> String {
        return web3Auth.getPrivateKey()
    }
    
    func getSolanaPrivateKey() throws -> String {
        return try web3Auth.getEd25519PrivateKey()
    }
    
    func getWeb3AuthResponse() -> Web3AuthResponse? {
        return web3Auth.web3AuthResponse
    }
    
    func login(email: String) async throws {
        _ = try await web3Auth.login(
            loginParams: LoginParams(
                authConnection: .EMAIL_PASSWORDLESS,
                extraLoginOptions: ExtraLoginOptions(login_hint: email)
            )
        )
    }
}
