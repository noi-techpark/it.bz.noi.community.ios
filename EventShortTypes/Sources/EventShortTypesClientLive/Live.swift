//
//  Live.swift
//  EventShortTypesClientLive
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Combine
import Foundation
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

private extension String {
    func firstCharLowercased() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}

// MARK: - JSONDecoder.KeyDecodingStrategy+PascalCase

extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromPascalCase: JSONDecoder.KeyDecodingStrategy {
        return .custom { keys -> CodingKey in
            // keys array is never empty
            let key = keys.last!
            // Do not change the key for an array
            guard key.intValue == nil else {
                return key
            }
            
            let codingKeyType = type(of: key)
            let newStringValue = key.stringValue.firstCharLowercased()
            
            return codingKeyType.init(stringValue: newStringValue)!
        }
    }
}

// MARK: - EmptyRepresentable

/// A type that has an "empty" representation.
public protocol EmptyRepresentable {
    static func empty() -> Self
}

// MARK: - Array+EmptyRepresentable

extension Array: EmptyRepresentable {
    public static func empty() -> Array<Element> {
        []
    }
}

// MARK: - Dictionary+EmptyRepresentable

extension Dictionary: EmptyRepresentable {
    public static func empty() -> Dictionary<Key, Value> {
        [:]
    }
}

// MARK: - KeyedDecodingContainer+EmptyRepresentable
extension KeyedDecodingContainer {
    public func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> T where T: Decodable & EmptyRepresentable {
        if let result = try decodeIfPresent(T.self, forKey: key) {
            return result
        } else {
            return T.empty()
        }
    }
}
