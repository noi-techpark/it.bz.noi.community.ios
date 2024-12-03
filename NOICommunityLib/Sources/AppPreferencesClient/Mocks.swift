// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Mocks.swift
//  AppPreferencesClient
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation
import Combine

// MARK: - AppPreferencesClient+Live

public extension AppPreferencesClient {
    
    static let alwaysShowIntro = Self(
        fetch: {
            AppPreferences(skipIntro: false, skipComeOnBoardOnboarding: false)
        },
        update: { _ in },
        delete: { }
    )
    
    static let neverShowIntro = Self(
        fetch: {
            AppPreferences(skipIntro: true, skipComeOnBoardOnboarding: false)
        },
        update: { _ in },
        delete: { }
    )

    static let alwaysShowComeOnBoardOnboarding = Self(
        fetch: {
            AppPreferences(skipIntro: false, skipComeOnBoardOnboarding: true)
        },
        update: { _ in },
        delete: { }
    )

    static let neverShowComeOnBoardOnboarding = Self(
        fetch: {
            AppPreferences(skipIntro: false, skipComeOnBoardOnboarding: true)
        },
        update: { _ in },
        delete: { }
    )
}
