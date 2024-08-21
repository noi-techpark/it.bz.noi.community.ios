// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Initial.swift
//  Core
//
//  Created by Matteo Matassoni on 21/08/24.
//

import Foundation

// MARK: - Initial

public struct Initial: Hashable {

    public let value: String

    public static let other = Initial("#")

    private init(_ value: String) {
        self.value = value
    }

    public init(from text: String) {
        guard let firstChar = text
                // Trim spaces and new lines
            .trimmingCharacters(in: .whitespacesAndNewlines)
                // Remove diacritics
            .applyingTransform(.stripDiacritics, reverse: false)?
            .first
        else { self = .other; return }

        let value = String(firstChar)

        let isLetter = value.rangeOfCharacter(from: .letters.inverted) == nil
        guard isLetter
        else { self = .other; return }

        self.init(value)
    }

}

extension Initial: Comparable {

    public static func <(lhs: Initial, rhs: Initial) -> Bool {
        lhs.value.localizedCaseInsensitiveCompare(rhs.value) == .orderedAscending
    }
    
}
