//
//  DependencyContainer.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import EventShortClient
import AppPreferencesClient

// MARK: - DependencyContainer

final class DependencyContainer {
    let eventShortClient: EventShortClient
    let appPreferencesClient: AppPreferencesClient

    init(
        eventShortClient: EventShortClient,
        appPreferencesClient: AppPreferencesClient
    ) {
        self.eventShortClient = eventShortClient
        self.appPreferencesClient = appPreferencesClient
    }
}

// MARK: ViewModelFactory

extension DependencyContainer: ViewModelFactory {
    func makeLoadAppPreferencesViewModel() -> LoadAppPreferencesViewModel {
        LoadAppPreferencesViewModel(appPreferencesClient: appPreferencesClient)
    }

    func makeUpdateAppPreferencesViewModel() -> UpdateAppPreferencesViewModel {
        UpdateAppPreferencesViewModel(appPreferencesClient: appPreferencesClient)
    }

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
