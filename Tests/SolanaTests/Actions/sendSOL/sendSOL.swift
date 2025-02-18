import XCTest
import Solana

class sendSOL: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaSolana
    var solana: Solana!
    var signer: Signer!
    
    override func setUpWithError() throws {
        let wallet: TestsWallet = .mainnetBeta
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
          from: signer
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
        let transactionId = try! solana.action.sendSOL(
          to: [toPublicKey],
          amount: 0.001.toLamport(decimals: 9),
          from: signer
          ,allowUnfundedRecipient: true
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try solana.action.sendSOL(
          to: [toPublicKey],
          amount: 0.001.toLamport(decimals: 9),
          from: signer
        )?.get())
    }
    func testSendSOLBigAmmount() {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
        XCTAssertThrowsError(try solana.action.sendSOL(
          to: [toPublicKey],
          amount: 9223372036854775808,
          from: signer
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
        allowUnfundedRecipient: true
      )?.get()
      print(transactionId)
      XCTAssertNotNil(transactionId)
    }
  
}
