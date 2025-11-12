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
import ArticleTagsClient
import PeopleClient
import VimeoVideoThumbnailClient

// MARK: - DependencyContainer

final class DependencyContainer {
    
    let appPreferencesClient: AppPreferencesClient
    let isAutorizedClient: IsAutorizedClient
	let oidcAuthValidator: OIDCAuthValidator
    let authClient: AuthClient
    let eventShortClient: EventShortClient
    let eventShortTypesClient: EventShortTypesClient
    let artileClient: ArticlesClient
    let articleTagsClient: ArticleTagsClient
    let peopleClient: PeopleClient
	let vimeoVideoThumbnailClient: VimeoVideoThumbnailClient

    private var _userInfoCache: Cache<CacheKey, UserInfo>?
    private var userInfoCache: Cache<CacheKey, UserInfo>! {
        get {
            if let userInfoCache = _userInfoCache {
                return userInfoCache
            } else {
                let userInfoCache = Cache<CacheKey, UserInfo>()
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
        isAutorizedClient: @escaping IsAutorizedClient,
		oidcAuthValidator: OIDCAuthValidator,
        authClient: AuthClient,
        eventShortClient: EventShortClient,
        eventShortTypesClient: EventShortTypesClient,
        articleClient: ArticlesClient,
        articleTagsClient: ArticleTagsClient,
        peopleClient: PeopleClient,
		vimeoVideoThumbnailClient: VimeoVideoThumbnailClient
    ) {
        self.appPreferencesClient = appPreferencesClient
        self.isAutorizedClient = isAutorizedClient
		self.oidcAuthValidator = oidcAuthValidator
        self.authClient = authClient
        self.eventShortClient = eventShortClient
        self.eventShortTypesClient = eventShortTypesClient
        self.artileClient = articleClient
        self.articleTagsClient = articleTagsClient
		self.peopleClient = peopleClient
		self.vimeoVideoThumbnailClient = vimeoVideoThumbnailClient

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
    
    func makeIsAutorizedClient() -> IsAutorizedClient {
        isAutorizedClient
    }
    
    
    func makeAppPreferencesClient() -> AppPreferencesClient {
        appPreferencesClient
    }

	func makeOIDCAuthValidator() -> any OIDCAuthValidator {
		oidcAuthValidator
	}

    func makeAuthClient() -> AuthClient {
        authClient
    }
    
    func makeArticlesClient() -> ArticlesClient {
        artileClient
    }
    
    func makePeopleClient() -> PeopleClient {
        peopleClient
    }

	func makeVimeoVideoThumbnailClient() -> any VimeoVideoThumbnailClient {
		vimeoVideoThumbnailClient
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


	func makeEventDetailsViewModel(eventId: String) -> EventDetailsViewModel {
		.init(eventShortClient: eventShortClient, eventId: eventId)
	}

	func makeEventDetailsViewModel(event: Event) -> EventDetailsViewModel {
		.init(eventShortClient: eventShortClient, event: event)
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

    func makeLoadUserInfoViewModel() -> LoadUserInfoViewModel {
        .init(
            authClient: makeAuthClient(),
            peopleClient: makePeopleClient(),
            appPreferencesClient: makeAppPreferencesClient(),
            cache: userInfoCache
        )
    }
    
    func makeMyAccountViewModel() -> MyAccountViewModel {
        .init(
            authClient: makeAuthClient(),
            appPreferencesClient: makeAppPreferencesClient(),
            cache: userInfoCache
        )
    }
    
    func makeNewsListViewModel(
        showFiltersHandler: @escaping () -> Void
    ) -> NewsListViewModel {
        .init(
            articlesClient: makeArticlesClient(),
            showFiltersHandler: showFiltersHandler
        )
    }

	func makeNewsDetailsViewModel(
		newsId: String
	) -> NewsDetailsViewModel {
		.init(articlesClient: makeArticlesClient(), newsId: newsId)
	}

	func makeNewsDetailsViewModel(
		news: Article
	) -> NewsDetailsViewModel {
		.init(articlesClient: makeArticlesClient(), news: news)
    }
    
    func makeNewsFiltersViewModel(
        showFilteredResultsHandler: @escaping () -> Void
    ) -> NewsFiltersViewModel {
        .init(
            articleTagsClient: articleTagsClient,
			appPreferencesClient: makeAppPreferencesClient(),
			articlesClient: makeArticlesClient(),
            showFilteredResultsHandler: showFilteredResultsHandler
        )
    }
    
    func makePeopleViewModel() -> PeopleViewModel {
        .init(authClient: makeAuthClient(), peopleClient: makePeopleClient())
    }

    func makeComeOnBoardOnboardingViewModel() -> ComeOnBoardOnboardingViewModel {
        .init(appPreferencesClient: makeAppPreferencesClient())
    }

    func makeDeveloperToolsViewModel() -> DeveloperToolsViewModel {
        .init()
    }

	func makeReauthenticatePopUpViewModel() -> ReauthenticatePopUpViewModel {
		.init()
	}

}

// MARK: ViewControllerFactory

extension DependencyContainer: ViewControllerFactory {
    
    func makeEventListViewController() -> EventListViewController {
        .init(items: [])
    }

	func makeEventPageViewController(
		viewModel: EventDetailsViewModel
	) -> EventPageViewController {
		.init(viewModel: viewModel, dependencyContainer: self)
	}

    func makeEventFiltersViewController(
        viewModel: EventFiltersViewModel
    ) -> EventFiltersViewController {
        .init(viewModel: viewModel)
    }
    
    func makeNewsFiltersViewController(viewModel: NewsFiltersViewModel) -> NewsFiltersViewController {
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
    
	func makeNewsPageViewController(
		viewModel: NewsDetailsViewModel
	) -> NewsPageViewController {
		.init(viewModel: viewModel, dependencyContainer: self)
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

    func makeComeOnBoardOnboardingViewController(
        viewModel: ComeOnBoardOnboardingViewModel
    ) -> ComeOnBoardOnboardingViewController {
        .init(viewModel: viewModel)
    }
    
    func makeDeveloperToolsViewController(
        viewModel: DeveloperToolsViewModel
    ) -> DeveloperToolsViewController {
        .init(viewModel: viewModel)
    }

	func makeReauthenticatePopUpViewController(
		viewModel: ReauthenticatePopUpViewModel
	) -> ReauthenticatePopUpViewController {
		.init(viewModel: viewModel)
	}

}
