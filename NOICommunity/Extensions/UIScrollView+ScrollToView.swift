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

public extension UIScrollView {

    func scrollToView(
        view: UIView,
        position: UITableView.ScrollPosition = .top,
        animated: Bool
    ) {
        if position == .none && bounds.intersects(view.frame) {
            return
        }

        guard let origin = view.superview
        else { return }

        let childStartPoint = origin.convert(view.frame.origin, to: self)
        let scrollPointY: CGFloat
        switch position {
        case .bottom:
            let childEndY = childStartPoint.y + view.frame.height
            scrollPointY = .maximum(childEndY - frame.size.height, 0)
        case .middle:
            let childCenterY = childStartPoint.y + view.frame.height / 2.0
            let scrollViewCenterY = frame.size.height / 2.0
            scrollPointY = .maximum(childCenterY - scrollViewCenterY, 0)
        default:
            scrollPointY = childStartPoint.y
        }

        let targetRect = CGRect(
            x: 0,
            y: scrollPointY,
            width: 1,
            height: frame.height
        )
        scrollRectToVisible(targetRect, animated: animated)
    }
}

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
