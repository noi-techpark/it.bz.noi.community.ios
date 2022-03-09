//
//  DependencyContainer.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import EventShortClient
import AppPreferencesClient
import EventShortTypesClient

// MARK: - DependencyContainer

final class DependencyContainer {

    let eventShortClient: EventShortClient
    let appPreferencesClient: AppPreferencesClient
    let eventShortTypesClient: EventShortTypesClient

    init(
        eventShortClient: EventShortClient,
        appPreferencesClient: AppPreferencesClient,
        eventShortTypesClient: EventShortTypesClient
    ) {
        self.eventShortClient = eventShortClient
        self.appPreferencesClient = appPreferencesClient
        self.eventShortTypesClient = eventShortTypesClient
    }

}

// MARK: ViewModelFactory

extension DependencyContainer: ViewModelFactory {

    func makeLoadAppPreferencesViewModel() -> LoadAppPreferencesViewModel {
        .init(appPreferencesClient: appPreferencesClient)
    }

    func makeUpdateAppPreferencesViewModel() -> UpdateAppPreferencesViewModel {
        .init(appPreferencesClient: appPreferencesClient)
    }

    func makeEventsViewModel(
        showFiltersHandler: @escaping () -> Void
    ) -> EventsViewModel {
        let supportedPreferredLanguage = Bundle.main.preferredLocalizations
            .lazy
            .compactMap(Language.init(rawValue:))
            .first
        return .init(
            eventShortClient: eventShortClient,
            language: supportedPreferredLanguage,
            showFiltersHandler: showFiltersHandler
        )
    }

    func makeEventFiltersViewModel(
        showFilteredResultsHandler: @escaping () -> Void
    ) -> EventFiltersViewModel {
        .init(
            eventShortTypes: eventShortTypesClient,
            showFilteredResultsHandler: showFilteredResultsHandler
        )
    }

}

// MARK: ViewControllerFactory

extension DependencyContainer: ViewControllerFactory {

    func makeEventListViewController() -> EventListViewController {
        .init(items: [])
    }

    func makeEventFiltersViewController(
        viewModel: EventFiltersViewModel
    ) -> EventFiltersViewController {
        .init(viewModel: viewModel)
    }

}
