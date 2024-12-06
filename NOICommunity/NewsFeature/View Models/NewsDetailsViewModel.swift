// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsDetailsViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import CoreUI
import Combine
import ArticlesClient

// MARK: - NewsDetailsViewModel

final class NewsDetailsViewModel: BasePageViewModel {

    let articlesClient: ArticlesClient
	let newsId: String

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var result: Article!
    
    init(
        articlesClient: ArticlesClient,
        news: Article
    ) {
        self.articlesClient = articlesClient
		self.newsId = news.id
		self.result = news

		super.init()
    }

	init(
		articlesClient: ArticlesClient,
		newsId: String
	) {
		self.articlesClient = articlesClient
		self.newsId = newsId

		super.init()
	}

	@available(*, unavailable)
	required init() {
		fatalError("\(#function) not available")
	}

    func fetchNews(with newsId: String) {
		Task(priority: .userInitiated) { [weak self] in
			await self?.performFetchNews(with: newsId)
		}
    }

	override func onViewDidLoad() {
		super.onViewDidLoad()

		if result == nil {
			fetchNews(with: newsId)
		}
	}

}

// MARK: Private APIs

private extension NewsDetailsViewModel {

	func performFetchNews(with newsId: String) async {
		isLoading = true
		defer {
			isLoading = false
		}

		do {
			result = try await articlesClient.getArticle(newsId: newsId)
		} catch {
			self.error = error
		}
	}

}
