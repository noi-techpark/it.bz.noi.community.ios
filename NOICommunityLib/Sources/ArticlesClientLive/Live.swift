//
//  Live.swift
//  ArticlesClientLive
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation
import Combine
import PascalJSONDecoder
import DecodeEmptyRepresentable
import ArticlesClient
import Endpoint

// MARK: - Private Constants

private let baseURL = URL(string: "https://tourism.opendatahub.bz.it")!
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
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
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
    
    public static func live(urlSession: URLSession = .shared) -> Self {
        Self(
            list: { pageSize, pageNumber, language in
                let urlRequest = Endpoint.articleList(
                    pageSize: pageSize,
                    pageNumber: pageNumber,
                    language: language
                ).makeRequest(withBaseURL: baseURL)
                
                return urlSession
                    .dataTaskPublisher(for: urlRequest)
                    .map { data, _ in
                        if let bodyOutput = String(data: data, encoding: .utf8) {
                            print("response: \(bodyOutput)")
                        }
                        return data
                    }
                    .decode(
                        type: MyArticleListResponse.self,
                        decoder: articlesJsonDecoder
                    )
                    .map(ArticleListResponse.init(from:))
                    .eraseToAnyPublisher()
            },
            detail: { id, language in
                let urlRequest = Endpoint.article(id: id, language: language)
                    .makeRequest(withBaseURL: baseURL)
                
                return urlSession
                    .dataTaskPublisher(for: urlRequest)
                    .map { data, _ in data }
                    .decode(
                        type: Article.self,
                        decoder: articlesJsonDecoder
                    )
                    .eraseToAnyPublisher()
            }
        )
    }
    
}
