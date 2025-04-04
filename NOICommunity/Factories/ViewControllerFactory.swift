// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ViewControllerFactory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import PeopleClient

protocol ViewControllerFactory {
    
    func makeEventListViewController() -> EventListViewController

	func makeEventPageViewController(
		viewModel: EventDetailsViewModel
	) -> EventPageViewController

    func makeEventFiltersViewController(
        viewModel: EventFiltersViewModel
    ) -> EventFiltersViewController
    
    func makeNewsFiltersViewController(
        viewModel: NewsFiltersViewModel
    ) -> NewsFiltersViewController

    func makeWelcomeViewController(
        viewModel: WelcomeViewModel
    ) -> AuthWelcomeViewController
    
    func makeMyAccountViewController(
        viewModel: MyAccountViewModel
    ) -> MyAccountViewController
    
    func makeAccessNotGrantedViewController(
        viewModel: MyAccountViewModel
    ) -> AccessNotGrantedViewController
    
    func makeNewsViewController(
        viewModel: NewsListViewModel
    ) -> NewsViewController
    
    func makeNewsPageViewController(
        viewModel: NewsDetailsViewModel
    ) -> NewsPageViewController
    
    func makeMeetMainViewController(
        viewModel: PeopleViewModel
    ) -> MeetMainViewController
    
    func makePersonDetailsViewController(
        person: Person,
        company: Company?
    ) -> PersonDetailsViewController
    
    func makeCompaniesFiltersViewController(
        viewModel: PeopleViewModel
    ) -> CompaniesFiltersViewController

    func makeComeOnBoardOnboardingViewController(
        viewModel: ComeOnBoardOnboardingViewModel
    ) -> ComeOnBoardOnboardingViewController

    func makeDeveloperToolsViewController(
        viewModel: DeveloperToolsViewModel
    ) -> DeveloperToolsViewController
}
