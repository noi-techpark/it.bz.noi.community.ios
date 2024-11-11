// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIScrollView+ScrollToView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 10/03/22.
//

import UIKit

extension UIScrollView {
    enum ScrollDirection {
        case top, bottom, left, right
    }

    func contentOffset(for direction: ScrollDirection) -> CGPoint {
        switch direction {
        case .top:
            return CGPoint(x: contentOffset.x,
                           y: -adjustedContentInset.top)
        case .bottom:
            return CGPoint(x: contentOffset.x,
                           y: contentSize.height - bounds.size.height)
        case .left:
            return CGPoint(x: -adjustedContentInset.left,
                           y: contentOffset.y)
        case .right:
            return CGPoint(x: contentSize.width - bounds.size.width,
                           y: contentOffset.y)
        }
    }

    func scrollTo(direction: ScrollDirection,
                  animated: Bool = true) {
        setContentOffset(contentOffset(for: direction), animated: animated)
    }
}
