// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MessageViewController+Error.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 17/05/22.
//

import Foundation

extension MessageViewController {
    
    convenience init(error: Error) {
        let message: Message
        
        if let localizedError = error as? LocalizedError,
            let errorDescription = localizedError.errorDescription {
            let detailedTextComponents = [
                localizedError.failureReason,
                localizedError.recoverySuggestion
            ]
                .compactMap { $0 }
            
            message = .init(
                text: errorDescription,
                detailedText: detailedTextComponents.isEmpty
                ? nil
                : detailedTextComponents.joined(separator: "\n\n"),
                image: nil,
                action: nil)
        } else {
            message = Message(
                text: error.localizedDescription,
                detailedText: nil,
                image: nil,
                action: nil
            )
        }

        self.init(message: message)
    }
    
}
