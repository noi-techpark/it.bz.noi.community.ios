// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIViewController+isInWindowHierarchy.swift
//  CoreUI
//
//  Created by Matteo Matassoni on 22/11/24.
//

import UIKit

public extension UIViewController {

    var isInWindowHierarchy: Bool {
        viewIfLoaded?.window != nil
    }

}
