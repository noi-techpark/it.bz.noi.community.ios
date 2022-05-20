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

    func makeEventFiltersViewModel(
        showFilteredResultsHandler: @escaping () -> Void
    ) -> EventFiltersViewModel
    
    func makeWelcomeViewModel() -> WelcomeViewModel
    
    func makeMyAccountViewModel() -> MyAccountViewModel
    
    func makeNewsListViewModel() -> NewsListViewModel
    
    func makeNewsDetailsViewModel(
        availableNews: Article?
    ) -> NewsDetailsViewModel
    
    func makePeopleViewModel() -> PeopleViewModel
    
}
