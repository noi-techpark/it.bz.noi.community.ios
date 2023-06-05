// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//  EventShortTypesClient
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Foundation

// MARK: - EventsFilter

public struct EventsFilter: Decodable, Hashable {

    public typealias Id = String
    public let id: Id

    public let key: String

    public let type: Kind

    public let typeDesc: [String:String]

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Id.self, forKey: .id)
        key = try values.decode(String.self, forKey: .key)
        type = try values.decode(Kind.self, forKey: .type)

        typeDesc = try values.decodeIfPresent(
            [String:String].self,
            forKey: .typeDesc
        ) ?? [:]
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public struct Kind: RawRepresentable, Hashable, Codable {

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let customTagging = Self(rawValue: "CustomTagging")
        public static let technologyFields = Self(rawValue: "TechnologyFields")
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case type
        case typeDesc
    }
}
