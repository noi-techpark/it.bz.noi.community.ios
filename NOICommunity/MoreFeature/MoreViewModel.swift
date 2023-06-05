// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MoreViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/09/21.
//

import Foundation

// MARK: - MoreViewModel

final class MoreViewModel {
    
    struct Entry: Hashable, CaseIterable {
        static var allCases: [Entry] = [
            .bookRoom,
            .onboarding,
            .feedbacks,
            .bugReport,
            .myAccount
        ]

        let localizedTitle: String
        let url: URL?

        static let bookRoom = Self(
            localizedTitle: .localized("room_booking"),
            url: .roomBooking
        )
        
        static let onboarding = Self(
            localizedTitle: .localized("more_item_onboarding"),
            url: .onboarding
        )
        
        static let feedbacks = Self(
            localizedTitle: .localized("more_item_feedback"),
            url: .feedbacks
        )
        
        static let bugReport = Self(
            localizedTitle: .localized("more_item_bug_report"),
            url: .bugReport
        )
        
        static let myAccount = Self(
            localizedTitle: .localized("more_item_account"),
            url: nil
        )
    }
}
