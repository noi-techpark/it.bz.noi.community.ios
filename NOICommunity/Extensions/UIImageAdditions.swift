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
    
    static func image(
        withBackgroundColor backgroundColor: UIColor,
        strokeColor strokeColorOrNil: UIColor?,
        lineWidth: CGFloat
    ) -> UIImage? {
        let rect = CGRect(
            origin: .zero,
            size: CGSize(
                width: 1 + lineWidth * 2,
                height: 1 + lineWidth * 2
            )
        )
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(rect)
            
            if let strokeColor = strokeColorOrNil {
                strokeColor.setStroke()
                context.cgContext.setLineWidth(lineWidth)
                context.stroke(rect)
            }
        }.stretchableImage(
            withLeftCapWidth: Int(lineWidth),
            topCapHeight: Int(lineWidth)
        )
    }
    
}
