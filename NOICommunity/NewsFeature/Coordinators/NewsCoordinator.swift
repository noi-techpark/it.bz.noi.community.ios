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
    private var newsFiltersViewModel: NewsFiltersViewModel!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func start(animated: Bool) {
        let newsFiltersViewModel = dependencyContainer.makeNewsFiltersViewModel { [weak self] in
            self?.closeFilters()
        }
        
        self.newsFiltersViewModel = newsFiltersViewModel
        
        let newsListViewModel = dependencyContainer.makeNewsListViewModel {[weak self] in
            self?.goToFilters()
        }
        
        self.newsListViewModel = newsListViewModel
        
        newsListViewModel.activeFilters = newsFiltersViewModel.activeFilters
        
        newsListViewModel.showDetailsHandler = { [weak self] news, _ in
            self?.goToDetails(of: news)
        }
        mainVC = dependencyContainer.makeNewsViewController(
            viewModel: newsListViewModel
        )
        mainVC.tabBarItem.title = .localized("news_top_tab")
        
        newsFiltersViewModel.$activeFilters
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activeFilters in
                self?.newsListViewModel.activeFilters = activeFilters
            }
            .store(in: &subscriptions)
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
			return pageVC
		}()
        navigationController.pushViewController(pageVC, animated: true)
    }
    
    func goToFilters() {
        let filtersVC = dependencyContainer.makeNewsFiltersViewController(
            viewModel: newsFiltersViewModel
        )
        filtersVC.modalPresentationStyle = .fullScreen
        filtersVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(closeFilters)
        )
        navigationController.present(
            NavigationController(rootViewController: filtersVC),
            animated: true,
            completion: nil
        )
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
    
    @objc func closeFilters() {
        navigationController.dismiss(animated: true, completion: nil)
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
