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
import ArticlesClient

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
        publishedon: String?,
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

            if let publishedon = publishedon {
                URLQueryItem(
                    name: "publishedon",
                    value: publishedon
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
