// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticleResponseNumber.swift
//  NOICommunityTests
//
//  Created by Camilla on 12/03/25.
//

import XCTest
@testable import ArticlesClient

final class ArticleResponseNumber: XCTestCase {

    public func testGetTotalArticleResults() async { 
        let baseURL = URL(string: "https://tourism.api.opendatahub.com")!
        let transport = URLSession.shared
        
        let client = ArticlesClientImplementation(baseURL: baseURL, transport: transport)
        
        do {
            let totalResults = try await client.getTotalArticleResults(
                startDate: Date(),
                publishedOn: "noi-communityapp",
                articleType: "newsfeednoi",
                rawFilter: nil
            )
            print("✅ Total Results: \(totalResults)")
            
            let filteredTotalResults = try await client.getTotalArticleResults(
                startDate: Date(),
                publishedOn: "noi-communityapp",
                articleType: "newsfeednoi",
                rawFilter: "in(TagIds.[],\"1334267f-41ce-433a-9080-d4541c75762c\")"
            )
            print("✅ Filtered Total Results: \(filteredTotalResults)")
            
        } catch {
            fatalError("❌ Test failed with error: \(error)")
        }
    }
    
}
