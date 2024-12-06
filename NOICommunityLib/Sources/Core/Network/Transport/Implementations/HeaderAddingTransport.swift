// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  StatusCodeCheckingTransport.swift
//  Core
//
//  Created by Matteo Matassoni on 27/08/24.
//

import Foundation

// MARK: - StatusCodeCheckingTransport

public final class HeaderAddingTransport: Transport {

    let wrapped: Transport
    let headers: [String: String]

    public init(wrapping: Transport, headers: [String: String]) {
        self.wrapped = wrapping
        self.headers = headers
    }

    public func send(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var mutableCopy = request
        for (key, value) in headers {
            mutableCopy.addValue(value, forHTTPHeaderField: key)
        }

        return try await wrapped.send(request: request)
    }

}

// MARK: - Transport+addingJSONHeaders

public extension Transport {

    func addingJSONHeaders() -> Transport {
        HeaderAddingTransport(
            wrapping: self,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json",
            ]
        )
    }

}

// MARK: - Transport+addingJSONHeaders

public extension Transport {

    func authenticated(withBearerToken accessToken: String) -> Transport {
        HeaderAddingTransport(
            wrapping: self,
            headers: [
                "Authorization": "Bearer \(accessToken)"
            ]
        )
    }

}


