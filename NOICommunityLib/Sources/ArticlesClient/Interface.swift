// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Interface.swift
//  ArticlesClient
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation
import Combine

public struct ArticlesClient {
    
    public typealias ListMethod = (
        _ startDate: Date?,
        _ publishedon: String?,
        _ articleType: String?,
        _ rawSort: String?,
        _ rawFilter: String?,
        _ pageSize: Int?,
        _ pageNumber: Int?
    ) -> AnyPublisher<ArticleListResponse, Error>
    public var list: ListMethod

    public typealias DetailMethod = (
        _ articleId: String
    ) -> AnyPublisher<Article, Error>
    public var detail: DetailMethod

    public init(
        list: @escaping ListMethod, 
        detail: @escaping DetailMethod
    ) {
        self.list = list
        self.detail = detail
    }

    public func list(
        startDate: Date? = nil,
        publishedon: String? = nil,
        articleType: String? = nil,
        rawSort: String? = nil,
        rawFilter: String? = nil,
        pageSize: Int? = nil,
        pageNumber: Int? = nil
    ) -> AnyPublisher<ArticleListResponse, Error> {
        list(
            startDate,
            publishedon,
            articleType,
            rawSort,
            rawFilter,
            pageSize,
            pageNumber
        )
    }

    public func detail(
        ofArticleWithId articleId: String
    ) -> AnyPublisher<Article, Error> {
        detail(articleId)
    }

}
