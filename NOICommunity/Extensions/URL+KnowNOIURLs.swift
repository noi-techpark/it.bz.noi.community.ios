//
//  URL+KnowNOIURLs.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

extension URL {
    static let map = URL(string: .localized("url_map"))!
    static let roomBooking = URL(string: .localized("url_room_booking"))!
    static let lab = URL(string: .localized("url_lab"))!
    static let aboutUs = URL(string: .localized("url_about_us"))!
    static let onboarding = URL(string: .localized("url_onboarding"))!
    static let feedbacks = URL(string: .localized("url_provide_feedback"))!
    static let noisteriaMenu = URL(string: .localized("url_noisteria_menu"))!
    static let noiBarMenu = URL(string: .localized("url_noi_bar_menu"))!
    static let alumixMenu = URL(string: .localized("url_alumix_menu"))!
    static let bugReport = URL(string: .localized("url_bug_report"))!
}
