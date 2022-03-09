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
