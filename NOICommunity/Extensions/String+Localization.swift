//
//  File.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/21.
//

import Foundation

extension String {
    static func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
