// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  DeveloperToolsViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/08/24.
//

import Foundation

// MARK: - DeveloperToolsOption

enum DeveloperToolsOption: String {
    case forceCrash = "Force Crash 💥!"
}

// MARK: - DeveloperToolsViewModel

final class DeveloperToolsViewModel {

    @Published private(set) var options: [DeveloperToolsOption] = [
        .forceCrash
    ]

    func perform(option: DeveloperToolsOption) {
        switch option {
        case .forceCrash:
            forceCrash()
        }
    }

}

// MARK: Private APIs

private extension DeveloperToolsViewModel {


    func forceCrash() {
        let numbers = [0]
        let _ = numbers[1]
    }
}
