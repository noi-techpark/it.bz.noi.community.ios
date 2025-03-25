// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+Article.swift
//  ArticlesClientLive
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import Core

private let dateFormatter: DateFormatter = { dateFormatter in
    dateFormatter.calendar = Calendar(identifier: .iso8601)
    dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")!
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}(DateFormatter())

extension Endpoint {
    
    static func articleList(
        startDate: Date?,
        publishedOn: String?,
        articleType: String?,
        rawSort: String?,
        rawFilter: String?,
        pageSize: Int?,
        pageNumber: Int?
    ) -> Endpoint {
        Self(path: "/v1/Article") {
            if let startDate {
                URLQueryItem(
                    name: "startDate",
                    value: dateFormatter.string(from: startDate)
                )
            }

            if let publishedOn {
                URLQueryItem(
                    name: "publishedon",
                    value: publishedOn
                )
            }

            if let pageSize {
                URLQueryItem(
                    name: "pagesize",
                    value: String(pageSize)
                )
            }
            
            if let pageNumber {
                URLQueryItem(
                    name: "pagenumber",
                    value: String(pageNumber)
                )
            }

            URLQueryItem(
                name: "removeNullValues",
                value: "true"
            )

            if let articleType {
                URLQueryItem(
                    name: "articletype",
                    value: articleType
                )
            }

            if let rawSort {
                URLQueryItem(
                    name: "rawsort",
                    value: rawSort
                )
            }

            if let rawFilter {
                URLQueryItem(
                    name: "rawfilter",
                    value: rawFilter
                )
            }

            URLQueryItem(
                name: "fields",
                value: "Id,ArticleDate,Detail,ContactInfos,ImageGallery,ODHTags,Highlight"
            )
        }
    }
    
    static func articleListResponseNumber(
        startDate: Date?,
        publishedOn: String?,
        articleType: String?,
        rawFilter: String?
    ) -> Endpoint {
        Self(path: "/v1/Article") {
            if let startDate {
                URLQueryItem(
                    name: "startDate",
                    value: dateFormatter.string(from: startDate)
                )
            }

            if let publishedOn {
                URLQueryItem(
                    name: "publishedon",
                    value: publishedOn
                )
            }
            
            URLQueryItem(
                name: "pagesize",
                value: String(1)
            )
            
            URLQueryItem(
                name: "pagenumber",
                value: String(1)
            )
            

            URLQueryItem(
                name: "removeNullValues",
                value: "true"
            )

            if let articleType {
                URLQueryItem(
                    name: "articletype",
                    value: articleType
                )
            }

            if let rawFilter {
                URLQueryItem(
                    name: "rawfilter",
                    value: rawFilter
                )
            }

            URLQueryItem(
                name: "fields",
                value: "Id"
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
