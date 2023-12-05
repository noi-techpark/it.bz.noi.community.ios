// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  JSONDecoder.KeyDecodingStrategy+PascalCase.swift
//  Core
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Foundation

// MARK: - JSONDecoder.KeyDecodingStrategy+PascalCase

public extension JSONDecoder.KeyDecodingStrategy {
    
    static var convertFromPascalCase: JSONDecoder.KeyDecodingStrategy {
        .custom { keys -> CodingKey in
            // keys array is never empty
            let key = keys.last!
            // Do not change the key for an array
            guard key.intValue == nil else {
                return key
            }
            
            let stringValue = key.stringValue
            let newStringValue = stringValue.firstCharLowercased()
            
            let codingKeyType = type(of: key)
            return codingKeyType.init(stringValue: newStringValue)!
        }
    }
    
}
