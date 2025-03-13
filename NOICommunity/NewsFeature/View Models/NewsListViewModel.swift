// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsListViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 11/05/21.
//

import Foundation
import Combine
import ArticlesClient
import ArticleTagsClient

// MARK: - NewsViewModel

final class NewsListViewModel {
    
    let articlesClient: ArticlesClient
    
    let pageSize: Int
    let firstPage: Int

    private var needsToRequestHighlight: Bool
    
    var hasNextPage: Bool {
        nextPage != nil
    }
    
    @Published private(set) var nextPage: Int?
    @Published private(set) var isLoadingFirstPage = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var newsIds: [String] = []
    @Published var newsResults: Int = 0
    @Published var activeFilters: Set<ArticleTag.Id> = []
    private var idToNews: [String: Article] = [:]
    
    private var refreshCancellable: AnyCancellable?
    private var fetchRequestCancellable: AnyCancellable?
    
    var showDetailsHandler: ((Article, Any?) -> Void)!
    let showFiltersHandler: () -> Void
    
    init(
        articlesClient: ArticlesClient,
        showFiltersHandler: @escaping () -> Void,
        pageSize: Int = 10,
        firstPage: Int = 1,
        needsToRequestHighlight: Bool = true
    ) {
        self.articlesClient = articlesClient
        self.showFiltersHandler = showFiltersHandler
        self.pageSize = pageSize
        self.firstPage = firstPage
        self.nextPage = firstPage
        self.needsToRequestHighlight = needsToRequestHighlight

        configureBindings()
    }

    func fetchNews(refresh: Bool = false) {
		Task(priority: .userInitiated) { [weak self] in
			await self?.performFetchNews(refresh: refresh)
		}
    }
    
    func news(withId newsId: String) -> Article {
        guard let result = idToNews[newsId]
        else { fatalError("Unknown newsId: \(newsId)") }
        
        return result
    }
    
    func showNewsDetails(of newsId: String, sender: Any?) {
        showDetailsHandler(news(withId: newsId), sender)
    }
    
}

// MARK: Private APIs

private extension NewsListViewModel {

    func performFetchResultNumber() async {
        do {
            let resultsNumber = try await articlesClient.getTotalArticleResults(
                startDate: Date(),
                publishedOn: "noi-communityapp",
                articleType: "newsfeednoi",
                rawFilter: {
                    if let filtersQuery = activeFilters.toQuery(), !filtersQuery.isEmpty {
                        return filtersQuery
                    }
                    return nil
                }()
            )
            
            self.newsResults = resultsNumber
        }
        catch {
            self.error = error
        }
    }
    
	func performFetchNews(refresh: Bool = false) async {
		guard nextPage != nil || refresh
		else { return }

		let pageNumber = refresh ? firstPage : nextPage!
		needsToRequestHighlight = needsToRequestHighlight || refresh

		isLoadingFirstPage = pageNumber == firstPage
		isLoading = true
		defer {
			isLoadingFirstPage = false
			isLoading = false
		}

		do {
			let pagination = try await articlesClient.getArticleList(
				startDate: Date(),
				publishedOn: "noi-communityapp",
				articleType: "newsfeednoi",
				rawSort: "-ArticleDate",
                rawFilter: {
                    // Highlight Filter
                    var filterString = needsToRequestHighlight ? #"eq(Highlight,"true")"# : #"or(eq(Highlight,"false"),isnull(Highlight))"#
                    
                    // Active Tag Filters
                    if let filtersQuery = activeFilters.toQuery(), !filtersQuery.isEmpty {
                        filterString = #"and(\#(filterString),\#(filtersQuery))"#
                    }
                    
                    return filterString
                }(),
				pageSize: pageSize,
				pageNumber: pageNumber
			)

			let hadRequestHighlight = needsToRequestHighlight

			let newItems = pagination.items
			newItems.forEach { idToNews[$0.id] = $0 }
			if refresh {
				newsIds = newItems.map(\.id)
			} else {
				newsIds = newsIds + newItems.map(\.id)
			}
            
            if needsToRequestHighlight, !pagination.hasNextPage {
                nextPage = firstPage
                needsToRequestHighlight = false
            } else {
                nextPage = pagination.nextPage
            }

			if hadRequestHighlight, newItems.isEmpty {
				fetchNews()
            }
            if nextPage == nil && !refresh{
                await performFetchResultNumber()
            }
		} catch {
			self.error = error
		}

	}

    func configureBindings() {
        refreshCancellable = NotificationCenter
            .default
            .publisher(for: refreshNewsListNotification)
            .sink { [weak self] _ in
                self?.fetchNews(refresh: true)
            }
    }
    
}

// MARK: Query Helper

private extension Collection where Element == ArticleTag.Id {
    
    func toQuery() -> String? {
        let filterToQuery: (ArticleTag.Id) -> String = {
            #"in(TagIds.[],"\#($0)")"#
        }

        let queryComponentsToQuery: ([String], String) -> String = { components, logicOperator in
            let components = components.filter { !$0.isEmpty }
            if components.isEmpty {
                return ""
            } else if components.count == 1 {
                return components.first!
            } else {
                return logicOperator + "(" + components.joined(separator: ",") + ")"
            }
        }

        let queryComponents = self.map(filterToQuery)
        return queryComponentsToQuery(queryComponents, "or")
    }
}
