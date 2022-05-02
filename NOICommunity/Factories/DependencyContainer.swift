//
//  DependencyContainer.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import Combine
import AppAuth
import AppPreferencesClient
import AuthStateStorageClient
import AuthClient
import EventShortClient
import EventShortTypesClient
import SwiftCache

// MARK: - DependencyContainer

final class DependencyContainer {
    
    let appPreferencesClient: AppPreferencesClient
    let isAutorizedClient: () -> Bool
    let hasAccessGrantedClient: () -> Bool
    let authClient: AuthClient
    let eventShortClient: EventShortClient
    let eventShortTypesClient: EventShortTypesClient
    
    private var _userInfoCache: Cache<MyAccountViewModel.CacheKey, UserInfo>?
    private var userInfoCache: Cache<MyAccountViewModel.CacheKey, UserInfo>! {
        get {
            if let userInfoCache = _userInfoCache {
                return userInfoCache
            } else {
                let userInfoCache = Cache<MyAccountViewModel.CacheKey, UserInfo>()
                _userInfoCache = userInfoCache
                return userInfoCache
            }
        }
        set {
            _userInfoCache = newValue
        }
    }
    
    private var subscriptions: Set<AnyCancellable> = []

    init(
        appPreferencesClient: AppPreferencesClient,
        isAutorizedClient: @escaping () -> Bool,
        hasAccessGrantedClient: @escaping () -> Bool,
        authClient: AuthClient,
        eventShortClient: EventShortClient,
        eventShortTypesClient: EventShortTypesClient
    ) {
        self.appPreferencesClient = appPreferencesClient
        self.isAutorizedClient = isAutorizedClient
        self.hasAccessGrantedClient = hasAccessGrantedClient
        self.authClient = authClient
        self.eventShortClient = eventShortClient
        self.eventShortTypesClient = eventShortTypesClient
        
        NotificationCenter
            .default
            .publisher(for: logoutNotification)
            .sink { [weak self] _ in
                self?.userInfoCache = nil
            }
            .store(in: &subscriptions)
    }
    
}
// MARK: ClientFactory

extension DependencyContainer: ClientFactory {
    
    func makeIsAutorizedClient() -> () -> Bool {
        isAutorizedClient
    }
    
    
    func makeAppPreferencesClient() -> AppPreferencesClient {
        appPreferencesClient
    }
    
    func makeAuthClient() -> AuthClient {
        authClient
    }
    
    func makeHasAccessGrantedClient() -> () -> Bool {
        hasAccessGrantedClient
    }
    
}

// MARK: ViewModelFactory

extension DependencyContainer: ViewModelFactory {
    
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
    
    func makeWelcomeViewModel() -> WelcomeViewModel {
        .init(with: [
            .init(
                backgroundImageURL: .welcomeNewsImageURL,
                title: .localized("onboarding_news_title"),
                description: .localized("onboarding_news_text")
            ),
            .init(
                backgroundImageURL: .welcomeEventsImageURL,
                title: .localized("onboarding_events_title"),
                description: .localized("onboarding_events_text")
            ),
            .init(
                backgroundImageURL: .welcomeMeetImageURL,
                title: .localized("onboarding_meetup_title"),
                description: .localized("onboarding_meetup_text")
            )
        ])
    }
    
    func makeMyAccountViewModel() -> MyAccountViewModel {
        .init(authClient: makeAuthClient(), cache: userInfoCache)
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
    
    func makeWelcomeViewController(
        viewModel: WelcomeViewModel
    ) -> AuthWelcomeViewController {
        .init(viewModel: viewModel)
    }

    func makeMyAccountViewController(
        viewModel: MyAccountViewModel
    ) -> MyAccountViewController {
        .init(viewModel: viewModel)
    }
    
    func makeAccessNotGrantedViewController(
        viewModel: MyAccountViewModel
    ) -> AccessNotGrantedViewController {
        .init(viewModel: viewModel)
    }
    
}
