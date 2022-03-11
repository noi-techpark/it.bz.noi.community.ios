//
//  Mocks.swift
//  AppPreferencesClient
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation
import Combine

// MARK: - EventShortClient+Live

public extension AppPreferencesClient {
    static let alwaysShowIntro = Self(
        fetch: {
            Just(AppPreferences(skipIntro: false))
                .eraseToAnyPublisher()
        },
        update: { _ in
            return Just(())
                .eraseToAnyPublisher()
        }
    )

    static let neverShowIntro = Self(
        fetch: {
            Just(AppPreferences(skipIntro: true))
                .eraseToAnyPublisher()
        },
        update: { _ in
            return Just(())
                .eraseToAnyPublisher()
        }
    )
}
