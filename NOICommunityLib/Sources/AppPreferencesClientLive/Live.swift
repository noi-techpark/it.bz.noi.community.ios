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
private let skipComeOnBoardOnboardingKey = "skipComeOnBoardOnboarding"

// MARK: - EventShortClient+Live

public extension AppPreferencesClient {
    
    static func live(userDefaults: UserDefaults = .standard) -> Self {
        Self(
            fetch: {
                AppPreferences(
                    skipIntro: userDefaults.bool(forKey: skipIntroKey),
                    skipComeOnBoardOnboarding: userDefaults.bool(forKey: skipComeOnBoardOnboardingKey)
                )
            },
            update: { appPreference in
                userDefaults.set(appPreference.skipIntro, forKey: skipIntroKey)
                userDefaults.set(appPreference.skipComeOnBoardOnboarding, forKey: skipComeOnBoardOnboardingKey)
                userDefaults.synchronize()
            },
            delete: {
                userDefaults.removeObject(forKey: skipIntroKey)
                userDefaults.removeObject(forKey: skipComeOnBoardOnboardingKey)
                userDefaults.synchronize()
            }
        )
    }
}
