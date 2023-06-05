// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Live.swift
//  AppPreferencesClient
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation
import Combine
import AppPreferencesClient

// MARK: - Private Constants

private let skipIntroKey = "skipIntro"

// MARK: - EventShortClient+Live

public extension AppPreferencesClient {
    
    static func live(userDefaults: UserDefaults = .standard) -> Self {
        Self(
            fetch: {
                AppPreferences(
                    skipIntro: userDefaults.bool(forKey: skipIntroKey)
                )
            },
            update: { appPreference in
                userDefaults.set(appPreference.skipIntro, forKey: skipIntroKey)
            }
        )
    }
}
