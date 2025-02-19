// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArticleTagsClientImplementation.swift
//  NOICommunityLib
//
//  Created by Camilla on 18/02/25.
//

import Foundation
import Core

public final class ArticleTagsClientImplementation: ArticleTagsClient {

    private let baseURL: URL

    private let transport: Transport

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
        return jsonDecoder
    }()

    public init(
        baseURL: URL,
        transport: Transport
    ) {
        self.baseURL = baseURL
        self.transport = transport
            .checkingStatusCodes()
            .addingJSONHeaders()
    }

    public func getArticleTagList() async throws -> ArticleTagListResponse {
        let request = Endpoint
            .articleTagList()
            .makeRequest(withBaseURL: baseURL)

        let (data, _) = try await transport.send(request: request)

        try Task.checkCancellation()

        return try jsonDecoder.decode(ArticleTagListResponse.self, from: data)
    }

}

