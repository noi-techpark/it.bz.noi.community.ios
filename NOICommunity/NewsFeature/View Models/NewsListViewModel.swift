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

// MARK: - NewsViewModel

final class NewsListViewModel {
    
    let articlesClient: ArticlesClient
    
    let pageSize: Int
    let firstPage: Int

    private var needsToRequestHighlight: Bool

    private var nextPage: Int?
    
    var hasNextPage: Bool {
        nextPage != nil
    }
    
    @Published private(set) var isLoadingFirstPage = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var newsIds: [String] = []
    private var idToNews: [String: Article] = [:]
    
    private var refreshCancellable: AnyCancellable?
    private var fetchRequestCancellable: AnyCancellable?
    
    var showDetailsHandler: ((Article, Any?) -> Void)!
    
    init(
        articlesClient: ArticlesClient,
        pageSize: Int = 10,
        firstPage: Int = 1,
        needsToRequestHighlight: Bool = true
    ) {
        self.articlesClient = articlesClient
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
				rawFilter: needsToRequestHighlight ? #"eq(Highlight,"true")"# : #"or(eq(Highlight,"false"),isnull(Highlight))"#,
				pageSize: pageSize,
				pageNumber: pageNumber
			)

			let hadRequestHighlight = needsToRequestHighlight

			if needsToRequestHighlight, !pagination.hasNextPage {
				nextPage = firstPage
				needsToRequestHighlight = false
			} else {
				nextPage = pagination.nextPage
			}

			let newItems = pagination.items
			newItems.forEach { idToNews[$0.id] = $0 }
			if refresh {
				newsIds = newItems.map(\.id)
			} else {
				newsIds = newsIds + newItems.map(\.id)
			}

			if hadRequestHighlight, newItems.isEmpty {
				fetchNews()
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
