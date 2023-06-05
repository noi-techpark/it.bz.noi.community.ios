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
    
    private var fetchRequestCancellable: AnyCancellable?
    
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
        isLoading = true
        
        fetchRequestCancellable = articlesClient.detail(newsId)
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
                self?.result = $0
            })
    }
    
    func showExternalLink(sender: Any?) {
        showExternalLinkSubject.send((result, sender))
    }

    func showAskAQuestion(sender: Any?) {
        showAskAQuestionSubject.send((result, sender))
    }
    
}
