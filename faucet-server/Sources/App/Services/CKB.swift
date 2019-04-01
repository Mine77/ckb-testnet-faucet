//
//  CKBService.swift
//  App
//
//  Created by 翟泉 on 2019/3/12.
//

import Foundation
import CKB

class CKB {
    let api: APIClient

    static var shared = CKB()

    init() {
        api = APIClient()
        api.setMrubyConfig(
            outPoint: OutPoint(hash: "0xe33e7492d412979a96f55c9158aa89b7ae96ffa6410055bd63ff4a171b936b8b", index: 0),
            cellHash: "0x00ccb858f841db7ece8833a77de158b84af4c8f43a69dbb0f43de87faabfde32"
        )
    }

    func faucet(address: String) throws -> H256? {
        return nil
//        let asw = try AlwaysSuccessAccount(api: api)
//        return try asw.sendCapacity(targetAddress: address, capacity: 10000)
    }

    static func privateToAddress(_ privateKey: String) throws -> String {
        if privateKey.hasPrefix("0x") && privateKey.lengthOfBytes(using: .utf8) == 66 {
            return Utils.privateToAddress(String(privateKey.dropFirst(2)))
        } else if privateKey.lengthOfBytes(using: .utf8) == 64 {
            return Utils.privateToAddress(privateKey)
        } else {
            throw Error.invalidPrivateKey
        }
    }

    static func publicToAddress(_ publicKey: String) throws -> String {
        if publicKey.hasPrefix("0x") && publicKey.lengthOfBytes(using: .utf8) == 68 {
            return Utils.publicToAddress(String(publicKey.dropFirst(2)))
        } else if publicKey.lengthOfBytes(using: .utf8) == 66 {
            return Utils.publicToAddress(publicKey)
        } else {
            throw Error.invalidPrivateKey
        }
    }

    static func privateToPublic(_ privateKey: String) throws -> String {
        if privateKey.hasPrefix("0x") && privateKey.lengthOfBytes(using: .utf8) == 66 {
            return Utils.privateToPublic(String(privateKey.dropFirst(2)))
        } else if privateKey.lengthOfBytes(using: .utf8) == 64 {
            return Utils.privateToPublic(privateKey)
        } else {
            throw Error.invalidPrivateKey
        }
    }

    static func generatePrivateKey() -> String {
        var data = Data(repeating: 0, count: 32)
        data.withUnsafeMutableBytes({ _ = SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress! ) })
        return data.toHexString()
    }
}

extension CKB {
    enum Error: String, Swift.Error {
        case invalidPrivateKey = "Invalid privateKey"
        case invalidPublicKey = "Invalid publicKey"
    }
}
