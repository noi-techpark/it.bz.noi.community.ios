// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ViewModelFactory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import ArticlesClient

protocol ViewModelFactory {

    func makeEventsViewModel(
        showFiltersHandler: @escaping () -> Void
    ) -> EventsViewModel

	func makeEventDetailsViewModel(
		eventId: String
	) -> EventDetailsViewModel

	func makeEventDetailsViewModel(
		event: Event
	) -> EventDetailsViewModel

    func makeEventFiltersViewModel(
        showFilteredResultsHandler: @escaping () -> Void
    ) -> EventFiltersViewModel
    
    func makeWelcomeViewModel() -> WelcomeViewModel
    
    func makeMyAccountViewModel() -> MyAccountViewModel
    
    func makeNewsListViewModel(
        showFiltersHandler: @escaping () -> Void
    ) -> NewsListViewModel
    
    func makeNewsFiltersViewModel(
        showFilteredResultsHandler: @escaping () -> Void
    ) -> NewsFiltersViewModel
    
	func makeNewsDetailsViewModel(
		newsId: String
	) -> NewsDetailsViewModel

	func makeNewsDetailsViewModel(
		news: Article
	) -> NewsDetailsViewModel

    func makeLoadUserInfoViewModel() -> LoadUserInfoViewModel
    
    func makePeopleViewModel() -> PeopleViewModel

    func makeComeOnBoardOnboardingViewModel() -> ComeOnBoardOnboardingViewModel

    func makeDeveloperToolsViewModel() -> DeveloperToolsViewModel

}
