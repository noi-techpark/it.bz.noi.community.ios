//
//  FooterView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

class FooterView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}

private extension FooterView {

    func configure() {
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.masksToBounds = false
        layer.shadowColor = UIColor.noiBackgroundColor.cgColor
        layer.shadowRadius = 5
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.16
    }
}
