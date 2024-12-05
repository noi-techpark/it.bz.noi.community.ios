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
import Combine
import ArticlesClient

// MARK: - NewsDetailsViewModel

final class NewsDetailsViewModel {
    
    let articlesClient: ArticlesClient
    let language: Language?
    
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error!
    @Published private(set) var result: Article!
    
    private var showExternalLinkSubject: PassthroughSubject<(Article, Any?), Never> = .init()
    lazy var showExternalLinkPublisher = showExternalLinkSubject
        .eraseToAnyPublisher()
    
    private var showAskAQuestionSubject: PassthroughSubject<(Article, Any?), Never> = .init()
    lazy var showAskAQuestionPublisher = showAskAQuestionSubject
        .eraseToAnyPublisher()
    
    init(
        articlesClient: ArticlesClient,
        availableNews: Article?,
        language: Language?
    ) {
        self.articlesClient = articlesClient
        self.result = availableNews
        self.language = language
    }
    
    func refreshNewsDetails(newsId: String) {
		Task(priority: .userInitiated) { [weak self] in
			await self?.performRefreshNewsDetails(newsId: newsId)
		}
    }
    
    func showExternalLink(sender: Any?) {
        showExternalLinkSubject.send((result, sender))
    }

    func showAskAQuestion(sender: Any?) {
        showAskAQuestionSubject.send((result, sender))
    }
    
}

// MARK: Private APIs

private extension NewsDetailsViewModel {

	func performRefreshNewsDetails(newsId: String) async {
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
