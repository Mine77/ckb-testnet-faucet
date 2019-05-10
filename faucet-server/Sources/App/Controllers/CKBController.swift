//
//  CKB.swift
//  App
//
//  Created by 翟泉 on 2019/3/12.
//

import Foundation
import Vapor
import CKB

public struct CKBController: RouteCollection {
    public init() {
    }

    public func boot(router: Router) throws {
        router.post("ckb/faucet", use: faucet)
        router.get("ckb/address", use: address)
        router.get("ckb/address/random", use: makeRandomAddress)
    }

    // MARK: - API

    func faucet(_ req: Request) -> Response {
        let accessToken = req.http.cookies.all[accessTokenCookieName]?.string
        let verifyStatus = Authorization().verify(accessToken: accessToken)
        let result: [String: Any]

        if verifyStatus == .tokenIsVailable {
            let urlParameters = req.http.urlString.urlParametersDecode
            do {
                if let address = urlParameters["address"] {
                    let txHash = try faucet(address: address)
                    Authorization().recordCollectionDate(accessToken: accessToken!)
                    result = ["status": 0, "txHash": txHash]
                } else {
                     result = ["status": -3, "error": "No address"]
                }
            } catch {
                result = ["status": -4, "error": error.localizedDescription]
            }
        } else {
            result = ["status": verifyStatus.rawValue, "error": "Verify failed"]
        }

        return Response(http: HTTPResponse(body: HTTPBody(string: result.toJson)), using: req.sharedContainer)
    }

    func address(_ req: Request) -> Response {
        let urlParameters = req.http.urlString.urlParametersDecode
        let result: [String: Any]
        do {
            if let privateKey = urlParameters["privateKey"] {
                let address = try privateToAddress(privateKey)
                result = ["address": address, "status": 0]
            } else if let publicKey = urlParameters["publicKey"] {
                let address = try publicToAddress(publicKey)
                result = ["address": address, "status": 0]
            } else {
                result = ["status": -1, "error": "No public or private key"]
            }
        } catch {
            result = ["status": -2, "error": error.localizedDescription]
        }
        let headers = HTTPHeaders([("Access-Control-Allow-Origin", "*")])
        return Response(http: HTTPResponse(headers: headers, body: HTTPBody(string: result.toJson)), using: req.sharedContainer)
    }

    func makeRandomAddress(_ req: Request) -> Response {
        let privateKey = generatePrivateKey()
        let result: [String: Any] = [
            "privateKey": privateKey,
            "publicKey": try! privateToPublic(privateKey),
            "address": try! privateToAddress(privateKey)
        ]
        let headers = HTTPHeaders([("Access-Control-Allow-Origin", "*")])
        return Response(http: HTTPResponse(headers: headers, body: HTTPBody(string: result.toJson)), using: req.sharedContainer)
    }

    // MARK: - Utils

    public func faucet(address: String) throws -> H256 {
        let api = APIClient(url: URL(string: Environment.Process.nodeURL)!)
        guard let publicKeyHash = AddressGenerator(network: .testnet).publicKeyHash(for: address) else { throw Error.invalidAddress }
        let asw = try AlwaysSuccessWallet(api: api)
        let lock = Script(args: [publicKeyHash], codeHash: asw.systemScriptCellHash)
        return try asw.sendCapacity(targetLock: lock, capacity: 20000000000)
    }

    public func privateToAddress(_ privateKey: String) throws -> String {
        return try publicToAddress(try privateToPublic(privateKey))
    }

    public func publicToAddress(_ publicKey: String) throws -> String {
        if publicKey.hasPrefix("0x") && publicKey.lengthOfBytes(using: .utf8) == 68 {
            return AddressGenerator(network: .testnet).address(for: publicKey)
        } else if publicKey.lengthOfBytes(using: .utf8) == 66 {
            return AddressGenerator(network: .testnet).address(for: publicKey)
        } else {
            throw Error.invalidPublicKey
        }
    }

    public func privateToPublic(_ privateKey: String) throws -> String {
        if privateKey.hasPrefix("0x") && privateKey.lengthOfBytes(using: .utf8) == 66 {
            return Utils.publicToAddress(String(privateKey.dropFirst(2)))
        } else if privateKey.lengthOfBytes(using: .utf8) == 64 {
            return Utils.privateToPublic(privateKey)
        } else {
            throw Error.invalidPrivateKey
        }
    }

    public func generatePrivateKey() -> String {
        var data = Data(repeating: 0, count: 32)
        #if os(OSX)
            data.withUnsafeMutableBytes({ _ = SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress! ) })
        #else
            for idx in 0..<32 {
                data[idx] = UInt8.random(in: UInt8.min...UInt8.max)
            }
        #endif
        return data.toHexString()
    }
}

extension CKBController {
    enum Error: String, Swift.Error {
        case invalidPrivateKey = "Invalid privateKey"
        case invalidPublicKey = "Invalid publicKey"
        case invalidAddress = "Invalid address"
    }
}
