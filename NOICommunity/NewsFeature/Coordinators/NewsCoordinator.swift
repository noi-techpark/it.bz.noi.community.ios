// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
        newsListViewModel.showDetailsHandler = { [weak self] news, _ in
            self?.goToDetails(of: news)
        }
        mainVC = dependencyContainer.makeNewsViewController(
            viewModel: newsListViewModel
        )
        mainVC.tabBarItem.title = .localized("news_top_tab")
    }
}

// MARK: Private APIs

private extension NewsCoordinator {
    
    func goToDetails(of news: Article) {
        let viewModel = dependencyContainer.makeNewsDetailsViewModel(
			news: news
        )
		let pageVC = {
			let pageVC = dependencyContainer.makeNewsPageViewController(
				viewModel: viewModel
			)

			pageVC.externalLinkActionHandler = { [weak self] in
				self?.showExternalLink(of: $0)
			}
			pageVC.askQuestionActionHandler = { [weak self] in
				self?.showAskAQuestion(for: $0)
			}
            
			pageVC.navigationItem.largeTitleDisplayMode = .never

			return pageVC
		}()
        navigationController.pushViewController(pageVC, animated: true)
    }
    
    func showExternalLink(of news: Article) {
        let author = localizedValue(from: news.languageToAuthor)
        let safariVC = SFSafariViewController(url: author!.externalURL!)
        navigationController.present(safariVC, animated: true)
    }
    
    func showAskAQuestion(for news: Article) {
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
