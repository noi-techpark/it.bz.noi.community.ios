// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticlesClientImplementation.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 05/12/24.
//

import Foundation
import Core

public final class ArticlesClientImplementation: ArticlesClient {

	private let baseURL: URL

	private let transport: Transport

	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()

		jsonDecoder.dateDecodingStrategy = .custom { decoder in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)

			let dateFormatter = DateFormatter()
			dateFormatter.calendar = Calendar(identifier: .iso8601)
			dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Cannot decode date string \(dateStr)"
			)
		}

		jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
		return jsonDecoder
	}()

	public init(
		baseURL: URL,
		transport: Transport
	) {
		self.baseURL = baseURL
		self.transport = transport
			.checkingStatusCodes()
			.addingJSONHeaders()
	}

	public func getArticleList(
		startDate: Date?,
		publishedOn: String?,
		articleType: String?,
		rawSort: String?,
		rawFilter: String?,
		pageSize: Int?,
		pageNumber: Int?
	) async throws -> ArticleListResponse {
		let request = Endpoint
			.articleList(
				startDate: startDate,
				publishedOn: publishedOn,
				articleType: articleType,
				rawSort: rawSort,
				rawFilter: rawFilter,
				pageSize: pageSize,
				pageNumber: pageNumber
			)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		let articleListResponseWithPageURLs = try jsonDecoder.decode(
			ArticleListResponseWithPageURLs.self,
			from: data
		)
		return .init(from: articleListResponseWithPageURLs)
	}
	
	public func getArticle(newsId: String) async throws -> Article {
		let request = Endpoint
			.article(id: newsId)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(Article.self, from: data)
	}	

}

