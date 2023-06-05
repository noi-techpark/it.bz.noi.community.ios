// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CalendarAdditions.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 17/09/21.
//

import Foundation

extension Calendar {
    func endOfDay(for date: Date) -> Date {
        let startOfDay = startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay)!
    }

    func lastDayOfWeek(for date: Date) -> Date {
        let numberOfDaysInAWeek = weekdaySymbols.count
        let lastWeekday = ((firstWeekday - 1) + (numberOfDaysInAWeek - 1)) % numberOfDaysInAWeek + 1
        let components = DateComponents(weekday: lastWeekday)
        if component(.weekday, from: date) == lastWeekday {
            return date
        }
        return nextDate(
            after: date,
            matching: components,
            matchingPolicy: .nextTime
        )!
    }

    func lastDayOfMonth(for date: Date) -> Date {
        let numberOfDaysInCurrentMonth = range(of: .day, in: .month, for: date)!
            .count
        var components = dateComponents([.year, .month, .day], from: date)
        components.day = numberOfDaysInCurrentMonth
        return self.date(from: components)!
    }

    func dateForTime(from date: Date) -> Date {
        let components = dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: date
        )
        return self.date(from: components)!
    }
}
