//
//  AccountError.swift
//  App
//
//  Created by 翟泉 on 2019/3/29.
//

import Foundation
import CKB

enum AccountError: LocalizedError {
    case tooLowCapacity(min: Capacity)
    case notEnoughCapacity(required: Capacity, available: Capacity)

    var localizedDescription: String {
        switch self {
        case .tooLowCapacity(let min):
            return "Capacity cannot less than \(min)"
        case .notEnoughCapacity(let required, let available):
            return "Not enough capacity, required: \(required), available: \(available)"
        }
    }
}
