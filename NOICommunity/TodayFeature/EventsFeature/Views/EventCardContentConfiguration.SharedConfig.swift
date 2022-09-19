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

        let timeInterval: DateInterval = {
            let date1 = Calendar.current.dateForTime(from: item.startDate)
            let date2 = Calendar.current.dateForTime(from: item.endDate)
            if date1 < date2 {
                return DateInterval(start: date1, end: date2)
            } else {
                return DateInterval(start: date2, end: date1)
            }
        }()

        var contentConfiguration = EventCardContentConfiguration()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 30
        contentConfiguration.attributedText = NSAttributedString(
            string: item.title ?? .notDefined,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        contentConfiguration.textProprieties.font = .NOI.dynamic.title0Semibold
        
        contentConfiguration.leadingSecondaryText = item.venue ?? .notDefined
        
        
        contentConfiguration.trailingSecondaryText = timeIntervalFormatter
            .string(from: timeInterval) ?? .notDefined
        
        contentConfiguration.badgeText = dayMonthIntervalFormatter
            .string(from: dateInterval) ?? .notDefined
        
        contentConfiguration.image = UIImage(named: "placeholder_noi_events")
        
        return contentConfiguration
    }
    
    static func makeDetailedContentConfiguration(
        for item: Event,
        dayMonthIntervalFormatter: DateIntervalFormatter = .dayMonth(),
        timeIntervalFormatter: DateIntervalFormatter = .time()
    ) -> EventCardContentConfiguration {
        var contentConfiguration = makeContentConfiguration(
            for: item,
               dayMonthIntervalFormatter: dayMonthIntervalFormatter,
               timeIntervalFormatter: timeIntervalFormatter
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 45
        contentConfiguration.attributedText = NSAttributedString(
            string: item.title ?? .notDefined,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        contentConfiguration.textProprieties.font = .NOI.dynamic.title1Semibold
        
        contentConfiguration.tertiaryText = item.organizer ?? .notDefined
        
        return contentConfiguration
    }
}
