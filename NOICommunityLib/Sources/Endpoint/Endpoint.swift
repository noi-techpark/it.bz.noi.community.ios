// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint.swift
//  TofaneSDK
//
//  Created by Matteo Matassoni on 04/08/21.
//

import Foundation

public struct Endpoint {

    var path: String
    
    var queryItems: [URLQueryItem]

    public init(
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.queryItems = queryItems
    }

    private func makeURL(withBaseURL baseURL: URL) -> URL {
        guard var components = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: false
        )
        else { preconditionFailure("Invalid baseURL: \(baseURL)") }

        components.path += path
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url
        else { preconditionFailure("Invalid URL components: \(components)") }

        return url
    }

    public func makeRequest(withBaseURL baseURL: URL) -> URLRequest {
        URLRequest(url: makeURL(withBaseURL: baseURL))
    }
}
