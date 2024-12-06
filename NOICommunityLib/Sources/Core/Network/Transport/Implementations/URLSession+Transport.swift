// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  URLSession+Transport.swift
//  Core
//
//  Created by Matteo Matassoni on 27/08/24.
//

import Foundation

public struct InvalidResponseError: Error {}

extension URLSession: Transport {

    public func send(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await data(for: request)
        guard let httpResponse = response as? HTTPURLResponse
        else { throw InvalidResponseError() }

        return (data, httpResponse)
    }

}
