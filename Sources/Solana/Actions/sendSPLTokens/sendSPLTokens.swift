import Foundation

extension Action {
    public func sendSPLTokens(
        mintAddress: String,
        from fromPublicKey: String,
        to destinationAddresses: [String],
        amount: UInt64,
        gasLimit: TransactionInstruction? = nil,  //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
        priorityFee: TransactionInstruction? = nil, // ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        allowUnfundedRecipient: Bool = false,
        payer: Signer,
        onComplete: @escaping (Result<TransactionID, Error>) -> Void
    ) {
      
      guard !destinationAddresses.isEmpty else {
        onComplete(.failure(SolanaError.other("Invalid destinations")))
        return
      }
      
      if #available(iOS 13.0, *) {
        Task {
          do {
            var instructions = [TransactionInstruction]()
            for to in destinationAddresses {
              let (toPublicKey, isUnregisteredAsocciatedToken) = try await self.asyncFindSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: to, allowUnfundedRecipient: allowUnfundedRecipient)
              
              guard fromPublicKey != toPublicKey.base58EncodedString else {
                throw SolanaError.invalidPublicKey
              }

              guard let fromPublicKey = PublicKey(string: fromPublicKey),
                    let mintPublicKey = PublicKey(string: mintAddress),
                    case let .success(fromPublicKey) = PublicKey.associatedTokenAddress(walletAddress: fromPublicKey, tokenMintAddress: mintPublicKey) else {
                throw SolanaError.invalidPublicKey
              }
              // create associated token address
              if isUnregisteredAsocciatedToken {
                guard let mint = PublicKey(string: mintAddress) else {
                  throw SolanaError.invalidPublicKey
                }
                guard let owner = PublicKey(string: to) else {
                  throw SolanaError.invalidPublicKey
                }
                
                let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                  mint: mint,
                  associatedAccount: toPublicKey,
                  owner: owner,
                  payer: payer.publicKey
                )
                instructions.append(createATokenInstruction)
              }
              
              // send instruction
              let sendInstruction = TokenProgram.transferInstruction(
                tokenProgramId: .tokenProgramId,
                source: fromPublicKey,
                destination: toPublicKey,
                owner: payer.publicKey,
                amount: amount
              )
              
              instructions.append(sendInstruction)
            }
            
            if let gasLimit = gasLimit {
              instructions.append(gasLimit)
            }
            
            if let priorityFee = priorityFee {
              instructions.append(priorityFee)
            }
            
            self.serializeAndSendWithFee(instructions: instructions, signers: [payer]) {
              onComplete($0)
            }
          } catch {
            throw error
          }
        }
      } else {
        // Fallback on earlier versions
        onComplete(.failure(SolanaError.other("Unsupported action")))
      }
      
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
    func sendSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: [String],
        amount: UInt64,
        gasLimit: TransactionInstruction? = nil,
        priorityFee: TransactionInstruction? = nil,
        allowUnfundedRecipient: Bool = false,
        payer: Signer
    ) async throws -> TransactionID {
        try await withCheckedThrowingContinuation { c in
            self.sendSPLTokens(
                mintAddress: mintAddress,
                from: fromPublicKey,
                to: destinationAddress,
                amount: amount,
                gasLimit: gasLimit,
                priorityFee: priorityFee,
                allowUnfundedRecipient: allowUnfundedRecipient,
                payer: payer,
                onComplete: c.resume(with:)
            )
        }
    }
}

extension ActionTemplates {
    public struct SendSPLTokens: ActionTemplate {
        public let mintAddress: String
        public let fromPublicKey: String
        public let destinationAddress: [String]
        public let amount: UInt64
        public let payer: Signer
        public let allowUnfundedRecipient: Bool
        public let gasLimit: TransactionInstruction?
        public let priorityFee: TransactionInstruction?

        public typealias Success = TransactionID

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
            actionClass.sendSPLTokens(
              mintAddress: mintAddress,
              from: fromPublicKey,
              to: destinationAddress,
              amount: amount,
              gasLimit: gasLimit,
              priorityFee: priorityFee,
              allowUnfundedRecipient: allowUnfundedRecipient,
              payer: payer,
              onComplete: completion
            )
        }
    }
}
