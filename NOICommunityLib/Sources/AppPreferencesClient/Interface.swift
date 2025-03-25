// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Interface.swift
//  AppPreferencesClient
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation

public struct AppPreferences {
    
    public var skipIntro: Bool
    public var skipComeOnBoardOnboarding: Bool
    public var activeNewsFilterIds: [String]
    
    public init(
        skipIntro: Bool,
        skipComeOnBoardOnboarding: Bool,
        activeNewsFilterIds: [String] = []
    ) {
        self.skipIntro = skipIntro
        self.skipComeOnBoardOnboarding = skipComeOnBoardOnboarding
        self.activeNewsFilterIds = activeNewsFilterIds
    }
}


public struct AppPreferencesClient {
    
    public var fetch: () -> AppPreferences
    public var update: (AppPreferences) -> Void
    public var delete: () -> Void

    public init(
        fetch: @escaping () -> AppPreferences,
        update: @escaping (AppPreferences) -> Void,
        delete: @escaping () -> Void
    ) {
        self.fetch = fetch
        self.update = update
        self.delete = delete
    }
}
