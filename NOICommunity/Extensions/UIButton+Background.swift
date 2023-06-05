// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIButton+Background.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

extension UIButton {
    
    func setBackgroundColor(
        _ backgroundColor: UIColor?,
        for state: UIControl.State
    ) {
        let backgroundImageOrNil = backgroundColor
            .flatMap { UIImage.image(withColor: $0) }
        setBackgroundImage(backgroundImageOrNil, for: state)
    }
    
    func setBackgroundColor(
        _ backgroundColor: UIColor,
        strokeColor: UIColor?,
        lineWidth: CGFloat,
        for state: UIControl.State
    ) {
        let backgroundImage = UIImage.image(
            withBackgroundColor: backgroundColor,
            strokeColor: strokeColor,
            lineWidth: lineWidth
        )
        setBackgroundImage(backgroundImage, for: state)
    }
    
}
