// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventFiltersViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/03/22.
//

import Foundation
import Combine
import EventTagsClient

// MARK: - EventFiltersViewModel

class EventFiltersViewModel {

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var filtersResults: [Tag] = []
    @Published private(set) var activeFilters: Set<Tag> = []
    @Published var numberOfResults = 0

    private var activeCustomTaggingFilter: Tag?
    private var activeTechnologyFieldsFiltersIds: Set<Tag> = []

    let eventTagsClient: EventTagsClient

    private var subscriptions: Set<AnyCancellable> = []

    private let showFilteredResultsHandler: () -> Void

    init(
        eventTagsClient: EventTagsClient,
        showFilteredResultsHandler: @escaping () -> Void
    ) {
        self.eventTagsClient = eventTagsClient
        self.showFilteredResultsHandler = showFilteredResultsHandler
    }

    func refreshEventsFilters() {
        Task(priority: .userInitiated) { [weak self] in
            await self?.performRefreshEventsFilters()
        }
    }

    func setFilter(_ filter: Tag, isActive: Bool) {
        switch (filter.isCustomTagging, isActive) {
        case (true, false):
            activeCustomTaggingFilter = nil
        case (true, true):
            activeCustomTaggingFilter = filter
        default:
            break
        }

        switch (filter.isTechnologyFields, isActive) {
        case (true, false):
            activeTechnologyFieldsFiltersIds.remove(filter)
        case (true, true):
            activeTechnologyFieldsFiltersIds.insert(filter)
        default:
            break
        }

        var newActiveFiltersIds: Set<Tag> = []
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

// MARK: Private APIs

private extension EventFiltersViewModel {

    func performRefreshEventsFilters() async {
        guard !isLoading
        else { return }

        isLoading = true
        filtersResults = []
        defer {
            isLoading = false
        }

        do {
            filtersResults = try await eventTagsClient.getEventTagList().items
        } catch {
            self.error = error
        }
    }

}
