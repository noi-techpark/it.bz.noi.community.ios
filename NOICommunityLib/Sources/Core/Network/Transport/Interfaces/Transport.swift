// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Transport.swift
//  Core
//
//  Created by Matteo Matassoni on 27/08/24.
//

import Foundation

public protocol Transport {

    func send(request: URLRequest) async throws -> (Data, HTTPURLResponse)

}

public extension Transport {

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let request = URLRequest(url: url)
        return try await send(request: request)
    }

}
