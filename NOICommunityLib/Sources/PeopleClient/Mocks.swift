// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Mocks.swift
//  PeopleClient
//
//  Created by Matteo Matassoni on 23/05/22.
//

import Foundation
import Combine

extension PeopleClient {
    
    public static let empty = Self(
        people: { _ in
            Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        },
        companies: { _ in
            Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )
    
    public static let happyPath = empty
    
    public static let failed = Self(
        people: { _ in
            Fail(error: NSError(domain: "", code: 1))
                .eraseToAnyPublisher()
        },
        companies: { _ in
            Fail(error: NSError(domain: "", code: 1))
                .eraseToAnyPublisher()
        }
    )
    
}
