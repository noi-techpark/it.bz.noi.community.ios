//
//  ViewModelFactory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

protocol ViewModelFactory {

    func makeLoadAppPreferencesViewModel() -> LoadAppPreferencesViewModel

    func makeUpdateAppPreferencesViewModel() -> UpdateAppPreferencesViewModel

    func makeEventsViewModel(
        showFiltersHandler: @escaping () -> Void
    ) -> EventsViewModel

    func makeEventFiltersViewModel(
        showFilteredResultsHandler: @escaping () -> Void
    ) -> EventFiltersViewModel
    
}
