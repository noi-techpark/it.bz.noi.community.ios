// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticleTagsClientTests.swift
//  NOICommunityTests
//
//  Created by Camilla on 18/02/25.
//

import XCTest
import Core
@testable import ArticleTagsClient

final class ArticleTagsClientTests: XCTestCase {
    func testGetArticleTagList() async throws {
        let baseURL = URL(string: "https://tourism.opendatahub.com")!
        let transport = URLSession.shared
        lazy var articleTagsCache = Cache<String, ArticleTagListResponse>()

        let client = ArticleTagsClientImplementation(baseURL: baseURL, transport: transport, memoryCache: articleTagsCache)

        do {
            let response = try await client.getArticleTagList()
            XCTAssertFalse(response.items.isEmpty, "L'array di tag non dovrebbe essere vuoto")

            print("✅ Risultati ricevuti:")
            response.items.forEach { tag in
                print("""
                - Id: \(tag.id)
                  TagName: \(tag.tagName)
                  Types: \(tag.types)
                """)
            }
        } catch {
            XCTFail("❌ Errore durante la chiamata API o decoding: \(error)")
        }
    }
}

