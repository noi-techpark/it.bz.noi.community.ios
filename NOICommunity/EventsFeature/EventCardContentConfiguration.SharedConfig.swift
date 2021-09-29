//
//  EventCardContentConfiguration.SharedConfig.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/09/21.
//

import UIKit

extension EventCardContentConfiguration {
    static func makeContentConfiguration(
        for item: Event,
        dayMonthIntervalFormatter: DateIntervalFormatter = .dayMonth(),
        timeIntervalFormatter: DateIntervalFormatter = .time()
    ) -> EventCardContentConfiguration {
        let dateInterval = DateInterval(
            start: item.startDate,
            end: item.endDate
        )
        let timeInterval = DateInterval(
            start: Calendar.current.dateForTime(from: item.startDate),
            end: Calendar.current.dateForTime(from: item.endDate)
        )

        var contentConfiguration = EventCardContentConfiguration()
        contentConfiguration.text = item.title ?? .notDefined
        contentConfiguration.leadingSecondaryText = item.venue ?? .notDefined
        contentConfiguration.trailingSecondaryText = timeIntervalFormatter
            .string(from: timeInterval) ?? .notDefined
        contentConfiguration.badgeText = dayMonthIntervalFormatter
            .string(from: dateInterval) ?? .notDefined
        contentConfiguration.image = UIImage(named: "placeholder_noi_events")
        return contentConfiguration
    }
    
    static func makeDetailedContentConfiguration(
        for event: Event,
        dayMonthIntervalFormatter: DateIntervalFormatter = .dayMonth(),
        timeIntervalFormatter: DateIntervalFormatter = .time()
    ) -> EventCardContentConfiguration {
        var contentConfiguration = makeContentConfiguration(
            for: event,
               dayMonthIntervalFormatter: dayMonthIntervalFormatter,
               timeIntervalFormatter: timeIntervalFormatter
        )
        contentConfiguration.tertiaryText = event.organizer ?? .notDefined
        return contentConfiguration
    }
}
