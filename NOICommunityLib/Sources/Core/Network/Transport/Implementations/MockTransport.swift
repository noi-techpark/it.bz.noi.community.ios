// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MockTransport.swift
//  Core
//
//  Created by Matteo Matassoni on 27/08/24.
//

import Foundation

public final class MockTransport: Transport {

    public let data: Data
    public let response: HTTPURLResponse

    public init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }

    public convenience init(statusCode: Int, data: Data = .init()) {
        self.init(
            data: data,
            response: .init(
                url: URL(string: "example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
        )
    }

    public func send(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        (data, response)
    }

}

extension MockTransport {

    public static func ok(data: Data = .init()) -> MockTransport {
        MockTransport(statusCode: 200, data: data)
    }

    public static func serverError(data: Data = .init()) -> MockTransport {
        MockTransport(statusCode: 500, data: data)
    }

}
