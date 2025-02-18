import XCTest
import Solana

class sendSOL: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var signer: Signer!
    
    override func setUpWithError() throws {
      let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))! // 5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx
    }
    
    func testSendSOLFromBalance() {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
        
        let balance = try! solana.api.getBalance(account: signer.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(balance)
        
        let transactionId = try! solana.action.sendSOL(
          to: [toPublicKey],
          amount: balance!/10,
          from: signer,
          gasLimit: ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
          priorityFee: ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        )?.get()
        XCTAssertNotNil(transactionId)
    }
  
    func testSendSOL() {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
        let transactionId = try! solana.action.sendSOL(
          to: [toPublicKey],
          amount: 0.0013.toLamport(decimals: 9),
          from: signer,
          gasLimit: ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
          priorityFee: ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000),
          allowUnfundedRecipient: true
        )?.get()
        print(transactionId)
        XCTAssertNotNil(transactionId)
    }
  
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try solana.action.sendSOL(
          to: [toPublicKey],
          amount: 0.001.toLamport(decimals: 9),
          from: signer,
          gasLimit: ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
          priorityFee: ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        )?.get())
    }
  
    func testSendSOLBigAmmount() {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
        XCTAssertThrowsError(try solana.action.sendSOL(
          to: [toPublicKey],
          amount: 9223372036854775808,
          from: signer,
          gasLimit: ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
          priorityFee: ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        )?.get())
    }
    
    func testMultiSendSOL() {
      let toPublicKey = [
        "GQUcpeAgeiBNKWvPCcG2SBEcrXRs9RYbXUjSZnNbkNg3",
        "4nZeaVR96o4G9fwZ3efT3cGTN3n2kjRUhXqAGMrUnPVt",
        "GB3brArmNaPREG6Cp6YHCuW4uimvPv1VbTu3naiinQi8",
        "2q3EXnRMZx3FBF9nXmb8dMB4MjTQeVudwyj5RKESvzkp",
        "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
      ]
      let transactionId = try! solana.action.sendSOL(
        to: toPublicKey,
        amount: 0.005.toLamport(decimals: 9),
        from: signer,
        gasLimit: nil, //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
        priorityFee: nil, //ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        allowUnfundedRecipient: true
      )?.get()
      print(transactionId)
      XCTAssertNotNil(transactionId)
    }
  
}
