//
//  NewsCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/05/22.
//

import Foundation
import Combine
import SafariServices
import MessageUI
import ArticlesClient

// MARK: - NewsCoordinator

final class NewsCoordinator: BaseNavigationCoordinator {
    
    override var rootViewController: UIViewController {
        mainVC
    }
    
    private var mainVC: NewsViewController!
    
    private var newsListViewModel: NewsListViewModel!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func start(animated: Bool) {
        newsListViewModel = dependencyContainer.makeNewsListViewModel()
        newsListViewModel.showDetailsHandler = { [weak self] in
            self?.goToDetails(of: $0, sender: $1)
        }
        mainVC = dependencyContainer.makeNewsViewController(
            viewModel: newsListViewModel
        )
        mainVC.tabBarItem.title = .localized("news_top_tab")
    }
}

// MARK: Private APIs

private extension NewsCoordinator {
    
    func goToDetails(of news: Article, sender: Any?) {
        let viewModel = dependencyContainer.makeNewsDetailsViewModel(
            availableNews: news
        )
        viewModel.showExternalLinkPublisher
            .sink { [weak self] (article, sender) in
                self?.showExternalLink(of: news, sender: sender)
            }
            .store(in: &subscriptions)
        viewModel.showaskAQuestionPublisher
            .sink { [weak self] (article, sender) in
                self?.showAskAQuestion(for: news, sender: sender)
            }
            .store(in: &subscriptions)
        
        let detailVC = dependencyContainer.makeNewsDetailsViewController(
            newsId: news.id,
            viewModel: viewModel
        )
        detailVC.navigationItem.title = localizedValue(
            from: news.languageToDetails
        )?
            .title
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func showExternalLink(of news: Article, sender: Any?) {
        let author = localizedValue(from: news.languageToAuthor)
        let safariVC = SFSafariViewController(url: author!.externalURL!)
        navigationController.present(safariVC, animated: true)
    }
    
    func showAskAQuestion(for news: Article, sender: Any?) {
        let author = localizedValue(from: news.languageToAuthor)
        navigationController.mailTo(
            author!.email!,
            delegate: self,
            completion: nil
        )
    }
    
}

// MARK: MFMailComposeViewControllerDelegate

extension NewsCoordinator: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith _: MFMailComposeResult,
        error _: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
