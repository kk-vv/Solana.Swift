import Foundation

extension Action {
  public func sendSOL(
    to destinations: [String],
    from: Signer,
    amount: UInt64,
    gasLimit: TransactionInstruction? = nil,  //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
    priorityFee: TransactionInstruction? = nil, // ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
    allowUnfundedRecipient: Bool = false,
    onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
  ) {
    guard !destinations.isEmpty else {
      onComplete(.failure(SolanaError.other("Invalid destinations")))
      return
    }
    let account = from
    let fromPublicKey = account.publicKey
    var instructions = [TransactionInstruction]()
    for to in destinations {
      guard let receipt = PublicKey(string: to) else {
        onComplete(.failure(SolanaError.invalidPublicKey))
        return
      }
      let instruction = SystemProgram.transferInstruction(
        from: fromPublicKey,
        to: receipt,
        lamports: amount
      )
      instructions.append(instruction)
    }
    if let gasLimit = gasLimit {
      instructions.append(gasLimit)
    }
    if let priorityFee = priorityFee {
      instructions.append(priorityFee)
    }
    self.serializeAndSendWithFee(
      instructions: instructions,
      signers: [account]
    ) {
      switch $0 {
      case let .success(transaction):
        onComplete(.success(transaction))
      case let .failure(error):
        onComplete(.failure(error))
      }
    }
  }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
  func sendSOL(
    to destination: [String],
    from: Signer,
    amount: UInt64,
    gasLimit: TransactionInstruction? = nil,
    priorityFee: TransactionInstruction? = nil
  ) async throws -> TransactionID {
    try await withCheckedThrowingContinuation { c in
      self.sendSOL(
        to: destination,
        from: from,
        amount: amount,
        gasLimit: gasLimit,
        priorityFee: priorityFee,
        onComplete: c.resume(with:)
      )
    }
  }
}

extension ActionTemplates {
  public struct SendSOL: ActionTemplate {
    public init(
      amount: UInt64,
      destination: [String],
      from: Signer,
      gasLimit: TransactionInstruction? = nil,
      priorityFee: TransactionInstruction? = nil
    ) {
      self.amount = amount
      self.destination = destination
      self.from = from
      self.gasLimit = gasLimit
      self.priorityFee = priorityFee
    }
    
    public typealias Success = TransactionID
    public let amount: UInt64
    public let destination: [String]
    public let from: Signer
    public let gasLimit: TransactionInstruction?
    public let priorityFee: TransactionInstruction?
    
    public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
      actionClass.sendSOL(
        to: destination,
        from: from,
        amount: amount,
        gasLimit: gasLimit,
        priorityFee: priorityFee,
        onComplete: completion
      )
    }
  }
}
