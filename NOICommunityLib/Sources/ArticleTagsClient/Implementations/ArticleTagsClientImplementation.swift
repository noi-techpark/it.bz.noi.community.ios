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
import Combine

public final class ArticleTagsClientImplementation: ArticleTagsClient {

    private let baseURL: URL

    private let transport: Transport
    
    private let memoryCache: Cache<String, ArticleTagListResponse>
    
    private let diskCacheFileURL: URL?

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
        return jsonDecoder
    }()
    
    public enum CacheKey: Int {
        case newsFilters = 0
    }

    public init(
        baseURL: URL,
        transport: Transport,
        memoryCache: Cache<String, ArticleTagListResponse>,
        diskCacheFileURL: URL? = nil
    ) {
        self.baseURL = baseURL
        self.transport = transport
            .checkingStatusCodes()
            .addingJSONHeaders()
        self.memoryCache = memoryCache
        self.diskCacheFileURL = diskCacheFileURL
    }
    
    public func getArticleTagList() async throws -> ArticleTagListResponse {
            let cacheKey = "articleTagList"

            // Controlla se il dato è già in cache (memoria)
            if let cachedData = memoryCache[cacheKey] {
                return cachedData
            }

            // Prova a leggere dal file di cache su disco (se disponibile)
            if let fileURL = diskCacheFileURL,
               let data = try? Data(contentsOf: fileURL),
               let cachedResponse = try? jsonDecoder.decode(ArticleTagListResponse.self, from: data) {
                memoryCache[cacheKey] = cachedResponse
                return cachedResponse
            }

            // Scarica i dati dalla rete e aggiorna la cache
            let request = Endpoint
                .articleTagList()
                .makeRequest(withBaseURL: baseURL)

            let (data, _) = try await transport.send(request: request)

            try Task.checkCancellation()

            let response = try jsonDecoder.decode(ArticleTagListResponse.self, from: data)

            // Salva nella cache in memoria
            memoryCache[cacheKey] = response

            // Se c'è un file di cache, salva su disco
            if let fileURL = diskCacheFileURL {
                try? data.write(to: fileURL)
            }

            return response
        }

}

