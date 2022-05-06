//
//  DateIntervalFilter.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/21.
//

import Foundation

enum DateIntervalFilter: CaseIterable {
    case all
    case today
    case currentWeek
    case currentMonth

    var localizedString: String {
        switch self {
        case .all:
            return .localized("time_filter_all")
        case .today:
            return .localized("time_filter_today")
        case .currentWeek:
            return .localized("time_filter_this_week")
        case .currentMonth:
            return .localized("time_filter_this_month")
        }
    }
}
