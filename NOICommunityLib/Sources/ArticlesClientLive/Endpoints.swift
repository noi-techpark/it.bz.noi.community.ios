//
//  Endpoints.swift
//  ArticlesClientLive
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import ArticlesClient
import Endpoint
import EndpointWithQueryBuilder

private let dateFormatter: DateFormatter = { dateFormatter in
    dateFormatter.calendar = Calendar(identifier: .iso8601)
    dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")!
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}(DateFormatter())

extension Endpoint {
    
    static func articleList(
        startDate: Date,
        pageSize: Int?,
        pageNumber: Int?
    ) -> Endpoint {
        Self(path: "/v1/Article") {
            if let startDateString = dateFormatter.string(from: startDate) {
                URLQueryItem(
                    name: "startDate",
                    value: startDateString
                )
            }
            
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
    
    static func article(id: String) -> Endpoint {
        Self(path: "/v1/Article/\(id)") {
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
