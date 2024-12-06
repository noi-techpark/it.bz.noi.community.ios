// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticlesClient.swift
//  ArticlesClient
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation

public protocol ArticlesClient {
	
	func getArticleList(
		startDate: Date?,
		publishedOn: String?,
		pageSize: Int?,
		pageNumber: Int?
	) async throws -> ArticleListResponse
	
	func getArticle(newsId: String) async throws -> Article
	
}

public extension ArticlesClient {
	
	func getArticleList(
		startDate: Date? = nil,
		publishedOn: String? = nil,
		pageSize: Int? = nil,
		pageNumber: Int? = nil
	) async throws -> ArticleListResponse {
		try await getArticleList(
			startDate: startDate,
			publishedOn: publishedOn,
			pageSize: pageSize,
			pageNumber: pageNumber
		)
	}
	
}



