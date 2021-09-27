//
//  Interface.swift
//  EventShortClient
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation
import Combine

public struct EventShortClient {
    public var list: (EventShortListRequest?) -> AnyPublisher<EventShortListResponse, Error>
    public var roomMapping: () -> AnyPublisher<[String:String], Error>

    public init(
        list: @escaping (EventShortListRequest?) -> AnyPublisher<EventShortListResponse, Error>,
        roomMapping: @escaping () -> AnyPublisher<[String:String], Error>
    ) {
        self.list = list
        self.roomMapping = roomMapping
    }
}
