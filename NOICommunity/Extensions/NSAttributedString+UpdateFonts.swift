//
//  NSAttributedString+UpdateFonts.swift
//  HTMLAttrbutedString
//
//  Created by Matteo Matassoni on 04/03/22.
//

import UIKit

public extension NSAttributedString {

    func updatedFonts(usingTextStyle textStyle: UIFont.TextStyle) -> NSAttributedString {
        let mSelf = NSMutableAttributedString(attributedString: self)
        enumerateAttribute(
            .font,
            in: NSMakeRange(0, length),
            options: [.longestEffectiveRangeNotRequired]
        ) { value, range, stop in
            guard let font = value as? UIFont
            else { return }

            let userFont = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
            let pointSize = userFont.withSize(font.pointSize)
            let customFont: UIFont
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                customFont = UIFont.boldSystemFont(ofSize: pointSize.pointSize)
            } else {
                customFont = UIFont.systemFont(ofSize: pointSize.pointSize)
            }
            let dynamicText = UIFontMetrics.default.scaledFont(for: customFont)
            mSelf.addAttribute(
                .font,
                value: dynamicText,
                range: range
            )
        }
        return NSAttributedString(attributedString: mSelf)
    }
    
    func updatedFonts2(usingTextStyle textStyle: UIFont.TextStyle) -> NSAttributedString {
        let mSelf = NSMutableAttributedString(attributedString: self)
        enumerateAttribute(
            .font,
            in: NSMakeRange(0, length),
            options: [.longestEffectiveRangeNotRequired]
        ) { value, range, stop in
            guard let font = value as? UIFont
            else { return }

            let newFont = UIFont.preferredFont(
                forTextStyle: textStyle,
                traits: font.fontDescriptor.symbolicTraits
            )
            mSelf.addAttribute(
                .font,
                value: newFont,
                range: range
            )
        }
        return NSAttributedString(attributedString: mSelf)
    }
    
}
