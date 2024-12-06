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

private let validStatus = 200..<300

// MARK: - StatusCodeError

public struct StatusCodeError: Error {

    var statusCode: Int

}

// MARK: - StatusCodeCheckingTransport

public final class StatusCodeCheckingTransport: Transport {

    let wrapped: Transport

    public init(wrapping wrapped: Transport) {
        self.wrapped = wrapped
    }

    public func send(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await wrapped.send(request: request)
        guard validStatus.contains(response.statusCode)
        else { throw StatusCodeError(statusCode: response.statusCode) }

        return (data, response)
    }

}

// MARK: - Transport+checkingStatusCodes

public extension Transport {

    func checkingStatusCodes() -> Transport {
        StatusCodeCheckingTransport(wrapping: self)
    }

}


