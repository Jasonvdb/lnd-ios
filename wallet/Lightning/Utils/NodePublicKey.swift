//
//  NodePublicKey.swift
//  wallet
//
//  Created by Jason van den Berg on 2020/08/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class NodePublicKey {
    enum NodePublicKeyErrors: Error {
        case invalidHexString
        case invalidByte
        case invalidByteLength
    }
    
    private let bytes: [UInt8]
    let hexString: String
    
    var data: Data {
        return Data(bytes)
    }
    
    init(_ hexString: String) throws {
        let length = hexString.count
        
        // Must start with 02 or 03 as according to SECP256K1
        guard hexString.hasPrefix("02") || hexString.hasPrefix("03") else {
            throw NodePublicKeyErrors.invalidHexString
        }
        
        // Must be even characters
        guard length & 1 == 0 else {
            throw NodePublicKeyErrors.invalidHexString
        }

        var bytes = [UInt8]()
        bytes.reserveCapacity(length / 2)

        var index = hexString.startIndex
        for _ in 0..<length / 2 {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                throw NodePublicKeyErrors.invalidByte
            }
            bytes.append(byte)
            index = nextIndex
        }

        // Must be 33 bytes in length for compressed bitcoin public key
        guard bytes.count == 33 else {
            throw NodePublicKeyErrors.invalidByteLength
        }
        
        self.bytes = bytes
        self.hexString = hexString
    }
}
