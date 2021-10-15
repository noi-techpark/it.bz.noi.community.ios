//
//  Button.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

extension UIButton {
    @discardableResult func configureAsRectangleButton(
        withBackgroundColor backgroundColor: UIColor,
        contentEdgeInsets: UIEdgeInsets = .zero
    ) -> UIButton {
        titleLabel?.adjustsFontForContentSizeCategory = true
        setBackgroundColor(backgroundColor, for: .normal)
        self.contentEdgeInsets = contentEdgeInsets
        return self
    }

    @discardableResult func configureAsActionButton(
        minHeight: CGFloat = 50
    )  -> UIButton {
        configureAsRectangleButton(
            withBackgroundColor: .noiBackgroundColor,
            contentEdgeInsets: .init(top: 12, left: 12, bottom: 12, right: 12)
        )

        let id = "button-height-constraint"
        if !constraints.contains(where: { $0.identifier == id }) {
            let heightConstraint = heightAnchor
                .constraint(greaterThanOrEqualToConstant: minHeight)
            heightConstraint.identifier = id
            heightConstraint.isActive = true
        }

        titleLabel?.font = .preferredFont(
            forTextStyle: .body,
            weight: .semibold
        )
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center

        setTitleColor(.noiPrimaryColor, for: .normal)

        return self
    }

}

