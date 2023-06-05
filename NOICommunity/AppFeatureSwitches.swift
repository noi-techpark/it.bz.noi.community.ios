// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AppFeatureSwitches.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 19/10/21.
//

import Foundation

enum AppFeatureSwitches {

    static var isCrashlyticsEnabled: Bool {
#if DEBUG
        false
#else
        true
#endif
    }

}
