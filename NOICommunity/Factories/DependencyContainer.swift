// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
import Core
import ArticlesClient
import PeopleClient

// MARK: - DependencyContainer

final class DependencyContainer {
    
    let appPreferencesClient: AppPreferencesClient
    let isAutorizedClient: () -> Bool
    let hasAccessGrantedClient: () -> Bool
    let authClient: AuthClient
    let eventShortClient: EventShortClient
    let eventShortTypesClient: EventShortTypesClient
    let artileClient: ArticlesClient
    let peopleClient: PeopleClient
    
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
        eventShortTypesClient: EventShortTypesClient,
        articleClient: ArticlesClient,
        peopleClient: PeopleClient
    ) {
        self.appPreferencesClient = appPreferencesClient
        self.isAutorizedClient = isAutorizedClient
        self.hasAccessGrantedClient = hasAccessGrantedClient
        self.authClient = authClient
        self.eventShortClient = eventShortClient
        self.eventShortTypesClient = eventShortTypesClient
        self.artileClient = articleClient
        self.peopleClient = peopleClient
        
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
    
    func makeArticlesClient() -> ArticlesClient {
        artileClient
    }
    
    func makePeopleClient() -> PeopleClient {
        peopleClient
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
                backgroundImageName: "welcome_news",
                title: .localized("onboarding_news_title"),
                description: .localized("onboarding_news_text")
            ),
            .init(
                backgroundImageName: "noisteria_außen",
                title: .localized("onboarding_events_title"),
                description: .localized("onboarding_events_text")
            ),
            .init(
                backgroundImageName: "welcome_meet",
                title: .localized("onboarding_meetup_title"),
                description: .localized("onboarding_meetup_text")
            )
        ])
    }
    
    func makeMyAccountViewModel() -> MyAccountViewModel {
        .init(authClient: makeAuthClient(), cache: userInfoCache)
    }
    
    func makeNewsListViewModel() -> NewsListViewModel {
        .init(articlesClient: makeArticlesClient())
    }
    
    func makeNewsDetailsViewModel(availableNews: Article?) -> NewsDetailsViewModel {
        .init(
            articlesClient: makeArticlesClient(),
            availableNews: availableNews,
            language: nil
        )
    }
    
    func makePeopleViewModel() -> PeopleViewModel {
        .init(authClient: makeAuthClient(), peopleClient: makePeopleClient())
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
    
    func makeNewsViewController(
        viewModel: NewsListViewModel
    ) -> NewsViewController {
        .init(viewModel: viewModel)
    }
    
    func makeNewsDetailsViewController(
        newsId: String,
        viewModel: NewsDetailsViewModel
    ) -> NewsDetailsViewController {
        .init(newsId: newsId, viewModel: viewModel)
    }
    
    func makeMeetMainViewController(
        viewModel: PeopleViewModel
    ) -> MeetMainViewController {
        .init(viewModel: viewModel)
    }
    
    func makePersonDetailsViewController(
        person: Person,
        company: Company?
    ) -> PersonDetailsViewController {
        .init(person: person, company: company)
    }
    
    func makeCompaniesFiltersViewController(
        viewModel: PeopleViewModel
    ) -> CompaniesFiltersViewController {
        .init(peopleViewModel: viewModel)
    }
    
}
