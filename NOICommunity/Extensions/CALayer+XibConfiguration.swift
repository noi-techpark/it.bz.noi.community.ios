//
//  CALayer+XibConfiguration.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 26/05/22.
//

import UIKit
import QuartzCore

extension CALayer {
    
    @objc var borderUIColor: UIColor? {
        get {
            borderColor.flatMap { UIColor(cgColor: $0) }
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
    
}
