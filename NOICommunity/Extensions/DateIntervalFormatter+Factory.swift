//
//  DateIntervalFormatter+Factory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 22/09/21.
//

import Foundation

extension DateIntervalFormatter {
    class func dayMonth() -> DateIntervalFormatter {
        let dateIntervalFormatter = DateIntervalFormatter()
        dateIntervalFormatter.dateTemplate = "d M"
        return dateIntervalFormatter
    }

    class func time() -> DateIntervalFormatter {
        let timeIntervalFormatter = DateIntervalFormatter()
        timeIntervalFormatter.timeStyle = .short
        timeIntervalFormatter.dateStyle = .none
        return timeIntervalFormatter
    }
}
