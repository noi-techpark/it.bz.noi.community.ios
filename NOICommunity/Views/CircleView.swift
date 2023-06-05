// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CircleView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import UIKit

@IBDesignable class CircleView: UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let edge = min(frame.width, frame.height)
        layer.cornerRadius = edge / 2
        layer.masksToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
    }
}
