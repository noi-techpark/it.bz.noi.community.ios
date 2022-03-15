//
//  UIImageAdditions.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 09/03/22.
//

import UIKit

public extension UIImage {

    static func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { context in
            color.setFill()
            context.fill(rect)
        }
    }

}
