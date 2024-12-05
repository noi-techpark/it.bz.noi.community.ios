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
    
    public let items: [Article]?
    
    public init(
        totalResults: Int,
        totalPages: Int,
        currentPage: Int,
        previousPage: Int? = nil,
        nextPage: Int? = nil,
        items: [Article]? = nil
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
    
    public let imageGallery: [ImageGallery]?
    
    public let tags: [Tag]?
    
    public var isImportant: Bool {
        tags?.contains { $0.id == "important" } ?? false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case date = "articleDate"
        case languageToDetails = "detail"
        case languageToAuthor = "contactInfos"
        case imageGallery
        case tags = "oDHTags"
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

// MARK: - ArticleListResponse

struct MyArticleListResponse: Codable, Equatable {

	let totalResults: Int

	let totalPages: Int

	let currentPage: Int

	let previousPageURL: URL?

	let nextPageURL: URL?

	let items: [Article]?

	private enum CodingKeys: String, CodingKey {
		case totalResults
		case totalPages
		case currentPage
		case previousPageURL = "previousPage"
		case nextPageURL = "nextPage"
		case items
	}

}

private func extractPageNumber(url: URL) -> Int? {
	let urlComponents = URLComponents(
		url: url,
		resolvingAgainstBaseURL: true
	)
	return urlComponents?
		.queryItems?
		.first { $0.name == "pagenumber"}?
		.value
		.flatMap(Int.init)
}

extension ArticleListResponse {

	init(from response: MyArticleListResponse) {
		self.init(
			totalResults: response.totalResults,
			totalPages: response.totalPages,
			currentPage: response.currentPage,
			previousPage: response.previousPageURL.flatMap(extractPageNumber(url:)),
			nextPage: response.nextPageURL.flatMap(extractPageNumber(url:)),
			items: response.items
		)
	}

}
