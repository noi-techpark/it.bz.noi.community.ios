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

public struct Person: Codable {
    
    public var id: String
    public var firstname: String
    public var lastname: String
    public var fullname: String
    public var email: String?
    public var companyId: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "contactid"
        case email = "emailaddress1"
        case firstname
        case lastname
        case fullname
        case companyId = "_parentcustomerid_value"
    }
    
}

public struct Company: Codable {
    
    public var id: String
    public var name: String
    public var phoneNumber: String?
    public var fullAddress: String?
    public var tags: Set<Tag>
    
    private enum CodingKeys: String, CodingKey {
        case id = "accountid"
        case name
        case phoneNumber = "telephone1"
        case fullAddress = "address1_composite"
        case tags = "crb14_accountcat_placepresscommunity"
    }
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        phoneNumber = try values.decodeIfPresent(
            String.self,
            forKey: .phoneNumber
        )
        fullAddress = try values.decodeIfPresent(
            String.self,
            forKey: .fullAddress
        )
        let tags = try values.decodeIfPresent(
            String.self,
            forKey: .tags
        )
        self.tags = Set(
            tags?
                .split(separator: ",")
                .map(String.init)
                .map(Tag.init(rawValue:))
            ?? []
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(fullAddress, forKey: .fullAddress)
        if !tags.isEmpty {
            let tags = tags.map(\.rawValue).joined(separator: ",")
            try container.encode(tags, forKey: .tags)
        }
    }
}

extension Company {
    
    public struct Tag: RawRepresentable, Codable, Hashable {
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let noiCommunity = Self(rawValue: "952210000")
        public static let startup = Self(rawValue: "952210001")
        public static let company = Self(rawValue: "952210002")
        public static let researchInstitution = Self(rawValue: "952210003")
        
    }
    
}
