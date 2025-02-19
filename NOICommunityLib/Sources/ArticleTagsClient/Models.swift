// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//  ArticleTagsClient
//
//  Created by Camilla on 18/02/25.
//

import Foundation

// MARK: - Language

public struct Language: RawRepresentable, Codable, Hashable {

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let en = Self(rawValue: "en")
    public static let it = Self(rawValue: "it")
    public static let de = Self(rawValue: "de")

}

// MARK: - ArticleTagListResponse

public struct ArticleTagListResponse: Codable, Hashable {

    public let totalResults: Int
    public let items: [ArticleTag]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalResults = try container.decode(Int.self, forKey: .totalResults)
        items = try container.decodeIfPresent([ArticleTag].self, forKey: .items) ?? []
    }

    public init(
        totalResults: Int,
        items: [ArticleTag]
    ) {
        self.totalResults = totalResults
        self.items = items
    }
}


// MARK: - ArticleTag

public struct ArticleTag: Codable, Hashable {

    public typealias LocalizedMap<T: Codable> = [String:T]

    public let id: String
    public let tagName: LocalizedMap<String>
    public let types: [String]

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.tagName = try values.decodeIfPresent(LocalizedMap<String>.self, forKey: .tagName) ?? [:]
        self.types = try values.decodeIfPresent([String].self, forKey: .types) ?? []
    }

    public init(
        id: String,
        tagName: LocalizedMap<String>,
        types: [String]
    ) {
        self.id = id
        self.tagName = tagName
        self.types = types
    }
}


