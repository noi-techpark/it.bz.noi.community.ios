// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Mocks.swift
//  EventShortTypesClient
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Foundation
import Combine

extension EventShortTypesClient {
    public static let empty = Self(
        filters: {
            Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )
    
    public static let happyPath = Self(
        filters: {
            Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )
    
    public static let failed = Self(
        filters: {
            Fail(error: NSError(domain: "", code: 1))
                .eraseToAnyPublisher()
        }
    )
}
