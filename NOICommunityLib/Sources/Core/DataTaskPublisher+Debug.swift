// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  DataTaskPublisher+Debug.swift
//  
//
//  Created by Matteo Matassoni on 04/12/23.
//

import Foundation
import Combine

public extension Publisher where Output == URLSession.DataTaskPublisher.Output {

    func debug() -> AnyPublisher<Publishers.HandleEvents<Self>.Output, Publishers.HandleEvents<Self>.Failure> {
        handleEvents(receiveOutput: { output in
#if DEBUG
            DataTaskOutput(data: output.data, response: output.response)
                .debug()
#endif
        })
        .eraseToAnyPublisher()
    }

    private func debug(data: Data, response: URLResponse) {
        
    }
}

private struct DataTaskOutput {

    var data: Data
    var response: URLResponse

    func debug() {
        let statusCode = (response as! HTTPURLResponse).statusCode
        print("[HTTP] RESPONSE FROM: \(response.url?.absoluteString ?? String.notAvailable)")
        print("[HTTP] STATUS: \(statusCode)")

        if let httpHeaders = (response as? HTTPURLResponse)?.allHeaderFields,
           !httpHeaders.isEmpty {
            print("[HTTP] HEADERS:")
            for (key, value) in httpHeaders {
                print("[HTTP] - \(key): \(String(describing: value))")
            }
        }

        if let contentType = (response as? HTTPURLResponse)?.contentType {
            print("[HTTP] Content-Type: \(contentType)")
        }

        let encoding: String.Encoding = (response as? HTTPURLResponse)?.charset() ?? .utf8
        if let bodyContent = String(data: data, encoding: encoding) {
            print("[HTTP] BODY START")
            print("[HTTP] \(bodyContent)")
            print("[HTTP] BODY END")
        }
    }
}

extension String {

    static var notAvailable: String {
        "N/A"
    }
}

extension URLRequest {

    func debug() {
        print("[HTTP] REQUEST TO: \(url?.absoluteString ?? String.notAvailable)")
        print("[HTTP] METHOD: \(httpMethod ?? String.notAvailable)")

        if let httpHeaders = allHTTPHeaderFields,
           !httpHeaders.isEmpty {
            print("[HTTP] HEADERS:")
            for (key, value) in httpHeaders {
                print("[HTTP] - \(key): \(value)")
            }
        }

        if
            let url,
            let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            print("[HTTP] - COOKIES START")
            for cookie in cookies {
                cookie.debug()
            }
            print("[HTTP] - COOKIES END")
        }

        if let contentType = contentType {
            print("[HTTP] Content-Type: \(contentType)")
        }

        if let bodyData = httpBody {
            let encoding: String.Encoding = charset() ?? .utf8
            if let bodyContent = String(data: bodyData, encoding: encoding) {
                print("[HTTP] BODY START")
                print("[HTTP] \(bodyContent)")
                print("[HTTP] BODY END")
            }
        }
    }

}

private typealias ContentTypeValue = String
private var contentTypeKey = "Content-Type"

private func encoding(from contentType: ContentTypeValue) -> String.Encoding {
    let defaultEncoding: String.Encoding = .utf8

    let parts = contentType.split(separator: ";")
    guard !parts.isEmpty
    else { return defaultEncoding }

    for parameter in parts[1...] {
        let parameterParts = parameter
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "=")
        guard parameterParts.count >= 2
        else { continue }

        let token = parameterParts[0]
        let value = String(parameterParts[1])
        if token.caseInsensitiveCompare("charset") == .orderedSame {
            do {
                let encoding = try String.Encoding(value: value)
                return encoding
            } catch {
                print("[HTTP] ERROR: \(error.localizedDescription)")
                return defaultEncoding
            }
        }
    }

    return defaultEncoding
}

private extension HTTPURLResponse {
    var contentType: String? {
        allHeaderFields[contentTypeKey] as? String
    }

    func charset() -> String.Encoding? {
        contentType.flatMap { encoding(from: $0) }
    }
}

private extension String.Encoding {

    struct UnknownEncodingError: Error {
        let value: String
    }

    init(value: String) throws {
        switch value {
        case let charset where charset.caseInsensitiveCompare("UTF-8") == .orderedSame:
            self = .utf8
        case let charset where charset.caseInsensitiveCompare("utf-16") == .orderedSame:
            self = .utf16
        case let charset where charset.caseInsensitiveCompare("UTF-16BE") == .orderedSame:
            self = .utf16BigEndian
        case let charset where charset.caseInsensitiveCompare("UTF-16LE") == .orderedSame:
            self = .utf16LittleEndian
        case let charset where charset.caseInsensitiveCompare("UTF-32") == .orderedSame:
            self = .utf32
        case let charset where charset.caseInsensitiveCompare("UTF-32") == .orderedSame:
            self = .utf32
        case let charset where charset.caseInsensitiveCompare("ascii") == .orderedSame:
            self = .ascii
        default:
            throw UnknownEncodingError(value: value)
        }
    }
}

private extension NSURLRequest {
    var contentType: String? {
        allHTTPHeaderFields?[contentTypeKey]
    }

    func charset() -> String.Encoding? {
        contentType.flatMap { encoding(from: $0) }
    }
}

private extension URLRequest {
    var contentType: String? {
        allHTTPHeaderFields?[contentTypeKey]
    }

    func charset() -> String.Encoding? {
        contentType.flatMap { encoding(from: $0) }
    }
}

private extension HTTPCookie {

    func debug() {
        print("[HTTP] - %@", [
            "version: \(version)",
            "name: \(name)",
            "value: \(value)",
            "expiresDate: \(String(describing: expiresDate))",
            "sessionOnly: \(isSessionOnly ? "true" : "false")",
            "domain: \(domain)",
            "path: \(path)",
            "isSecure: \(isSecure ? "true" : "false")"
        ].joined(separator: ", "))
    }

}

