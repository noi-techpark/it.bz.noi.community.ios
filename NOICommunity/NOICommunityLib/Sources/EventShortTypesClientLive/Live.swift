//
//  Live.swift
//  EventShortTypesClientLive
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Foundation
import Combine
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

                return urlSession
                    .dataTaskPublisher(for: urlComponents.url!)
                    .map { data, _ in data }
                    .decode(
                        type: [EventsFilter].self,
                        decoder: jsonDecoder
                    )
                    .eraseToAnyPublisher()
            }
        )
    }

    public static func live(fileURL: URL) -> Self {
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
