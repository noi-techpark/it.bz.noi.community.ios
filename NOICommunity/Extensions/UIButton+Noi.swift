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
    
    @discardableResult func withTintColor(
        _ tintColor: UIColor?
    ) -> UIButton {
        self.tintColor = tintColor
        
        return self
    }
    
    @discardableResult func withDynamicType(numberOfLines: Int = 0) -> UIButton {
        titleLabel?.numberOfLines = numberOfLines
        titleLabel?.adjustsFontForContentSizeCategory = true
        adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        return self
    }
    
    @discardableResult func withFont(_ font: UIFont) -> UIButton {
        titleLabel?.font = font
        
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
        contentEdgeInsets: UIEdgeInsets? = nil
    ) -> UIButton {
        setBackgroundColor(backgroundColor, for: .normal)
        
        if let contentEdgeInsets = contentEdgeInsets {
            self.contentEdgeInsets = contentEdgeInsets
        }
        
        return self
    }
    
    @discardableResult func configureAsRectangleButton(
        withBackgroundColor backgroundColor: UIColor,
        strokeColor: UIColor?,
        lineWidth: CGFloat,
        contentEdgeInsets: UIEdgeInsets? = nil
    ) -> UIButton {
        setBackgroundColor(
            backgroundColor,
            strokeColor: strokeColor,
            lineWidth: lineWidth,
            for: .normal
        )
        
        if let contentEdgeInsets = contentEdgeInsets {
            self.contentEdgeInsets = contentEdgeInsets
        }
        
        return self
    }
    
    @discardableResult func withMinimumHeight(
        _ minHeight: CGFloat
    ) -> UIButton {
        let id = "button-minimum-height-constraint"
        
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
    
    @discardableResult func withMaximumHeight(
        _ maxHeight: CGFloat
    ) -> UIButton {
        let id = "button-maximum-height-constraint"
        
        var minHeightConstraint: NSLayoutConstraint! = constraints
            .first { $0.identifier == id }
        if minHeightConstraint == nil {
            minHeightConstraint = heightAnchor
                .constraint(lessThanOrEqualToConstant: maxHeight)
            minHeightConstraint.identifier = id
        }
        minHeightConstraint.constant = maxHeight
        minHeightConstraint.isActive = true
        
        return self
    }
    
    @discardableResult func configureAsFooterButton(
        numberOfLines: Int = 0
    )  -> UIButton {
        self
            .withMinimumHeight(50)
            .withMaximumHeight(150)
            .withTextAligment(.center)
            .withDynamicType(numberOfLines: numberOfLines)
            .withFont(.NOI.dynamic.bodySemibold)
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
            .withTintColor(.noiPrimaryColor)
    }
    
    @discardableResult func configureAsSecondaryActionButton(
        numberOfLines: Int = 0,
        contentEdgeInsets: UIEdgeInsets? = nil
    )  -> UIButton {
        self
            .configureAsFooterButton(numberOfLines: numberOfLines)
            .configureAsRectangleButton(
                withBackgroundColor: .clear,
                strokeColor: .noiSecondaryColor,
                lineWidth: 1,
                contentEdgeInsets: contentEdgeInsets
            )
            .withTitleColor(.noiSecondaryColor)
            .withTintColor(.noiSecondaryColor)
    }
    
    @discardableResult func configureAsTertiaryActionButton()  -> UIButton {
        self
            .configureAsFooterButton()
            .withTitleColor(.noiBackgroundColor)
    }
    
}

