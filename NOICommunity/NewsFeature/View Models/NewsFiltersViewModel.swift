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

    
    func performRefreshNewsFilters() async {
        guard !isLoading else { return }
        isLoading = true
        filtersResults = []
        
        do {
            filtersResults = try await articleTagsClient.getArticleTagList().items
        }
        catch{
            self.error = error
        }
        self.isLoading = false
    }
    
    func refreshNewsFilters(){
        Task{
            await self.performRefreshNewsFilters()
        }
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

