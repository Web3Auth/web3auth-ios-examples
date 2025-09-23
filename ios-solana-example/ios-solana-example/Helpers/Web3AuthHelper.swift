//
//  Web3AuthHelper.swift
//  ios-solana-example
//
//  Created by Ayush B on 26/02/24.
//

import Foundation
import Web3Auth
import FetchNodeDetails

class Web3AuthHelper {
    
    var web3Auth: Web3Auth!
    private var clientID = "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ"
    private var redirectUrl = "com.w3a.ios-solana-example://auth"
    private var web3AuthNetwork: Web3AuthNetwork = .SAPPHIRE_MAINNET
    private var buildEnv: BuildEnv = .production
    
    func initialize() async throws {
        web3Auth = try await Web3Auth(options: .init(
            clientId: clientID,
            redirectUrl: redirectUrl,
            authBuildEnv: buildEnv,
            web3AuthNetwork: web3AuthNetwork,
            useSFAKey: true
        ))
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
    
    func getSolanaPrivateKey() throws -> String {
        print("getSolanaPrivateKey", web3Auth.getEd25519PrivateKey())
        return web3Auth.getEd25519PrivateKey()
    }
    
    func login() async throws {
        _ = try await web3Auth.login(loginParams: LoginParams(
            authConnection: .GOOGLE,
            mfaLevel: .DEFAULT,
            curve: .ED25519
        ))
    }
}
