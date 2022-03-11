//
//  Live.swift
//  EventShortTypesClientLive
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Foundation
import Combine
import SwiftCache
import PascalJSONDecoder
import DecodeEmptyRepresentable
import EventShortTypesClient

// MARK: - Private Constants

private let baseUrl = URL(string: "https://tourism.opendatahub.bz.it")!
private let jsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
    return jsonDecoder
}()

// MARK: - EventShortTypesClient+Live

extension EventShortTypesClient {

    public static func live(urlSession: URLSession = .shared) -> Self {
        Self(
            filters: {
                urlSession
                    .dataTaskPublisher(for: requestURL())
                    .map { data, _ in data }
                    .decode(
                        type: [EventsFilter].self,
                        decoder: jsonDecoder
                    )
                    .eraseToAnyPublisher()
            }
        )
    }

    public static func file(url fileURL: URL) -> Self {
        Self(
            filters: {
                FilePublisher(fileURL: fileURL)
                    .subscribe(on: DispatchQueue.global(qos: .background))
                    .decode(
                        type: [EventsFilter].self,
                        decoder: jsonDecoder
                    )
                    .eraseToAnyPublisher()
            }
        )
    }

    public enum CacheKey: Int {
        case eventsFilters = 0
    }

    public static func live(
        memoryCache cache: Cache<CacheKey, [EventsFilter]>,
        diskCacheFileURL fileURL: URL,
        urlSession: URLSession = .shared
    ) -> Self {
        return Self(
            filters: {
                // If filters are available on memory cache use just them
                if let filters = cache[.eventsFilters] {
                    return Just(filters)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                // Otherwise fetch the filters first from disk cache and
                // from its REST service caching the response to disk.
                // If the REST service call fails get the filters from disk.
                // In any case cache the fetched filters to memory.
                let diskCachePublisher = FilePublisher(fileURL: fileURL)
                    .map { data -> Data in
                        return data
                    }
                let restPublisher = urlSession
                    .dataTaskPublisher(for: requestURL())
                    .mapError { $0 as Error }
                    .map { data, _ -> Data in
                        let jsonString = String(
                            data: data,
                            encoding: .utf8
                        )
                        try? jsonString?.write(
                            to: fileURL,
                            atomically: true,
                            encoding: .utf8
                        )
                        return data
                    }
                let restOrDiskCachePublisher = restPublisher
                    .catch { _ in
                        diskCachePublisher
                    }
                return diskCachePublisher
                    .append(restOrDiskCachePublisher)
                    .decode(
                        type: [EventsFilter].self,
                        decoder: jsonDecoder
                    )
                    .map { filters in
                        cache[.eventsFilters] = filters
                        return filters
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
}

// MARK: Private APIs

private extension EventShortTypesClient {

    static func requestURL() -> URL {
        var urlComponents = URLComponents(
            url: baseUrl,
            resolvingAgainstBaseURL: false
        )!
        urlComponents.path = "/v1/EventShortTypes"
        urlComponents.queryItems = EventShortTypesListRequest(
            fields: ["Id", "Key", "Type", "TypeDesc"],
            rawFilter: #"or(eq(Type,"TechnologyFields"),and(eq(Type,"CustomTagging"),eq(Parent,"EventType")))"#
        )
            .asURLQueryItems()
        return urlComponents.url!
    }

}

// MARK: - EventShortTypesListRequest+URLQueryItem

private struct EventShortTypesListRequest {
    public let fields: [String]?
    public let rawFilter: String?

    func asURLQueryItems() -> [URLQueryItem]? {
        var result: [URLQueryItem] = []
        
        if let fields = fields {
            result.append(URLQueryItem(
                name: "fields",
                value: fields.joined(separator: ",")))
        }
        if let rawFilter = rawFilter {
            result.append(URLQueryItem(
                name: "rawfilter",
                value: rawFilter)
            )
        }

        return result.isEmpty ? nil : result
    }

}
