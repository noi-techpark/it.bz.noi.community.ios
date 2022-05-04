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
            AppPreferences(skipIntro: false)
        },
        update: { _ in }
    )
    
    static let neverShowIntro = Self(
        fetch: {
            AppPreferences(skipIntro: true)
        },
        update: { _ in }
    )
}
