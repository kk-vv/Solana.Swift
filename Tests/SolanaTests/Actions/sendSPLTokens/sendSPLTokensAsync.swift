import XCTest
import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class sendSPLTokensAsync: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaSolana
    var solana: Solana!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .mainnetBeta
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
      signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testSendSPLTokenWithFee() async throws {
        let mintAddress = "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263"
        let source = "5n3vrofk2Cj2zEUm7Bq4eT6GNbw8Hyq8EFdWJX2yXPbh"
        let destination = [
          "GQUcpeAgeiBNKWvPCcG2SBEcrXRs9RYbXUjSZnNbkNg3",
          "4nZeaVR96o4G9fwZ3efT3cGTN3n2kjRUhXqAGMrUnPVt",
          "GB3brArmNaPREG6Cp6YHCuW4uimvPv1VbTu3naiinQi8",
          "2q3EXnRMZx3FBF9nXmb8dMB4MjTQeVudwyj5RKESvzkp"
        ]

        let transactionId = try await solana.action.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: source,
            to: destination,
            amount: Double(100).toLamport(decimals: 5),
            payer: signer,
            gasLimit: ComputeBudgetProgram.setComputeUnitLimit(units: 500000),
            priorityFee: ComputeBudgetProgram.setComputeUnitPrice(microLamports: 10 * 5000)
        )
        print(transactionId)
        XCTAssertNotNil(transactionId)
    }
}
