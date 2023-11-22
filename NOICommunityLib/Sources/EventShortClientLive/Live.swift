// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Live.swift
//  EventShortClientLive
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation
import Combine
import PascalJSONDecoder
import DecodeEmptyRepresentable
import EventShortClient

// MARK: - Private Constants

private let baseUrl = URL(string: "https://tourism.opendatahub.com")!
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
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
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

// MARK: - EventShortClient+Live

extension EventShortClient {
    public static func live(urlSession: URLSession = .shared) -> Self {
        Self(
            list: { request in
                var urlComponents = URLComponents(
                    url: baseUrl,
                    resolvingAgainstBaseURL: false
                )!
                urlComponents.path = "/v1/EventShort"
                if let request = request {
                    urlComponents.queryItems = request.asURLQueryItems()
                }
                
                return urlSession
                    .dataTaskPublisher(for: urlComponents.url!)
                    .map(\.data)
                    .decode(
                        type: EventShortListResponse.self,
                        decoder: eventsJsonDecoder
                    )
                    .eraseToAnyPublisher()
            },
            roomMapping: { language in
                var urlComponents = URLComponents(
                    url: baseUrl,
                    resolvingAgainstBaseURL: false
                )!
                urlComponents.path = "/v1/EventShort/RoomMapping"
                if let language = language {
                    urlComponents.queryItems = [language.asURLQueryItem()]
                }
                
                return URLSession.shared
                    .dataTaskPublisher(for: urlComponents.url!)
                    .map(\.data)
                    .decode(
                        type: [String:String].self,
                        decoder: eventsJsonDecoder
                    )
                    .eraseToAnyPublisher()
            }
        )
    }
}

// MARK: - EventShortListRequest+URLQueryItem

private extension EventShortListRequest {
    func asURLQueryItems() -> [URLQueryItem]? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var result: [URLQueryItem] = []
        
        if let pageNumber = pageNumber {
            result.append(URLQueryItem(
                name: "pagenumber",
                value: "\(pageNumber)"))
        }
        if let pageSize = pageSize {
            result.append(URLQueryItem(
                name: "pagesize",
                value: "\(pageSize)"))
        }
        if let startDate = startDate {
            result.append(URLQueryItem(
                name: "startdate",
                value: dateFormatter.string(from: startDate)))
        }
        if let endDate = endDate {
            result.append(URLQueryItem(
                name: "enddate",
                value: dateFormatter.string(from: endDate)))
        }
        if let source = source {
            result.append(URLQueryItem(
                name: "source",
                value: source.rawValue))
        }
        if let eventLocation = eventLocation {
            result.append(URLQueryItem(
                name: "eventlocation",
                value: eventLocation.rawValue))
        }
        if let onlyActive = onlyActive {
            result.append(URLQueryItem(
                name: "onlyactive",
                value: onlyActive ? "true" : "false"))
        }
        if let eventIds = eventIds {
            result.append(URLQueryItem(
                name: "eventids",
                value: eventIds.joined(separator: ",")))
        }
        if let webAddress = webAddress {
            result.append(URLQueryItem(
                name: "webaddress",
                value: webAddress)
            )
        }
        if let sortOrder = sortOrder {
            result.append(URLQueryItem(
                name: "sortorder",
                value: sortOrder.rawValue))
        }
        if let seed = seed {
            result.append(URLQueryItem(
                name: "seed",
                value: "\(seed)"))
        }
        if let language = language {
            result.append(URLQueryItem(
                name: "language",
                value: language))
        }
        if let langFilter = langFilter {
            result.append(URLQueryItem(
                name: "langfilter",
                value: langFilter.joined(separator: ",")))
        }
        if let fields = fields {
            result.append(URLQueryItem(
                name: "fields",
                value: fields.joined(separator: ",")))
        }
        if let lastChange = lastChange {
            result.append(URLQueryItem(
                name: "lastchange",
                value: dateFormatter.string(from: lastChange)))
        }
        if let searchFilter = searchFilter {
            result.append(URLQueryItem(
                name: "searchfilter",
                value: searchFilter)
            )
        }
        if let rawFilter = rawFilter {
            result.append(URLQueryItem(
                name: "rawfilter",
                value: rawFilter)
            )
        }
        if let rawSort = rawSort {
            result.append(URLQueryItem(
                name: "rawsort",
                value: rawSort)
            )
        }
        if let removeNullValues = removeNullValues {
            result.append(URLQueryItem(
                name: "removenullvalues",
                value: removeNullValues ? "true" : "false"))
        }
        if let optimizeDates = optimizeDates {
            result.append(URLQueryItem(
                name: "optimizedates",
                value: optimizeDates ? "true" : "false"))
        }
        
        return result.isEmpty ? nil : result
    }
}

// MARK: - Language+URLQueryItem

private extension Language {
    func asURLQueryItem() -> URLQueryItem {
        URLQueryItem(name: "language", value: rawValue)
    }
}
