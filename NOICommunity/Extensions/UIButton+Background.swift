//
//  UIButton+Background.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/10/21.
//

import UIKit

extension UIButton {
    // https://stackoverflow.com/questions/14523348/how-to-change-the-background-color-of-a-uibutton-while-its-highlighted
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { context in
            color.setFill()
            context.fill(rect)
        }
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}
