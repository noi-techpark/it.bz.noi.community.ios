//
//  DependencyContainer.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import EventShortClient

final class DependencyContainer {
    let eventShortClient: EventShortClient

    init(eventShortClient: EventShortClient) {
        self.eventShortClient = eventShortClient
    }
}

// MARK: ViewModelFactory
extension DependencyContainer: ViewModelFactory {
    func makeEventsViewModel() -> EventsViewModel {
        EventsViewModel(eventShortClient: eventShortClient)
    }
}

// MARK: ViewControllerFactory
extension DependencyContainer: ViewControllerFactory {
    func makeEventListViewController() -> EventListViewController {
        EventListViewController(items: [])
    }
}
