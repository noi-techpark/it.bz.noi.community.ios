//
//  DependencyContainer.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import EventShortClient

// MARK: - DependencyContainer

final class DependencyContainer {
    let eventShortClient: EventShortClient

    init(eventShortClient: EventShortClient) {
        self.eventShortClient = eventShortClient
    }
}

// MARK: ViewModelFactory

extension DependencyContainer: ViewModelFactory {
    func makeEventsViewModel() -> EventsViewModel {
        let supportedPreferredLanguage = Bundle.main.preferredLocalizations
            .lazy
            .compactMap(Language.init(rawValue:))
            .first
        return EventsViewModel(
            eventShortClient: eventShortClient,
            language: supportedPreferredLanguage
        )
    }
}

// MARK: ViewControllerFactory

extension DependencyContainer: ViewControllerFactory {
    func makeEventListViewController() -> EventListViewController {
        EventListViewController(items: [])
    }
}
