// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  RoundedLabel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/05/2022.
//

import UIKit

@IBDesignable
open class HighlightLabel: UILabel {
    @IBInspectable
    open var normalBackgroundColor: UIColor? {
        didSet {
            if normalBackgroundColor != oldValue {
                update()
            }
        }
    }

    @IBInspectable
    open var highlightedBackgroundColor: UIColor? {
        didSet {
            if highlightedBackgroundColor != oldValue {
                update()
            }
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted != oldValue {
                update()
            }
        }
    }

    fileprivate func update() {
        backgroundColor = isHighlighted ? highlightedBackgroundColor : normalBackgroundColor
    }
}

@IBDesignable open class RoundedLabel: HighlightLabel {
    fileprivate var _cornerRadius: CGFloat = 0

    @IBInspectable
    open var cornerRadius: CGFloat {
        get {
            _cornerRadius
        }
        set {
            _cornerRadius = max(0, newValue)
        }
    }

    open var textInsets: UIEdgeInsets = .zero {
        didSet {
            if textInsets != oldValue {
                setNeedsDisplay()
            }
        }
    }

    fileprivate var rectColor: UIColor? {
        didSet {
            if rectColor != oldValue {
                setNeedsDisplay()
            }
        }
    }

    override open var backgroundColor: UIColor? {
        get {
            rectColor
        }
        set {
            rectColor = newValue
            super.backgroundColor = nil
        }
    }

    override open var intrinsicContentSize: CGSize {
        let superIntrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: superIntrinsicContentSize.width + textInsets.left + textInsets.right,
                      height: superIntrinsicContentSize.height + textInsets.top + textInsets.bottom)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        return CGSize(width: superSizeThatFits.width +
            textInsets.left +
            textInsets.right,
            height: superSizeThatFits.height +
                textInsets.top +
                textInsets.bottom)
    }

    override open func draw(_ rect: CGRect) {
        guard cornerRadius > 0,
              let color = rectColor
        else { return super.draw(rect) }

        let roundedRect = UIBezierPath(roundedRect: bounds,
                                       cornerRadius: cornerRadius)
        color.setFill()
        roundedRect.fill()

        drawText(in: bounds.inset(by: textInsets))
    }
}

// MARK: Interface Builder Helpers

#if !TARGET_INTERFACE_BUILDER
    extension RoundedLabel {
        @IBInspectable
        open var topTextInset: CGFloat {
            get {
                textInsets.top
            }
            set {
                var textInsets = textInsets
                textInsets.top = newValue
                self.textInsets = textInsets
            }
        }

        @IBInspectable
        open var leftTextInset: CGFloat {
            get {
                textInsets.left
            }
            set {
                var textInsets = textInsets
                textInsets.left = newValue
                self.textInsets = textInsets
            }
        }

        @IBInspectable
        open var bottomTextInset: CGFloat {
            get {
                textInsets.bottom
            }
            set {
                var textInsets = textInsets
                textInsets.bottom = newValue
                self.textInsets = textInsets
            }
        }

        @IBInspectable
        open var rightTextInset: CGFloat {
            get {
                textInsets.right
            }
            set {
                var textInsets = textInsets
                textInsets.right = newValue
                self.textInsets = textInsets
            }
        }
    }
#endif
