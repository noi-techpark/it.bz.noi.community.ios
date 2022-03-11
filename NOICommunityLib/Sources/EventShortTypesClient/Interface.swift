//
//  Interface.swift
//  EventShortTypesClient
//
//  Created by Matteo Matassoni on 23/02/22.
//

import Foundation
import Combine

public struct EventShortTypesClient {

    public var filters: () -> AnyPublisher<[EventsFilter], Error>

    public init(
        filters: @escaping () -> AnyPublisher<[EventsFilter], Error>
    ) {
        self.filters = filters
    }
}
