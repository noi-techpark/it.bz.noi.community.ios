// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIAlertController+Error.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/2021.
//

import UIKit

extension UIAlertController {
    
    convenience init(
        error: Error,
        preferredStyle: UIAlertController.Style
    ) {
        var title = error.localizedDescription
        var message: String?
        if
            let localizedError = error as? LocalizedError,
            let errorDescription = localizedError.errorDescription {
            title = errorDescription
            message = [
                localizedError.failureReason,
                localizedError.recoverySuggestion
            ]
            .compactMap { $0 }
            .joined(separator: "\n\n")
        }

        self.init(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
    }
    
}
