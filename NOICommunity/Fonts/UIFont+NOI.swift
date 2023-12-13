// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIFont+Noi.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 29/06/22.
//

import UIKit

extension UIFont {
    
    class func noiFont(ofSize fontSize: CGFloat) -> UIFont {
        guard let noiFont = UIFont(
            name: "SourceSansPro-Regular",
            size: fontSize
        )
        else {
            fatalError("""
                Failed to load the "SourceSansPro-Regular" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        
        return noiFont
    }
    
    class func noiItalicFont(ofSize fontSize: CGFloat) -> UIFont {
        guard let noiItalicFont = UIFont(
            name: "SourceSansPro-Italic",
            size: fontSize
        )
        else {
            fatalError("""
                Failed to load the "SourceSansPro-Italic" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        
        return noiItalicFont
    }
    
    
    class func noiBoldFont(ofSize fontSize: CGFloat) -> UIFont {
        guard let noiSemiboldFont = UIFont(
            name: "SourceSansPro-Bold",
            size: fontSize
        )
        else {
            fatalError("""
            Failed to load the "SourceSansPro-Bold" font.
            Make sure the font file is included in the project and the font name is spelled correctly.
            """
            )
        }
        
        return noiSemiboldFont
    }
    
    class func noiSemiboldFont(ofSize fontSize: CGFloat) -> UIFont {
        guard let noiSemiboldFont = UIFont(
            name: "SourceSansPro-SemiBold",
            size: fontSize
        )
        else {
            fatalError("""
            Failed to load the "SourceSansPro-SemiBold" font.
            Make sure the font file is included in the project and the font name is spelled correctly.
            """
            )
        }
        
        return noiSemiboldFont
    }
    
    private class func noiPreferredFont(
        forTextStyle style: UIFont.TextStyle,
        withFontSize size: CGFloat
    ) -> UIFont {
        UIFontMetrics(forTextStyle: style)
            .scaledFont(for: noiFont(ofSize: size))
    }
    
    private class func noiPreferredBoldFont(
        forTextStyle style: UIFont.TextStyle,
        withFontSize size: CGFloat
    ) -> UIFont {
        UIFontMetrics(forTextStyle: style)
            .scaledFont(for: noiBoldFont(ofSize: size))
    }
    
    private class func noiPreferredSemiboldFont(
        forTextStyle style: UIFont.TextStyle,
        withFontSize size: CGFloat
    ) -> UIFont {
        UIFontMetrics(forTextStyle: style)
            .scaledFont(for: noiSemiboldFont(ofSize: size))
    }
    
}

extension UIFont {
    
    enum NOI {
        
        enum `dynamic` {
            
            static var subheadlineRegular: UIFont {
                .noiPreferredFont(forTextStyle: .subheadline, withFontSize: 19)
            }
            
            static var bodyRegular: UIFont {
                .noiPreferredFont(forTextStyle: .body, withFontSize: 17)
            }
            
            static var bodyBold: UIFont {
                .noiPreferredBoldFont(forTextStyle: .body, withFontSize: 17)
            }
            
            static var bodySemibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .body, withFontSize: 19)
            }
            
            static var footnoteSemibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .footnote, withFontSize: 17)
            }
            
            static var caption1Regular: UIFont {
                .noiPreferredFont(forTextStyle: .caption1, withFontSize: 14)
            }
            
            static var caption2Regular: UIFont {
                .noiPreferredFont(forTextStyle: .caption1, withFontSize: 13)
            }
            
            static var caption1Bold: UIFont {
                .noiPreferredBoldFont(forTextStyle: .footnote, withFontSize: 14)
            }
            
            static var caption1Semibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .footnote, withFontSize: 14)
            }
            
            static var caption2Semibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .caption2, withFontSize: 13)
            }
            
            static var headlineSemibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .headline, withFontSize: 25)
            }
            
            static var title0Semibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .title1, withFontSize: 25)
            }
            
            static var title1Semibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .title1, withFontSize: 40)
            }
            
            static var title2Semibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .title2, withFontSize: 33)
            }
            
            static var title3Semibold: UIFont {
                .noiPreferredSemiboldFont(forTextStyle: .title3, withFontSize: 25)
            }
            
        }
        
        enum fixed {
            
            static var subheadlineRegular: UIFont {
                .noiFont(ofSize: 19)
            }
            
            static var bodyRegular: UIFont {
                .noiFont(ofSize: 17)
            }
            
            static var bodyBold: UIFont {
                .noiBoldFont(ofSize: 17)
            }
            
            static var bodySemibold: UIFont {
                .noiSemiboldFont(ofSize: 19)
            }
            
            static var footnoteSemibold: UIFont {
                .noiSemiboldFont(ofSize: 17)
            }
            
            static var caption1Regular: UIFont {
                .noiFont(ofSize: 14)
            }
            
            static var caption2Regular: UIFont {
                .noiFont(ofSize: 13)
            }
            
            static var caption1Bold: UIFont {
                .noiBoldFont(ofSize: 14)
            }
            
            static var caption1Semibold: UIFont {
                .noiSemiboldFont(ofSize: 14)
            }
            
            static var caption2Semibold: UIFont {
                .noiSemiboldFont(ofSize: 13)
            }
            
            static var headlineSemibold: UIFont {
                .noiSemiboldFont(ofSize: 25)
            }
            
            static var title1Semibold: UIFont {
                .noiSemiboldFont(ofSize: 40)
            }
            
            static var title2Semibold: UIFont {
                .noiSemiboldFont(ofSize: 33)
            }
            
            static var title3Semibold: UIFont {
                .noiSemiboldFont(ofSize: 25)
            }
            
        }
        
    }
    
}
