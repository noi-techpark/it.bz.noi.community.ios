// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIViewController+EmptyState.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/06/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    static func emptyViewController(
        text: String = .localized("label_empty_state_title"),
        detailedText: String? = nil
    ) -> MessageViewController {
        MessageViewController(text: text, detailedText: detailedText)
    }
    
}
