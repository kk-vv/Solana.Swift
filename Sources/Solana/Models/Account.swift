import Foundation
import TweetNacl
import CryptoSwift

public extension Solana {
    struct Account: Codable, Hashable {
        public let phrase: [String]
        public let publicKey: PublicKey
        public let secretKey: Data
        
        /// Create account with seed phrase
        /// - Parameters:
        ///   - phrase: secret phrase for an account, leave it empty for new account
        ///   - network: network in which account should be created
        /// - Throws: Error if the derivation is not successful
        public init(phrase: [String] = [], network: Network, derivablePath: DerivablePath? = nil) throws {
            let mnemonic: Mnemonic
            var phrase = phrase.filter {!$0.isEmpty}
            if !phrase.isEmpty,
               let newMnemonic = Mnemonic(phrase: phrase) {
                mnemonic = newMnemonic
            } else {
                mnemonic = Mnemonic()
                phrase = mnemonic.phrase
            }
            self.phrase = phrase
            
            let derivablePath = derivablePath ?? .default
            
            switch derivablePath.type {
            #if canImport(UIKit)
            case .deprecated:
                let keychain = try Keychain(seedString: phrase.joined(separator: " "), network: network.cluster)
                guard let seed = try keychain.derivedKeychain(at: derivablePath.rawValue).privateKey else {
                    throw SolanaError.other("Could not derivate private key")
                }
                
                let keys = try NaclSign.KeyPair.keyPair(fromSeed: seed)
                
                self.publicKey = try PublicKey(data: keys.publicKey)
                self.secretKey = keys.secretKey
            #endif
            default:
                let keys = try Ed25519HDKey.derivePath(derivablePath.rawValue, seed: mnemonic.seed.toHexString())
                
                let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: keys.key)
                guard let newKey = PublicKey(data: keyPair.publicKey) else {
                    throw SolanaError.invalidPublicKey
                }
                self.publicKey = newKey
                self.secretKey = keyPair.secretKey
            }
        }
        
        public init(secretKey: Data) throws {
            let keys = try NaclSign.KeyPair.keyPair(fromSecretKey: secretKey)
            guard let newKey = PublicKey(data: keys.publicKey) else {
                throw SolanaError.invalidPublicKey
            }
            self.publicKey = newKey
            self.secretKey = keys.secretKey
            let phrase = try Mnemonic.toMnemonic(secretKey.bytes).get()
            self.phrase = phrase
        }
    }
}

public extension Solana.Account {
    struct Meta: Decodable, CustomDebugStringConvertible {
        public let publicKey: Solana.PublicKey
        public var isSigner: Bool
        public var isWritable: Bool
        
        // MARK: - Decodable
        enum CodingKeys: String, CodingKey {
            case pubkey, signer, writable
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            guard let newKey = Solana.PublicKey(string: try values.decode(String.self, forKey: .pubkey)) else {
                throw Solana.SolanaError.invalidPublicKey
            }
            publicKey = newKey
            isSigner = try values.decode(Bool.self, forKey: .signer)
            isWritable = try values.decode(Bool.self, forKey: .writable)
        }
        
        // Initializers
        public init(publicKey: Solana.PublicKey, isSigner: Bool, isWritable: Bool) {
            self.publicKey = publicKey
            self.isSigner = isSigner
            self.isWritable = isWritable
        }
        
        public var debugDescription: String {
            "{\"publicKey\": \"\(publicKey.base58EncodedString)\", \"isSigner\": \(isSigner), \"isWritable\": \(isWritable)}"
        }
    }
}
