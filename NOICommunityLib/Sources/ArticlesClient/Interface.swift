//
//  Interface.swift
//  ArticlesClient
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation
import Combine

public struct ArticlesClient {
    
    public var list: (Int?, Int?, Language?) -> AnyPublisher<ArticleListResponse, Error>
    
    public typealias ArticleId = String
    public var detail: (String, Language?) -> AnyPublisher<Article, Error>
    
    public init(
        list: @escaping (Int?, Int?, Language?) -> AnyPublisher<ArticleListResponse, Error>,
        detail: @escaping (String, Language?) -> AnyPublisher<Article, Error>
    ) {
        self.list = list
        self.detail = detail
    }
}
