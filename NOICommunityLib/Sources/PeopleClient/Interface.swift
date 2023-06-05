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

public struct PeopleClient {
    
    public var people: (String) -> AnyPublisher<[Person], Error>
    public var companies: (String) -> AnyPublisher<[Company], Error>
    
    public init(
        people: @escaping (String) -> AnyPublisher<[Person], Error>,
        companies: @escaping (String) -> AnyPublisher<[Company], Error>
    ) {
        self.people = people
        self.companies = companies
    }
}
