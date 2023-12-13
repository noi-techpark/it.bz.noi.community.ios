// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  String+firstCharLowercased.swift
//  Core
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
