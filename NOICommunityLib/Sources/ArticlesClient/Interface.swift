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
    
    public var list: (Date, String?, Int?, Int?) -> AnyPublisher<ArticleListResponse, Error>
    
    public typealias ArticleId = String
    public var detail: (String) -> AnyPublisher<Article, Error>
    
    public init(
        list: @escaping (Date, String?, Int?, Int?) -> AnyPublisher<ArticleListResponse, Error>,
        detail: @escaping (String) -> AnyPublisher<Article, Error>
    ) {
        self.list = list
        self.detail = detail
    }
}
