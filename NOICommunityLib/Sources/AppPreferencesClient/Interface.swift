//
//  Interface.swift
//  AppPreferencesClient
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation

public struct AppPreferences {
    
    public var skipIntro: Bool

    public init(skipIntro: Bool) {
        self.skipIntro = skipIntro
    }
}

public struct AppPreferencesClient {
    
    public var fetch: () -> AppPreferences
    public var update: (AppPreferences) -> Void

    public init(
        fetch: @escaping () -> AppPreferences,
        update: @escaping (AppPreferences) -> Void
    ) {
        self.fetch = fetch
        self.update = update
    }
}
