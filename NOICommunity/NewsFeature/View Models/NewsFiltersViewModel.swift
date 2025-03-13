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
import AppPreferencesClient

// MARK: - NewsFiltersViewModel

class NewsFiltersViewModel {

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var filtersResults: [ArticleTag] = []
    @Published private(set) var activeFilters: Set<ArticleTag.Id> = [] {
        didSet {
            saveActiveFiltersToPreferences()
        }
    }
    @Published var numberOfResults = 0
    
    private var refreshTagsRequestCancellable: AnyCancellable?
    private var subscriptions: Set<AnyCancellable> = []
    
    let articleTagsClient: ArticleTagsClient
    let appPreferencesClient: AppPreferencesClient
    private let showFilteredResultsHandler: () -> Void

    init(
        articleTagsClient: ArticleTagsClient,
        appPreferencesClient: AppPreferencesClient,
        showFilteredResultsHandler: @escaping () -> Void
    ) {
        self.articleTagsClient = articleTagsClient
        self.appPreferencesClient = appPreferencesClient
        self.showFilteredResultsHandler = showFilteredResultsHandler
        
        loadActiveFiltersFromPreferences()
    }
    
    func loadActiveFiltersFromPreferences() {
        let savedFilterIds = Set(appPreferencesClient.fetch().activeNewsFilterIds)
        activeFilters = savedFilterIds
    }
    
    private func saveActiveFiltersToPreferences() {
        var preferences = appPreferencesClient.fetch()
        preferences.activeNewsFilterIds = Array(activeFilters)
        appPreferencesClient.update(preferences)
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
            activeFilters.insert(filter.id)
        } else {
            activeFilters.remove(filter.id)
        }
    }

    
    func clearActiveFilters() {
        activeFilters.removeAll()
    }
    
    func showFilteredResults() {
        showFilteredResultsHandler()
    }
    
}

