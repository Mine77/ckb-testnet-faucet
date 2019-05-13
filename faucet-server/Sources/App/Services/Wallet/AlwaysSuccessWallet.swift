//
//  AlwaysSuccessAccount.swift
//  App
//
//  Created by 翟泉 on 2019/3/29.
//

import Foundation
import CKB
import Vapor

public class AlwaysSuccessWallet: Wallet {
    override public var lock: Script {
        return Script.alwaysSuccess
    }

    public init(api: APIClient) throws {
        try super.init(api: api, privateKey: Environment.Process.minerPrivateKey)
    }

    override func gatherInputs(capacity: Decimal, minCapacity: Decimal = minCellCapacity) throws -> ValidInputs {
        let validInputs = try super.gatherInputs(capacity: capacity, minCapacity: minCapacity)
        let cellInputs = validInputs.cellInputs.map { CellInput(previousOutput: $0.previousOutput, args: [], since: "0") }
        return ValidInputs(cellInputs: cellInputs, capacity: validInputs.capacity)
    }
}