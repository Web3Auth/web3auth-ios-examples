import Foundation
import Aptos
import Core
import Transactions
import Types
import Clients
import Crypto

struct Coin: Codable {
    let coin: InnerCoin
    
    struct InnerCoin: Codable {
        let value: String
    }
}

class AptosHelper {
    var aptosClient: Aptos!
    var account: AccountProtocol!
    
    /// Initializes the Aptos client and account using the provided Web3Auth private key.
    /// - Parameter privateKey: The private key received from Web3Auth.
    func initialize(privateKey: String) async throws {
        aptosClient = Aptos(aptosConfig: .devnet)
        if !privateKey.isEmpty {
            account = try generateAptosAccount(privateKey: privateKey)
        }
        
        print("Aptos client and account initialized successfully on devnet.")
    }
    
    /// Generates an Aptos account using a Web3Auth private key.
    /// - Parameter privateKey: The Web3Auth private key in hex format.
    /// - Returns: The generated Aptos account.
    func generateAptosAccount(privateKey: String) throws -> AccountProtocol {
        let privateKeyData = Data(hex: privateKey)
        let keyBytes = privateKeyData.bytes.prefix(32)
        
        guard keyBytes.count == 32 else {
            throw NSError(domain: "AptosHelper", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid private key length."])
        }
        
        let ed25519PrivateKey = try Ed25519PrivateKey(Data(keyBytes).hexString)
        let account = try Account.fromPrivateKey(ed25519PrivateKey)
        
        print("Aptos account generated with address: \(account.accountAddress.toString())")
        return account
    }

    /// Signs a message using the private key of the generated Aptos account.
    /// - Parameter message: The message to sign.
    /// - Returns: The signature as a string.
    func signMessage(message: String) throws -> String {
        guard let _ = message.data(using: .utf8) else {
            throw NSError(domain: "AptosHelper", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid message format."])
        }
        let signature = try account.sign(message: message)
        return signature.toString()
    }
    
    /// Fetches the balance of AptosCoin for the current account.
    /// - Returns: The account balance as a string.
    func getBalance() async throws -> String {
        // Use view function to get balance (most reliable method)
        do {
            let payload = InputViewFunctionData(
                function: "0x1::coin::balance",
                typeArguments: ["0x1::aptos_coin::AptosCoin"],
                functionArguments: [account.accountAddress]
            )
            
            let result = try await aptosClient.general.view(payload: payload)
            
            if let balanceArray = result as? [Any], 
               let stringValue = balanceArray.first as? String,
               let atomicBalance = UInt64(stringValue) {
                return formatBalanceToString(atomicBalance: atomicBalance)
            }
            
            return "0"
        } catch {
            print("Failed to fetch balance: \(error.localizedDescription)")
            return "0"
        }
    }
    
    /// Requests an airdrop of Aptos tokens from the devnet faucet and returns the transaction hash.
    /// - Returns: A string representing the transaction hash of the airdrop request.
    func airdropFaucet() async throws -> String {
        let faucetAmount = 100_000_000 // 1 APT
        print("Attempting to fund account: \(account.accountAddress.toString()) with amount: \(faucetAmount) (1 APT) on devnet")
        
        // SDK method
        do {
            let userTransaction = try await aptosClient.faucet.fundAccount(accountAddress: account.accountAddress, amount: faucetAmount)
            
            if userTransaction.success {
                // Wait for the transaction to be confirmed on-chain
                let confirmedTxn = try await aptosClient.transaction.waitForTransaction(transactionHash: userTransaction.hash)
                
                // Add delay to ensure balance is updated
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                return confirmedTxn.hash
            } else {
                throw NSError(domain: "AptosHelper", code: 5, userInfo: [NSLocalizedDescriptionKey: "Airdrop failed with status: \(userTransaction.vmStatus)"])
            }
        } catch {
            throw NSError(domain: "AptosHelper", code: 6, userInfo: [NSLocalizedDescriptionKey: "Devnet faucet request failed: \(error.localizedDescription)"])
        }
    }
    
    /// Executes a self-transfer of AptosCoin within the same account.
    /// - Returns: The transaction hash of the self-transfer.
    func selfTransfer() async throws -> String {
        let senderAccount = account!
        let accountAddress = senderAccount.accountAddress
        
        // Build, sign, and submit the transaction
        let rawTxn = try await aptosClient.transaction.build.simple(
            sender: accountAddress,
            data: InputEntryFunctionData(
                function: "0x1::aptos_account::transfer",
                functionArguments: [accountAddress, 100]
            )
        )
        
        let authenticator = try await aptosClient.transaction.sign.transaction(
            signer: senderAccount,
            transaction: rawTxn
        )
        
        let response = try await aptosClient.transaction.submit.simple(
            transaction: rawTxn,
            senderAuthenticator: authenticator
        )
        
        let txn = try await aptosClient.transaction.waitForTransaction(transactionHash: response.hash)
        
        // Add a small delay to ensure balance is updated
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
        return txn.hash
    }
    
    /// Converts atomic balance to human-readable APT balance string.
    /// - Parameter atomicBalance: The balance in atomic units (octas).
    /// - Returns: A formatted string representing the balance in APT units.
    private func formatBalanceToString(atomicBalance: UInt64) -> String {
        let aptBalance = Double(atomicBalance) / 100_000_000.0
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 2
        
        return numberFormatter.string(from: NSNumber(value: aptBalance)) ?? "\(aptBalance)"
    }
    
    /// Converts atomic balance string units to human-readable APT balance string.
    /// - Parameter atomicBalanceString: The balance in atomic units as a string.
    /// - Returns: A formatted string representing the balance in APT units.
    private func formatBalanceToString(atomicBalanceString: String) -> String {
        guard let atomicBalance = UInt64(atomicBalanceString) else {
            return "Invalid balance"
        }
        return formatBalanceToString(atomicBalance: atomicBalance)
    }
}
