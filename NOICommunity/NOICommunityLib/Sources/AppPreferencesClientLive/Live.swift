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
                return Just(AppPreferences(
                    skipIntro: userDefaults.bool(forKey: skipIntroKey)
                ))
                    //.delay(for: 3, scheduler: DispatchQueue.global())
                    .eraseToAnyPublisher()
            },
            update: { appPreference in
                userDefaults.set(appPreference.skipIntro, forKey: skipIntroKey)
                return Just(())
                    //.delay(for: 3, scheduler: DispatchQueue.global())
                    .eraseToAnyPublisher()
            }
        )
    }
}
