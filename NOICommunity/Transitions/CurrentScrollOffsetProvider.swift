// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
