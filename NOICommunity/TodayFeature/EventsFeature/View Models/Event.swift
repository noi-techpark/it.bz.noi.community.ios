// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Event.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import Foundation
import EventShortClient

struct Event: Hashable, Identifiable {
    let id: String
    let title: String?
    let startDate: Date
    let endDate: Date
    let location: EventLocation?
    let venue: String?
    let imageURL: URL?
    let description: String?
    let organizer: String?
    let technologyFields: [String]
    let mapURL: URL?
    let signupURL: URL?
}
