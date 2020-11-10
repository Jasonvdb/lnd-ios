//
//  LightningError.swift
//  wallet
//
//  Created by Jason van den Berg on 2020/09/12.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

enum LightningError: Error {
    case unknown
    case mapping
    case invalidPassword
    case paymentError(String)
}

extension LightningError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("LND_ERROR_UNKNOWN", comment: "LND error")
        case .mapping:
            return NSLocalizedString("LND_ERROR_MAPPING", comment: "LND error")
        case .invalidPassword:
            return NSLocalizedString("LND_ERROR_INVALID_PASSWORD", comment: "LND error")
        case .paymentError(let lndKey):
            //TODO get all possible error keys and create custom messages for them
            return String(format: NSLocalizedString("LND_ERROR_PAYMENT", comment: "LND error"), lndKey)
        }
    }
}
