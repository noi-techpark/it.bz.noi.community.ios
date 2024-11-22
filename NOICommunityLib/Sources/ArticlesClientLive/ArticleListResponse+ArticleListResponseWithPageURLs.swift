// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticleListResponse+ArticleListResponseWithPageURLs.swift
//  
//
//  Created by Matteo Matassoni on 22/11/24.
//

import Foundation
import ArticlesClient

// MARK: - ArticleListResponse+ArticleListResponseWithPageURLs

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

    init(from response: ArticleListResponseWithPageURLs) {
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
