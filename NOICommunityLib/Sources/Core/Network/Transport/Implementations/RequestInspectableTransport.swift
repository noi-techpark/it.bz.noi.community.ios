// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  RequestInspectableTransport.swift
//  Core
//
//  Created by Matteo Matassoni on 27/08/24.
//

import Foundation

public final class RequestInspectableTransport: Transport {

    public var lastSeenRequest: URLRequest?

    let wrapping: Transport

    public init(wrapping: Transport) {
        self.wrapping = wrapping
    }

    public func send(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        lastSeenRequest = request
        return try await wrapping.send(request: request)
    }

}
