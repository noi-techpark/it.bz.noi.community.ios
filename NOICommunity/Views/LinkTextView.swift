// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  LinkTextView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/12/23.
//

import UIKit

class LinkTextView: UITextView {

    override var selectedTextRange: UITextRange? {
        get { nil }
        set {}
    }

    override func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {

        switch gestureRecognizer {
        case is UIPanGestureRecognizer:
            // To still support scrolling
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        case let tapGestureRecognizer as UITapGestureRecognizer where tapGestureRecognizer.numberOfTapsRequired == 1:
            // To still support link tap
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        case let longPressGestureRecognizer as UILongPressGestureRecognizer where
            longPressGestureRecognizer.minimumPressDuration < 0.3:
            // To still support link but not text selection/zoom
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        default:
            gestureRecognizer.isEnabled = false
            return false
        }
    }
}
