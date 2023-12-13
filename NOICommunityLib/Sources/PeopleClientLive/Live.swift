// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Interface.swift
//  PeopleClient
//
//  Created by Matteo Matassoni on 20/05/22.
//

import Foundation
import Combine
import Core
import PeopleClient

// MARK: - PeopleClient+Live
    
extension PeopleClient {
    
    public static func live(
        baseURL: URL,
        urlSession: URLSession = .shared
    ) -> Self {
        Self(
            people: { accessToken in
                var urlRequest = Endpoint.contacts()
                    .makeRequest(withBaseURL: baseURL)
                urlRequest.allHTTPHeaderFields = [
                    "Authorization": "Bearer \(accessToken)",
                    "Accept": "application/json"
                ]

                return urlSession
                    .dataTaskPublisher(for: urlRequest)
                    .debug()
                    .map(\.data)
                    .decode(
                        type: PeopleResponse.self,
                        decoder: JSONDecoder()
                    )
                    .map(\.people)
                    .eraseToAnyPublisher()
            },
            companies: { accessToken in
                var urlRequest = Endpoint.accounts()
                    .makeRequest(withBaseURL: baseURL)
                urlRequest.allHTTPHeaderFields = [
                    "Authorization": "Bearer \(accessToken)",
                    "Accept": "application/json"
                ]
                
                return urlSession
                    .dataTaskPublisher(for: urlRequest)
                    .debug()
                    .map(\.data)
                    .decode(
                        type: CompanyResponse.self,
                        decoder: JSONDecoder()
                    )
                    .map(\.companies)
                    .eraseToAnyPublisher()
            }
        )
    }
    
}
