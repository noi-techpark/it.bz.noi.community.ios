//
//  Button+Noi.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

extension UIButton {
    
    @discardableResult func withText(
        _ text: String?,
        state: UIControl.State = .normal
    ) -> UIButton {
        setTitle(text, for: state)
        
        return self
    }
    
    @discardableResult func withDynamicType() -> UIButton {
        titleLabel?.numberOfLines = 0
        titleLabel?.adjustsFontForContentSizeCategory = true
        
        return self
    }
    
    @discardableResult func withTextStyle(
        _ textStyle: UIFont.TextStyle,
        weight: UIFont.Weight = .regular
    ) -> UIButton {
        titleLabel?.font = .preferredFont(
            forTextStyle: textStyle,
            weight: weight
        )
        
        return self
    }
    
    @discardableResult func withTextAligment(
        _ textAlignment: NSTextAlignment
    ) -> UIButton {
        titleLabel?.textAlignment = textAlignment
        
        return self
    }
    
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

    @discardableResult func configureAsSecondaryActionButton()  -> UIButton {
        titleLabel?.adjustsFontForContentSizeCategory = true

        titleLabel?.font = .preferredFont(
            forTextStyle: .body,
            weight: .semibold
        )
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center

        setTitleColor(.noiBackgroundColor, for: .normal)

        return self
    }

}

