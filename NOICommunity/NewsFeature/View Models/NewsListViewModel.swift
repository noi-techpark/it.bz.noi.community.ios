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
        firstPage: Int = 1
    ) {
        self.articlesClient = articlesClient
        self.pageSize = pageSize
        self.firstPage = firstPage
        self.nextPage = firstPage
        
        configureBindings()
    }
    
    func fetchNews(refresh: Bool = false) {
        guard nextPage != nil || refresh
        else { return }
        
        let pageNumber: Int
        
        if refresh {
            pageNumber = firstPage
        } else {
            pageNumber = nextPage!
        }
        
        if refresh {
            newsIds = []
        }
        
        isLoadingFirstPage = pageNumber == firstPage
        isLoading = true
        
        fetchRequestCancellable = articlesClient.list(
            Date(),
            pageSize,
            pageNumber
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoadingFirstPage = false
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            },
            receiveValue: { [weak self] pagination in
                guard let self = self
                else { return }
                
                self.nextPage = pagination.nextPage
                
                guard let newItems = pagination.items
                else { return }
                
                newItems.forEach { self.idToNews[$0.id] = $0 }
                
                var resultNewsIds = newItems.map(\.id)
                if !refresh {
                    resultNewsIds = Array(resultNewsIds.dropFirst())
                }
                self.newsIds += resultNewsIds
            })
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
    
    func configureBindings() {
        refreshCancellable = NotificationCenter
            .default
            .publisher(for: refreshNewsListNotification)
            .sink { [weak self] _ in
                self?.fetchNews(refresh: true)
            }
    }
    
}