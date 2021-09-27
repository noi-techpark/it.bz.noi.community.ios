//
//  Live.swift
//  EventShortClientLive
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Combine
import Foundation
import EventShortClient

private let baseUrl = URL(string: "https://tourism.opendatahub.bz.it")!

extension EventShortClient {
    public static let live = Self(
        list: { request in
            var components = URLComponents(
                url: baseUrl,
                resolvingAgainstBaseURL: false
            )!
            components.path = "/v1/EventShort"
            let queryItems: [URLQueryItem] = .init(from: request)
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            let serviceUrl = components.url!

            return URLSession.shared
                .dataTaskPublisher(for: serviceUrl)
                .map { data, _ in data }
                .decode(
                    type: EventShortListResponse.self,
                    decoder: eventsJsonDecoder
                )
                .eraseToAnyPublisher()
        },
        roomMapping: {
            var components = URLComponents(
                url: baseUrl,
                resolvingAgainstBaseURL: false
            )!
            components.path = "/v1/EventShort/RoomMapping"
            let serviceUrl = components.url!

            return URLSession.shared
                .dataTaskPublisher(for: serviceUrl)
                .map { data, _ in data }
                .decode(
                    type: [String:String].self,
                    decoder: eventsJsonDecoder
                )
                .eraseToAnyPublisher()
        }
    )
}


private extension Array where Element == URLQueryItem {
    init(from eventShortRequest: EventShortListRequest?) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        var result: [URLQueryItem] = []
        if let pageNumber = eventShortRequest?.pageNumber {
            result.append(URLQueryItem(
                            name: "pagenumber",
                            value: "\(pageNumber)"))
        }
        if let pageSize = eventShortRequest?.pageSize {
            result.append(URLQueryItem(
                            name: "pagesize",
                            value: "\(pageSize)"))
        }
        if let startDate = eventShortRequest?.startDate {
            result.append(URLQueryItem(
                name: "startdate",
                value: dateFormatter.string(from: startDate)))
        }
        if let endDate = eventShortRequest?.endDate {
            result.append(URLQueryItem(
                            name: "enddate",
                            value: dateFormatter.string(from: endDate)))
        }
        if let source = eventShortRequest?.source {
            result.append(URLQueryItem(
                            name: "source",
                            value: source.rawValue))
        }
        if let eventLocation = eventShortRequest?.eventLocation {
            result.append(URLQueryItem(
                            name: "eventlocation",
                            value: eventLocation.rawValue))
        }
        if let onlyActive = eventShortRequest?.onlyActive {
            result.append(URLQueryItem(
                            name: "onlyactive",
                            value: onlyActive ? "true" : "false"))
        }
        if let eventIds = eventShortRequest?.eventIds {
            result.append(URLQueryItem(
                            name: "eventids",
                            value: eventIds.joined(separator: ",")))
        }
        if let webAddress = eventShortRequest?.webAddress {
            result.append(URLQueryItem(
                            name: "webaddress",
                            value: webAddress)
            )
        }
        if let sortOrder = eventShortRequest?.sortOrder {
            result.append(URLQueryItem(
                            name: "sortorder",
                            value: sortOrder.rawValue))
        }
        if let seed = eventShortRequest?.seed {
            result.append(URLQueryItem(
                            name: "seed",
                            value: "\(seed)"))
        }
        if let language = eventShortRequest?.language {
            result.append(URLQueryItem(
                            name: "language",
                            value: language))
        }
        if let langFilter = eventShortRequest?.langFilter {
            result.append(URLQueryItem(
                            name: "langfilter",
                            value: langFilter.joined(separator: ",")))
        }
        if let fields = eventShortRequest?.fields {
            result.append(URLQueryItem(
                            name: "fields",
                            value: fields.joined(separator: ",")))
        }
        if let lastChange = eventShortRequest?.lastChange {
            result.append(URLQueryItem(
                            name: "lastchange",
                            value: dateFormatter.string(from: lastChange)))
        }
        if let searchFilter = eventShortRequest?.searchFilter {
            result.append(URLQueryItem(
                            name: "searchfilter",
                            value: searchFilter)
            )
        }
        if let rawFilter = eventShortRequest?.rawFilter {
            result.append(URLQueryItem(
                            name: "rawfilter",
                            value: rawFilter)
            )
        }
        if let rawSort = eventShortRequest?.rawSort {
            result.append(URLQueryItem(
                            name: "rawsort",
                            value: rawSort)
            )
        }
        if let removeNullValues = eventShortRequest?.removeNullValues {
            result.append(URLQueryItem(
                            name: "removenullvalues",
                            value: removeNullValues ? "true" : "false"))
        }
        self = result
    }
}

private extension String {
    func firstCharLowercased() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}

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

private let eventsJsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()

    jsonDecoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode date string \(dateStr)"
        )
    }

    jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
    return jsonDecoder
}()

/// A type that has an "empty" representation.
public protocol EmptyRepresentable {
    static func empty() -> Self
}

extension Array: EmptyRepresentable {
    public static func empty() -> Array<Element> {
        return Array()
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: Decodable & EmptyRepresentable {
        if let result = try decodeIfPresent(T.self, forKey: key) {
            return result
        } else {
            return T.empty()
        }
    }
}
