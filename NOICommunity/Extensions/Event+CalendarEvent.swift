//
//  Event.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/21.
//

import Foundation

extension Event {
    func toCalendarEvent() -> CalendarEvent {
        let fullLocation: String?
        if location == .noi,
           let venue = venue {
            fullLocation = [
                venue,
                .localized("noi_techpark_address")
            ].joined(separator: "\n")
        } else {
            fullLocation = self.venue
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
