//
//  CircleView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import UIKit

@IBDesignable class CircleView: UIView {

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
