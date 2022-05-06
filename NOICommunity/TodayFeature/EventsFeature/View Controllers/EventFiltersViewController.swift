//
//  EventFiltersViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/03/22.
//

import UIKit
import Combine

class EventFiltersViewController: UIViewController {

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

    let viewModel: EventFiltersViewModel

    init(viewModel: EventFiltersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "EventFiltersViewController", bundle: nil)
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
        viewModel.refreshEventsFilters()
    }
}

// MARK: Private APIs

private extension EventFiltersViewController {

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

    func makeResultsViewController() -> EventFiltersListViewController {
        let resultsViewController = EventFiltersListViewController(
            items: viewModel.filtersResults,
            onItemsIds: Set(viewModel.activeFilters.map(\.id))
        )
        resultsViewController
            .filterValueDidChangeHandler = { [weak viewModel] in
                viewModel?.setFilter($0, isActive: $1)
            }
        return resultsViewController
    }

    func configureBindings() {
        viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self
                else { return }

                self.updateContent(isLoading: isLoading)
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
                guard let self = self
                else { return }

                self.resultsVC.items = results
            }
            .store(in: &subscriptions)

        viewModel.$activeFilters
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] activeFiltersIds in
                resultsVC?.onItemsIds = Set(activeFiltersIds.map(\.id))
            }
            .store(in: &subscriptions)

        viewModel.$numberOfResults
            .receive(on: DispatchQueue.main)
            .sink { [weak showResultsButton] numberOfResults in
                showResultsButton?.setTitle(
                    .localizedStringWithFormat(
                        .localized("show_results_btn_format"),
                        numberOfResults
                    ),
                    for: .normal)
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

