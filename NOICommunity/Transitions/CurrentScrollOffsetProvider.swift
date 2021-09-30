//
//  CurrentScrollOffsetProvider.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/10/21.
//

import UIKit

// This is needed since collection view with orthogonal scrolling seems to not
// have a valid content offset.
protocol CurrentScrollOffsetProvider {
    var currentScrollOffset: CGPoint { get }
}
