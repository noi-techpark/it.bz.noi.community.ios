// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  File.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 01/10/21.
//

import UIKit

private var transitionContext: UInt8 = 0

extension UIView {

    private func synchronized<T>(_ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }

    var transitionId: String? {
        get {
            synchronized {
                guard let transitionId = objc_getAssociatedObject(self, &transitionContext) as? String
                else { return nil }

                return transitionId
            }
        }

        set {
            synchronized {
                objc_setAssociatedObject(self, &transitionContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    func view(withTransitionId transitionId: String) -> UIView? {
        recursiveSubviews { $0.transitionId == transitionId }.first
    }
}
