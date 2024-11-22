// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//  ArticlesClient
//
//  Created by Matteo Matassoni on 10/05/22.
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

// MARK: - ArticleListResponse

public struct ArticleListResponse: Codable, Hashable {

    public let totalResults: Int

    public let totalPages: Int

    public let currentPage: Int

    public let previousPage: Int?

    public let nextPage: Int?

    public var hasNextPage: Bool {
        nextPage != nil
    }

    public let items: [Article]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalResults = try container.decode(
            Int.self,
            forKey: .totalResults
        )
        totalPages = try container.decode(
            Int.self,
            forKey: .totalPages
        )
        currentPage = try container.decode(
            Int.self,
            forKey: .currentPage
        )
        previousPage = try container.decodeIfPresent(
            Int.self,
            forKey: .previousPage
        )
        nextPage = try container.decodeIfPresent(
            Int.self,
            forKey: .nextPage
        )
        items = try container.decodeIfPresent(
            [Article].self,
            forKey: .items
        ) ?? []
    }

    public init(
        totalResults: Int,
        totalPages: Int,
        currentPage: Int,
        previousPage: Int? = nil,
        nextPage: Int? = nil,
        items: [Article]
    ) {
        self.totalResults = totalResults
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.previousPage = previousPage
        self.nextPage = nextPage
        self.items = items
    }

}

// MARK: - Article

public struct Article: Codable, Hashable {

    public typealias LocalizedMap<T: Codable> = [String:T]

    public let id: String

    public let languageToDetails: LocalizedMap<Details>

    public let date: Date?

    public let languageToAuthor: LocalizedMap<ContactInfos>

    public let imageGallery: [ImageGallery]

    public let tags: [Tag]

    public let isHighlighted: Bool

    public var isImportant: Bool {
        tags.contains { $0.id == "important" }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date = "articleDate"
        case languageToDetails = "detail"
        case languageToAuthor = "contactInfos"
        case imageGallery
        case tags = "oDHTags"
        case isHighlighted = "highlight"
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.date = try values.decodeIfPresent(Date.self, forKey: .date)
        self.languageToDetails = try values.decodeIfPresent(
            LocalizedMap<Article.Details>.self,
            forKey: .languageToDetails) ?? [:]
        self.languageToAuthor = try values.decodeIfPresent(
            LocalizedMap<Article.ContactInfos>.self,
            forKey: .languageToAuthor
        ) ?? [:]
        self.imageGallery = try values.decodeIfPresent(
            [Article.ImageGallery].self,
            forKey: .imageGallery
        ) ?? []
        self.tags = try values.decodeIfPresent(
            [Article.Tag].self,
            forKey: .tags
        ) ?? []
        self.isHighlighted = try values.decodeIfPresent(
            Bool.self,
            forKey: .isHighlighted
        ) ?? false
    }

}

// MARK: Article.Details

extension Article {

    public struct Details: Codable, Hashable {

        public let title: String?

        public let abstract: String?

        public let text: String?

        private enum CodingKeys: String, CodingKey {
            case title = "title"
            case abstract = "additionalText"
            case text = "baseText"
        }

    }

}

// MARK: Article.ContactInfos

extension Article {

    public struct ContactInfos: Codable, Hashable {

        public let name: String?

        public let logoURL: URL?

        public let externalURL: URL?

        public let email: String?

        private enum CodingKeys: String, CodingKey {
            case name = "companyName"
            case logoURL = "logoUrl"
            case externalURL = "url"
            case email = "email"
        }

    }

}

// MARK: Article.ContactInfos

extension Article {

    public struct ImageGallery: Codable, Hashable {

        public let url: URL?

        private enum CodingKeys: String, CodingKey {
            case url = "imageUrl"
        }

    }

}

// MARK: Article.Tag

extension Article {

    public struct Tag: Codable, Hashable {
        public let id: String?
    }

}
