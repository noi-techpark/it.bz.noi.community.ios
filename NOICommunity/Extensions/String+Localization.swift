// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  String+Localization.swift
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
