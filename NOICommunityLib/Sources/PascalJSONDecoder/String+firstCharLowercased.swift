//
//  String+firstCharLowercased.swift
//  PascalJSONDecoder
//
//  Created by Matteo Matassoni on 11/03/22.
//

import Foundation

// MARK: - String+firstCharLowercased

extension String {

    func firstCharLowercased() -> String {
        prefix(1).lowercased() + dropFirst()
    }

}
