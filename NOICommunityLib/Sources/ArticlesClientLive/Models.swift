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
import ArticlesClient

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
