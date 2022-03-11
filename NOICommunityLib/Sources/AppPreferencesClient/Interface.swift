//
//  Interface.swift
//  AppPreferencesClient
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation
import Combine

public struct AppPreferences {
    public var skipIntro: Bool

    public init(skipIntro: Bool) {
        self.skipIntro = skipIntro
    }
}

public struct AppPreferencesClient {
    public var fetch: () -> AnyPublisher<AppPreferences, Never>
    public var update: (AppPreferences) -> AnyPublisher<Void, Never>

    public init(
        fetch: @escaping () -> AnyPublisher<AppPreferences, Never>,
        update: @escaping (AppPreferences) -> AnyPublisher<Void, Never>
    ) {
        self.fetch = fetch
        self.update = update
    }
}
