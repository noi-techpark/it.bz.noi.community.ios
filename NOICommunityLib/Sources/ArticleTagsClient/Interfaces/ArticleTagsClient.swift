// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticleTagsClient.swift
//  ArticleTagsClient
//
//  Created by Camilla on 18/02/25.
//

import Foundation
import Combine

public protocol ArticleTagsClient {
    
    func getArticleTagList() async throws -> ArticleTagListResponse
    
    func getArticleTagListPublisher() -> AnyPublisher<[ArticleTag], Error>
    
}

public extension ArticleTagsClient {
    
    func getArticleTagList() async throws -> ArticleTagListResponse {
        try await getArticleTagList()
    }
    
    func getArticleTagListPublisher() -> AnyPublisher<[ArticleTag], Error> {
        getArticleTagListPublisher()
    }

}




