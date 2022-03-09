//
//  UIButton+Background.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

extension UIButton {

    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        let backgroundImageOrNil = color
            .flatMap { UIImage.image(withColor: $0) }
        self.setBackgroundImage(backgroundImageOrNil, for: state)
    }
}
