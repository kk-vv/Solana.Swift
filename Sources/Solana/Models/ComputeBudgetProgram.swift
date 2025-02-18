//
//  File.swift
//  Solana
//
//  Created by Felix Hu on 2025/2/18.
//

import Foundation

public struct ComputeBudgetProgram {
  
  public static let programId = PublicKey(string: "ComputeBudget111111111111111111111111111111")!
  
  public static func setComputeUnitLimit(units: UInt32) -> TransactionInstruction {
    /*{
      "discriminator": {
        "type": "u8",
        "data": 2
      },
      "units": {
        "type": "u32",
        "data": 1231234
      }
    }*/
    return TransactionInstruction(keys: [], programId: programId, data: [UInt8(2), units])
  }
  
  public static func setComputeUnitPrice(microLamports: UInt64) -> TransactionInstruction {
    /*
    {
      "discriminator": {
        "type": "u8",
        "data": 3
      },
      "microLamports": {
        "type": "u64",
        "data": 50000
      }
    }
     */
    return TransactionInstruction(keys: [], programId: programId, data: [UInt8(3), microLamports])
  }
}
