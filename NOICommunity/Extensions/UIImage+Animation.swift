// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIImage+Animation.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 30/05/22.
//

import UIKit

extension UIImageView{
    
    func setImage(
        _ image: UIImage?,
        animated: Bool,
        duration: TimeInterval = 0.3
    ) {
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.image = image
            },
            completion: nil
        )
    }
    
}
