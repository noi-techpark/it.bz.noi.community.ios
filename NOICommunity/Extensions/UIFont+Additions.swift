//
//  UIFont+Additions.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//  Copyright © 2019 DIMENSION S.r.l. All rights reserved.
//

import UIKit

extension UIFont {
    open class var keepSize: CGFloat {
        0
    }

    public static func preferredFont(forTextStyle textStyle: TextStyle,
                                     traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let desc = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: textStyle)
            .withSymbolicTraits(traits)
        return UIFont(descriptor: desc!, size: Self.keepSize)
    }

    public static func preferredFont(forTextStyle textStyle: TextStyle,
                                     weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }

    public static func preferredMonospacedDigitSystemFont(forTextStyle textStyle: TextStyle,
                                                          weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let font = UIFont.monospacedDigitSystemFont(ofSize: desc.pointSize,
                                                    weight: weight)
        return metrics.scaledFont(for: font)
    }

    @available(iOS 13.0, *)
    public static func preferredMonospacedSystemFont(forTextStyle textStyle: TextStyle,
                                                     weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let font = UIFont.monospacedSystemFont(ofSize: desc.pointSize,
                                               weight: weight)
        return metrics.scaledFont(for: font)
    }
}
