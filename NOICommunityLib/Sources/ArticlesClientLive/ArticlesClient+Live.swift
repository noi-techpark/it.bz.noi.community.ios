// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticlesClient+Live.swift
//  ArticlesClientLive
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation
import Combine
import Core
import ArticlesClient

// MARK: - Private Constants

private let articlesJsonDecoder: JSONDecoder = {
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

// MARK: - ArticlesClient+Live

extension ArticlesClient {
    
    public static func live(
        baseURL: URL,
        urlSession: URLSession = .shared
    ) -> Self {
        Self(
            list: { startDate, publishedon, articleType, rawSort, rawFilter, pageSize, pageNumber in
                let urlRequest = Endpoint.articleList(
                    startDate: startDate, 
                    publishedon: publishedon,
                    articleType: articleType,
                    rawSort: rawSort,
                    rawFilter: rawFilter,
                    pageSize: pageSize,
                    pageNumber: pageNumber
                ).makeRequest(withBaseURL: baseURL)
                
                return urlSession
                    .dataTaskPublisher(for: urlRequest)
                    .debug()
                    .map { data, response in data }
                    .decode(
                        type: ArticleListResponseWithPageURLs.self,
                        decoder: articlesJsonDecoder
                    )
                    .map(ArticleListResponse.init(from:))
                    .eraseToAnyPublisher()
            },
            detail: { id in
                let urlRequest = Endpoint.article(id: id)
                    .makeRequest(withBaseURL: baseURL)
                
                return urlSession
                    .dataTaskPublisher(for: urlRequest)
                    .debug()
                    .map { data, response in data }
                    .decode(
                        type: Article.self,
                        decoder: articlesJsonDecoder
                    )
                    .eraseToAnyPublisher()
            }
        )
    }
    
}
