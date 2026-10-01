// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Event.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/21.
//

import Foundation

extension Event {
    func toCalendarEvent() -> CalendarEvent {
        // Every event surfaced by this app is a NOI Techpark event (location
        // filtering happens server-side), so the address is always appended.
        let fullLocation: String?
        if let venue {
            fullLocation = [
                venue,
                .localized("noi_techpark_address")
            ].joined(separator: "\n")
        } else {
            fullLocation = nil
        }
        return AnyCalendarEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: fullLocation
        )
    }
}

private struct AnyCalendarEvent: CalendarEvent {
    let title: String?
    let startDate: Date?
    let endDate: Date?
    let location: String?
    let notes: String?
    let url: URL?

    init(
        title: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        notes: String? = nil,
        url: URL? = nil
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.url = url
    }
}
