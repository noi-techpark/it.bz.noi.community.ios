//
//  File.swift
//  
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import ArticlesClient
import Endpoint
import EndpointWithQueryBuilder

extension Endpoint {
    
    static func articleList(
        pageSize: Int?,
        pageNumber: Int?,
        language: Language?
    ) -> Endpoint {
        Self(path: "/v1/Article") {
            if let pageSize = pageSize {
                URLQueryItem(
                    name: "pagesize",
                    value: String(pageSize)
                )
            }
            
            if let pageNumber = pageNumber {
                URLQueryItem(
                    name: "pagenumber",
                    value: String(pageNumber)
                )
            }
            
            if let language = language {
                URLQueryItem(
                    name: "language",
                    value: language.rawValue
                )
            }
            
            URLQueryItem(
                name: "onlyActive",
                value: "true"
            )
            
            URLQueryItem(
                name: "removeNullValues",
                value: "true"
            )
            
            URLQueryItem(
                name: "articletype",
                value: "newsfeednoi"
            )
            
            URLQueryItem(
                name: "rawsort",
                value: "-ArticleDate"
            )
            
            URLQueryItem(
                name: "fields",
                value: "Id,ArticleDate,Detail,ContactInfos,ImageGallery,ODHTags"
            )
        }
    }
    
    static func article(id: String, language: Language?) -> Endpoint {
        Self(path: "/v1/Article/\(id)") {
            if let language = language {
                URLQueryItem(
                    name: "language",
                    value: language.rawValue
                )
            }
            
            URLQueryItem(
                name: "removeNullValues",
                value: "true"
            )
            
            URLQueryItem(
                name: "fields",
                value: "Id,ArticleDate,Detail,ContactInfos,ImageGallery,ODHTags"
            )
        }
    }
    
}
