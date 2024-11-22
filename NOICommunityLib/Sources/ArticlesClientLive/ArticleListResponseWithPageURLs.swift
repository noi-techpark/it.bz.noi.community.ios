// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticleListResponseWithPageURLs.swift
//  ArticlesClient
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation
import ArticlesClient

// MARK: - ArticleListResponseWithPageURLs

struct ArticleListResponseWithPageURLs: Codable, Equatable {

    let totalResults: Int

    let totalPages: Int

    let currentPage: Int

    let previousPageURL: URL?

    let nextPageURL: URL?

    let items: [Article]

    private enum CodingKeys: String, CodingKey {
        case totalResults
        case totalPages
        case currentPage
        case previousPageURL = "previousPage"
        case nextPageURL = "nextPage"
        case items
    }

    init(from decoder: any Decoder) throws {
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
        previousPageURL = try container.decodeIfPresent(
            URL.self,
            forKey: .previousPageURL
        )
        nextPageURL = try container.decodeIfPresent(
            URL.self,
            forKey: .nextPageURL
        )
        items = try container.decodeIfPresent(
            [Article].self,
            forKey: .items
        ) ?? []
    }

}
