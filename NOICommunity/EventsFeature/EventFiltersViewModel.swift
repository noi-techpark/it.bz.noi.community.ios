//
//  EventFiltersViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/03/22.
//

import Foundation
import Combine
import EventShortTypesClient

// MARK: - EventFiltersViewModel

class EventFiltersViewModel {

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var filtersResults: [EventsFilter] = []
    @Published private(set) var activeFilters: Set<EventsFilter> = []
    @Published var numberOfResults = 0

    private var activeCustomTaggingFilter: EventsFilter?
    private var activeTechnologyFieldsFiltersIds: Set<EventsFilter> = []

    private var refreshEventsRequestCancellable: AnyCancellable?

    let eventShortTypes: EventShortTypesClient

    private var subscriptions: Set<AnyCancellable> = []

    private var roomMapping: [String:String]!

    private let showFilteredResultsHandler: () -> Void

    init(
        eventShortTypes: EventShortTypesClient,
        showFilteredResultsHandler: @escaping () -> Void
    ) {
        self.eventShortTypes = eventShortTypes
        self.showFilteredResultsHandler = showFilteredResultsHandler
    }

    func refreshEventsFilters() {
        isLoading = true
        filtersResults = []

        refreshEventsRequestCancellable = eventShortTypes.filters()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] in
                    self?.filtersResults = $0
                })
    }

    func setFilter(_ filter: EventsFilter, isActive: Bool) {
        switch (filter.type, isActive) {
        case (.customTagging, false):
            activeCustomTaggingFilter = nil
        case (.customTagging, true):
            activeCustomTaggingFilter = filter
        case (.technologyFields, false):
            activeTechnologyFieldsFiltersIds.remove(filter)
        case (.technologyFields, true):
            activeTechnologyFieldsFiltersIds.insert(filter)
        default:
            break
        }

        var newActiveFiltersIds: Set<EventsFilter> = []
        if let activeCustomTaggingFilter = activeCustomTaggingFilter {
            newActiveFiltersIds.insert(activeCustomTaggingFilter)
        }
        newActiveFiltersIds.formUnion(activeTechnologyFieldsFiltersIds)
        activeFilters = newActiveFiltersIds
    }

    func clearActiveFilters() {
        activeCustomTaggingFilter = nil
        activeTechnologyFieldsFiltersIds.removeAll()
        activeFilters = []
    }

    func showFilteredResults() {
        showFilteredResultsHandler()
    }

}

extension EventsFilter {

    var isCustomTagging: Bool {
        type == .customTagging
    }

    var isTechnologyFields: Bool {
        type == .technologyFields
    }

}
