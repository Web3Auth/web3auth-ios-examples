//
//  Web3AuthHelper.swift
//  ios-playground
//
//  Created by Ayush B on 25/04/24.
//

import Foundation
import Web3Auth

class Web3AuthHelper {

    var web3Auth: Web3Auth!

    func initialize() async throws {
        web3Auth = try await Web3Auth(
            options: Web3AuthOptions(
                clientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ",
                web3AuthNetwork: .SAPPHIRE_MAINNET,
                redirectUrl: "com.w3a.ios-playground://auth"
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

    func getEd25519PrivateKey() throws -> String {
        return try web3Auth.getEd25519PrivateKey()
    }

    func login(email: String) async throws {
        let _ = try await web3Auth.connectTo(
            loginParams: LoginParams(
                authConnection: .EMAIL_PASSWORDLESS,
                loginHint: email
            )
        )

        return
    }
}
