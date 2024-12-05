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




