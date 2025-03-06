// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsFiltersViewModel.swift
//  NOICommunity
//
//  Created by Camilla on 04/03/25.
//

import Foundation
import Combine
import ArticleTagsClient

// MARK: - NewsFiltersViewModel

class NewsFiltersViewModel {

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var filtersResults: [ArticleTag] = []
    @Published private(set) var activeFilters: Set<ArticleTag> = []
    @Published var numberOfResults = 0
    
    private var refreshTagsRequestCancellable: AnyCancellable?
    
    let articleTagsClient: ArticleTagsClient
    private var subscriptions: Set<AnyCancellable> = []
    private let showFilteredResultsHandler: () -> Void

    init(
        articleTagsClient: ArticleTagsClient,
        showFilteredResultsHandler: @escaping () -> Void
    ) {
        self.articleTagsClient = articleTagsClient
        self.showFilteredResultsHandler = showFilteredResultsHandler
    }

    func refreshNewsFilters() {
        guard !isLoading else { return }
        isLoading = true
        filtersResults = []

        refreshTagsRequestCancellable = articleTagsClient.getArticleTagListPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                    self?.isLoading = false
                },
                receiveValue: { [weak self] tags in
                    self?.filtersResults = tags
                }
            )
    }

    
    func setFilter(_ filter: ArticleTag, isActive: Bool) {
        if isActive {
            activeFilters.insert(filter)
        } else {
            activeFilters.remove(filter)
        }
    }
    
    func clearActiveFilters() {
        activeFilters.removeAll()
    }
    
    func showFilteredResults() {
        showFilteredResultsHandler()
    }
    
}

