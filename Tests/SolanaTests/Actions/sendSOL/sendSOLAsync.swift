import XCTest
import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class sendSOLAsync: XCTestCase {
  var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))! // 5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx
    }
    
    func testSendSOLFromBalance() async throws {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"

        let balance = try await solana.api.getBalance(account: signer.publicKey.base58EncodedString, commitment: nil)
        XCTAssertNotNil(balance)

        let transactionId = try await solana.action.sendSOL(
            to: [toPublicKey],
            from: signer,
            amount: balance/10,
            gasLimit: nil, //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
            priorityFee: nil //ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        )
        XCTAssertNotNil(transactionId)
    }
    
    func testSendSOL() async throws {
        let toPublicKey = "FLY7ePk6wQ2cWKPoU9FCZuA8gRtYmKJuM276nkmqmr7h"
        let transactionId = try await solana.action.sendSOL(
            to: [toPublicKey],
            amount: 0.001.toLamport(decimals: 9),
            from: signer,
            gasLimit: nil, //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
            priorityFee: nil //ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        )
        XCTAssertNotNil(transactionId)
    }
  
    func testSendSOLIncorrectDestination() async {
        let toPublicKey = "XX"
        await asyncAssertThrowing("sendSOL should fail when destination is incorrect") {
            try await solana.action.sendSOL(
                to: [toPublicKey],
                from: signer,
                amount: 0.001.toLamport(decimals: 9),
                gasLimit: nil, //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
                priorityFee: nil //ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
            )
        }
    }
    func testSendSOLBigAmmount() async {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        await asyncAssertThrowing("sendSOL should fail when amount is too big") {
            try await solana.action.sendSOL(
                to: [toPublicKey],
                from: signer,
                amount: 9223372036854775808,
                gasLimit: nil, //ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
                priorityFee: nil //ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
            )
        }

    }
}
