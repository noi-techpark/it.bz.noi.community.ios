// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsFiltersViewController.swift
//  NOICommunity
//
//  Created by Camilla on 27/02/25.
//

import UIKit
import Combine
import ArticleTagsClient

class NewsFiltersViewController: UIViewController {

    @IBOutlet private var contentContainer: UIView!

    @IBOutlet private var actionsContainersView: FooterView!

    @IBOutlet private var resetActiveFiltersButton: UIButton! {
        didSet {
            resetActiveFiltersButton
                .configureAsTertiaryActionButton()
                .withMinimumHeight(44)
                .withTitle(.localized("reset_filters_btn"))
        }
    }

    @IBOutlet private var showResultsButton: UIButton! {
        didSet {
            showResultsButton
                .configureAsPrimaryActionButton()
        }
    }

    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var resultsVC = makeResultsViewController()
    
    let viewModel: NewsFiltersViewModel
    
    init(viewModel: NewsFiltersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "NewsFiltersViewController", bundle: nil)
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
    
    @available(*, unavailable)
    init() {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = .localized("title_filters")
        configureBindings()
        viewModel.fetchPossibleFilters()
    }
}

// MARK: Private APIs

private extension NewsFiltersViewController {
    
    func updateContent(isLoading: Bool) {
        if isLoading {
            embedChild(
                LoadingViewController(style: .light),
                in: contentContainer
            )
        } else {
            embedChild(resultsVC, in: contentContainer)
        }
    }
    
    func makeResultsViewController() -> NewsFiltersListViewController {
        let resultsViewController = NewsFiltersListViewController(
            items: viewModel.filtersResults,
            onItemsIds: viewModel.activeFilters
        )
        resultsViewController.filterValueDidChangeHandler = { [weak viewModel] in
            viewModel?.setFilter($0, isActive: $1)
        }
        return resultsViewController
    }
    
    func configureBindings() {
        viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.updateContent(isLoading: isLoading)
            })
            .store(in: &subscriptions)
        
        viewModel.$error
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$filtersResults
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.resultsVC.items = results
            }
            .store(in: &subscriptions)
        
        viewModel.$activeFilters
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] activeFiltersIds in
                resultsVC?.onItemsIds = activeFiltersIds
            }
            .store(in: &subscriptions)
        
        viewModel.$numberOfResults
            .receive(on: DispatchQueue.main)
            .sink { [weak showResultsButton] numberOfResults in
                showResultsButton?.setTitle(
                    .localizedStringWithFormat(
                        .localized("show_results_btn_format"), // TODO: mettere nuovo show results senza numero
                        numberOfResults
                    ),
                    for: .normal
                )
            }
            .store(in: &subscriptions)
        
        resetActiveFiltersButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.clearActiveFilters()
            }
            .store(in: &subscriptions)
        
        showResultsButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.showFilteredResults()
            }
            .store(in: &subscriptions)
    }

}
