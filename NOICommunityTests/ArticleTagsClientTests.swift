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
@testable import ArticleTagsClient

final class ArticleTagsClientTests: XCTestCase {
    func testGetArticleTagList() async throws {
        let baseURL = URL(string: "https://tourism.opendatahub.com")!
        let transport = URLSession.shared
        
        let client = ArticleTagsClientImplementation(baseURL: baseURL, transport: transport)
        
        do {
            let response = try await client.getArticleTagList()
            XCTAssertFalse(response.items.isEmpty, "L'array di tag non dovrebbe essere vuoto")
            print("✅ Risultati ricevuti:", response.items)
        } catch {
            XCTFail("Errore durante la chiamata API o decoding: \(error)")
        }
    }
}
