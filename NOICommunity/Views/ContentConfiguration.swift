//
//  ContentConfiguration.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 31/05/22.
//

import UIKit

enum ContentConfiguration {
    
    struct TextProperties: Hashable {
        
        /// The maximum number of lines for the text.
        var numberOfLines: Int
        
        /// The transform to apply to the text.
        var transform: UIListContentConfiguration.TextProperties.TextTransform
        
        /// The font for the text
        var font: UIFont
        
        init(
            numberOfLines: Int = 0,
            transform: UIListContentConfiguration.TextProperties.TextTransform = .none,
            font: UIFont = .preferredFont(forTextStyle: .body)
        ) {
            self.numberOfLines = numberOfLines
            self.transform = transform
            self.font = font
        }
    }
}

// MARK: - UILabel+setAttributedText

extension UILabel {
    
    func setText(
        _ textInfos: (NSAttributedString?, String?),
        textProperties: ContentConfiguration.TextProperties
    ) {
        let (attributedTextOrNil, textOrNil) = textInfos
        
        if var attributedText = attributedTextOrNil {
            switch textProperties.transform {
            case .none:
                break
            case .capitalized:
                attributedText = attributedText.capitalized()
            case .lowercase:
                attributedText = attributedText.lowercased()
            case .uppercase:
                attributedText = attributedText.uppercased()
            @unknown default:
                break
            }
            
            self.attributedText = attributedText
        } else if var text = textOrNil {
            switch textProperties.transform {
            case .none:
                break
            case .capitalized:
                text = text.capitalized
            case .lowercase:
                text = text.lowercased()
            case .uppercase:
                text = text.uppercased()
            @unknown default:
                break
            }
            
            self.text = text
        } else {
            text = nil
        }
        
        numberOfLines = textProperties.numberOfLines
        font = textProperties.font
    }
    
}

extension NSAttributedString {
    
    func capitalized() -> NSAttributedString {
        transform { $0.capitalized }
    }
    
    func uppercased() -> NSAttributedString {
        transform { $0.uppercased() }
    }
    
    func lowercased() -> NSAttributedString {
        transform { $0.lowercased()}
    }
    
    private func transform(_ block: (String) -> String) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        
        enumerateAttributes(
            in: NSRange(location: 0, length: length),
            options: [.longestEffectiveRangeNotRequired]
        ) { _, range, _ in
            let currentText = (string as NSString).substring(with: range)
            result.replaceCharacters(in: range, with: block(currentText))
        }
        
        return result
    }
    
}
