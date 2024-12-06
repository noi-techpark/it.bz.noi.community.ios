// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsPageViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 05/12/24.
//

import UIKit
import CoreUI
import ArticlesClient

// MARK: - NewsPageViewController

final class NewsPageViewController: BasePageViewController<NewsDetailsViewModel> {

	private lazy var containerViewController = ContainerViewController()

	private var newsDetailsViewController: NewsDetailsViewController? {
		children
			.lazy
			.compactMap { $0 as? NewsDetailsViewController }
			.first
	}

	var externalLinkActionHandler: ((Article) -> Void)? {
		didSet {
			newsDetailsViewController?.externalLinkActionHandler = { [weak self] in
				self?.externalLinkActionHandler?($0)
			}
		}
	}

	var askQuestionActionHandler: ((Article) -> Void)? {
		didSet {
			newsDetailsViewController?.askQuestionActionHandler = { [weak self] in
				self?.askQuestionActionHandler?($0)
			}
		}
	}

	override func configureBindings() {
		super.configureBindings()

		viewModel.$isLoading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isLoading in
				if isLoading {
					self?.show(content: LoadingViewController())
				}
			}
			.store(in: &subscriptions)

		viewModel.$result
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] event in
				guard let self
				else { return }
        
                self.navigationItem.title = localizedValue(
                    from: event.languageToDetails
                )?
                    .title

				self.show(content: self.makeResultContent(for: event))
			}
			.store(in: &subscriptions)

		viewModel.$error
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] error in
				self?.showError(error)
			}
			.store(in: &subscriptions)
	}

	override func configureLayout() {
		super.configureLayout()

		navigationItem.largeTitleDisplayMode = .never
		embedChild(containerViewController)
	}
	

}

// MARK: Private APIs

private extension NewsPageViewController {

	func show(content: UIViewController) {
		containerViewController.content = content
	}

	func makeResultContent(for news: Article) -> NewsDetailsViewController {
		let result = NewsDetailsViewController(for: news)
		result.externalLinkActionHandler = { [weak self] in
			self?.externalLinkActionHandler?($0)
		}
		result.askQuestionActionHandler = { [weak self] in
			self?.askQuestionActionHandler?($0)
		}
		return result
	}

}
