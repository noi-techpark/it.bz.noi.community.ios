// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//  PeopleClient
//
//  Created by Matteo Matassoni on 23/05/22.
//

import Foundation
import PeopleClient

struct PeopleResponse: Codable {
    
    var people: [Person]
    var count: Int?
    
    private enum CodingKeys: String, CodingKey {
        case people = "value"
        case count = "@odata.count"
    }
    
}

struct CompanyResponse: Codable {
    
    var companies: [Company]
    var count: Int?
    
    private enum CodingKeys: String, CodingKey {
        case companies = "value"
        case count = "@odata.count"
    }
    
}
