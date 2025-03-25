// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 11/05/22.
//

import UIKit
import Combine
import ArticleTagsClient

// MARK: - NewsViewController

final class NewsViewController: UIViewController {

    let viewModel: NewsListViewModel

    private var subscriptions: Set<AnyCancellable> = []

    private var content: UIViewController? {
        get { children.last }
        set {
            guard newValue != content
            else { return }

            var isLoading = false
            if let content = content {
                if let refreshableContent = content as? UIRefreshableViewController,
                   let refreshControl = refreshableContent.refreshControl {
                    isLoading = refreshControl.isLoading
                    refreshControl.isLoading = false
                }
                
                content.willMove(toParent: nil)
                content.view.removeFromSuperview()
                content.removeFromParent()
            }

            if let newContent = newValue {
                embedChild(newContent, in: contentContainerView)

                if let refreshableNewContent = newContent as? UIRefreshableViewController {
                    addRefreshControl(
                        to: refreshableNewContent,
                        isLoading: isLoading
                    )
                }
            }
        }
    }

    @IBOutlet private var filterBarContainerView: UIView!

    @IBOutlet private var filterBarView: NewsFilterBarView! {
        didSet {
            // Add any necessary setup for filter bar
        }
    }

    @IBOutlet private var contentContainerView: UIView!

    private var filtersButton: UIButton {
        filterBarView.filtersButton
    }

    private lazy var resultsVC = makeResultsViewController()

    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "\(NewsViewController.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }

    @available(*, unavailable)
    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        fatalError("\(#function) not available")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureBindings()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Private APIs

private extension NewsViewController {

    func configureViewHierarchy() {
        // Setup any additional view hierarchy if needed
    }

    func makeResultsViewController() -> NewsCollectionViewController {
        let resultsViewController = NewsCollectionViewController(viewModel: viewModel)
        return resultsViewController
    }

    func makeEmptyResultsViewController() -> UIViewController {
        UIViewController.emptyViewController(
            detailedText: .localized("label_news_empty_state_subtitle")
        )
    }

    func makeLoadingViewController() -> LoadingViewController {
        LoadingViewController()
    }

    func addRefreshControl(to viewController: UIRefreshableViewController, isLoading: Bool) {
        let refreshControl = UIRefreshControl()
        refreshControl.publisher(for: .valueChanged)
            .sink { [weak viewModel] in
                viewModel?.fetchNews(refresh: true)
            }
            .store(in: &subscriptions)
        viewController.refreshControl = refreshControl
        refreshControl.isLoading = isLoading
    }

    func configureBindings() {
        filtersButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.showFiltersHandler()
            }
            .store(in: &subscriptions)

        viewModel.$isLoadingFirstPage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self
                else { return }

                if let refreshableContent = self.content as? UIRefreshableViewController,
                   let refreshControl = refreshableContent.refreshControl {
                    if isLoading && !refreshControl.isRefreshing {
                        refreshControl.beginRefreshing()
                    } else if !isLoading {
                        refreshControl.endRefreshing()
                    }
                } else {
                    if isLoading {
                        self.content = self.makeLoadingViewController()
                    } else {
                        if self.content is LoadingViewController {
                            self.content = nil
                        }
                    }
                }
            })
            .store(in: &subscriptions)

        viewModel.$error
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let error = $0
                else { return }
                
                self?.content = MessageViewController(error: error)
            }
            .store(in: &subscriptions)

		viewModel.$isEmpty
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isNewsEmpty in
				guard let self = self
				else { return }

				if isNewsEmpty {
					self.content = self.makeEmptyResultsViewController()
				} else {
					if !(self.content is NewsCollectionViewController) {
						self.content = self.resultsVC
					}
				}
			}
			.store(in: &subscriptions)

        // Handle active filters count to update the filters button
        viewModel.$activeFilters
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink { [unowned filtersButton] numberOfFilters in
                let title: String? = {
                    switch numberOfFilters {
                    case 0:
                        return nil
                    default:
                        return "(\(numberOfFilters))"
                    }
                }()
                filtersButton.setInsets(
                    forContentPadding: .init(
                        top: 8,
                        left: 8,
                        bottom: 8,
                        right: 8
                    ),
                    imageTitlePadding: title == nil ? 0 : 8
                )
                filtersButton.setTitle(title, for: .normal)
            }
            .store(in: &subscriptions)
    }
}
