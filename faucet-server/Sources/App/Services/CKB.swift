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
    }
    
    func faucet(address: String) throws -> H256? {
        let asw = try AlwaysSuccessAccount(api: api)
        return try asw.sendCapacity(targetLock: Script.verifyScript(for: address, binaryHash: ""), capacity: 10000)
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

//let expect = H256::from_hex_str("32a3cc6b5b56017262abe1e3898bc56b7ac3fa540570d8c39e7bd3db136d1480").unwrap();
//if transaction.hash() == expect {
//    let hash = output.lock.hash();
//    print!("\nlock_hash\n");
//    print!("{}\n", hash);
//    print!("{}\n", lock_hash);
//    print!("\n");
//    if hash == lock_hash {
//        println!("yyyyyyy-hash");
//    } else {
//        println!("nnnnnnn-hash");
//    }
//    if (!transaction_meta.is_dead(i)) {
//        print!("yyyyyyy-meta");
//    } else {
//        print!("nnnnnnn-meta");
//    }
//    print!("\n");
//}
