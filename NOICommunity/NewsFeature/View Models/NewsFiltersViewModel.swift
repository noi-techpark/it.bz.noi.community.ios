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
import ArticleTagsClient
import AppPreferencesClient
import ArticlesClient

// MARK: - NewsFiltersViewModel

class NewsFiltersViewModel {

	@Published private(set) var isLoading = false
	@Published private(set) var error: Error!
	@Published private(set) var filtersResults: [ArticleTag] = []
	@Published private(set) var activeFilters: Set<ArticleTag.Id> = [] {
		didSet {
			fetchResultNumber()
			saveActiveFiltersToPreferences()
		}
	}
	@Published private(set) var numberOfResults = 0

	private let articleTagsClient: ArticleTagsClient
	private let appPreferencesClient: AppPreferencesClient
	private let articlesClient: ArticlesClient
	private let showFilteredResultsHandler: () -> Void

	private var fetchResultNumberTask: Task<(), Never>?

	init(
		articleTagsClient: ArticleTagsClient,
		appPreferencesClient: AppPreferencesClient,
		articlesClient: ArticlesClient,
		showFilteredResultsHandler: @escaping () -> Void
	) {
		self.articleTagsClient = articleTagsClient
		self.appPreferencesClient = appPreferencesClient
		self.articlesClient = articlesClient
		self.showFilteredResultsHandler = showFilteredResultsHandler

		loadActiveFiltersFromPreferences()
	}

	func fetchPossibleFilters() {
		Task {
			await self.performFetchPossibleFilters()
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

// MARK: Private APIs

private extension NewsFiltersViewModel {

	func loadActiveFiltersFromPreferences() {
		activeFilters = Set(
			appPreferencesClient.fetch().activeNewsFilterIds
		)
	}

	func saveActiveFiltersToPreferences() {
		var preferences = appPreferencesClient.fetch()
		preferences.activeNewsFilterIds = Array(activeFilters)
		appPreferencesClient.update(preferences)
	}

	func performFetchPossibleFilters() async {
		guard !isLoading
		else { return }

		filtersResults = []
		isLoading = true
		defer {
			self.isLoading = false
		}

		do {
			filtersResults = try await articleTagsClient.getArticleTagList().items
		} catch {
			self.error = error
		}
	}

	func performFetchResultNumber() async {
		do {
			numberOfResults = try await articlesClient.getTotalArticleResults(
				startDate: Date(),
				publishedOn: "noi-communityapp",
				articleType: "newsfeednoi",
				rawFilter: activeFilters.toRawFilterQuery()
			)
		} catch {
			print("Error loading results with new filters selection")
		}
	}

	func fetchResultNumber() {
		fetchResultNumberTask = Task(priority: .userInitiated) {
			await self.performFetchResultNumber()
		}
	}

}

