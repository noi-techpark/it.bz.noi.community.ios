//
//  Mocks.swift
//  EventShortClient
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation
import Combine

extension EventShortClient {
    public static let empty = Self(
        list: { _ in
            Just(EventShortListResponse(
                totalResults: 0,
                totalPages: 0,
                currentPage: 1,
                onlineResults: nil,
                resultId: nil,
                seed: nil,
                items: []
            ))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        },
        roomMapping: {
            Just([:])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )
    
    public static let happyPath = Self(
        list: { _ in
            Just(EventShortListResponse(
                totalResults: 0,
                totalPages: 0,
                currentPage: 1,
                onlineResults: nil,
                resultId: nil,
                seed: nil,
                items: []
            ))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        },
        roomMapping: {
            Just([:])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )
    
    public static let failed = Self(
        list: { _ in
            Fail(error: NSError(domain: "", code: 1))
                .eraseToAnyPublisher()
        },
        roomMapping: {
            Fail(error: NSError(domain: "", code: 1))
                .eraseToAnyPublisher()
        }
    )
}
