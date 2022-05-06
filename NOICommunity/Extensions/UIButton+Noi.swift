//
//  Button+Noi.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

extension UIButton {
    
    @discardableResult func withTitle(
        _ title: String?,
        state: UIControl.State = .normal
    ) -> UIButton {
        setTitle(title, for: state)
        
        return self
    }
    
    @discardableResult func withTitleColor(
        _ color: UIColor?,
        state: UIControl.State = .normal
    ) -> UIButton {
        setTitleColor(color, for: state)
        
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
        setBackgroundColor(backgroundColor, for: .normal)
        
        self.contentEdgeInsets = contentEdgeInsets
        
        return self
    }
    
    @discardableResult func configureAsRectangleButton(
        withBackgroundColor backgroundColor: UIColor,
        strokeColor: UIColor?,
        lineWidth: CGFloat,
        contentEdgeInsets: UIEdgeInsets = .zero
    ) -> UIButton {
        setBackgroundColor(
            backgroundColor,
            strokeColor: strokeColor,
            lineWidth: lineWidth,
            for: .normal
        )
        
        self.contentEdgeInsets = contentEdgeInsets
        
        return self
    }
    
    @discardableResult func withMinimumHeight(
        _ minHeight: CGFloat = 50
    ) -> UIButton {
        let id = "button-height-constraint"
        
        var minHeightConstraint: NSLayoutConstraint! = constraints
            .first { $0.identifier == id }
        if minHeightConstraint == nil {
            minHeightConstraint = heightAnchor
                .constraint(greaterThanOrEqualToConstant: minHeight)
            minHeightConstraint.identifier = id
        }
        minHeightConstraint.constant = minHeight
        minHeightConstraint.isActive = true
        
        return self
    }
    
    @discardableResult func configureAsFooterButton()  -> UIButton {
        self
            .withMinimumHeight(50)
            .withTextAligment(.center)
            .withDynamicType()
            .withTextStyle(.body, weight: .semibold)
    }
    
    @discardableResult func configureAsPrimaryActionButton()  -> UIButton {
        self
            .configureAsFooterButton()
            .configureAsRectangleButton(
                withBackgroundColor: .noiBackgroundColor,
                contentEdgeInsets: .init(
                    top: 12,
                    left: 12,
                    bottom: 12,
                    right: 12
                )
            )
            .withTitleColor(.noiPrimaryColor)
    }
    
    @discardableResult func configureAsSecondaryActionButton()  -> UIButton {
        self
            .configureAsFooterButton()
            .configureAsRectangleButton(
                withBackgroundColor: .clear,
                strokeColor: .noiSecondaryColor,
                lineWidth: 1,
                contentEdgeInsets: .init(
                    top: 12,
                    left: 12,
                    bottom: 12,
                    right: 12
                )
            )
            .withTitleColor(.noiSecondaryColor)
    }
    
    @discardableResult func configureAsTertiaryActionButton()  -> UIButton {
        self
            .configureAsFooterButton()
            .withTitleColor(.noiBackgroundColor)
    }
    
}

