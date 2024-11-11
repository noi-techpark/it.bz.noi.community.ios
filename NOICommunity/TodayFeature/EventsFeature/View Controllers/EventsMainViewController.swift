// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventsMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 16/09/21.
//

import UIKit
import Combine

protocol UIRefreshableViewController: UIViewController {
    var refreshControl: UIRefreshControl? { get set }
}

extension EventListViewController: UIRefreshableViewController {}

extension MessageViewController: UIRefreshableViewController {}

final class EventsMainViewController: UIViewController {

    let viewModel: EventsViewModel

    var didSelectHandler: ((
        UICollectionView,
        UICollectionViewCell,
        IndexPath,
        Event
    ) -> Void)?

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

    @IBOutlet private var filterBarView: EventsFiltersBarView! {
        didSet {
            filterBarView.filtersBarView.delegate = self
        }
    }

    @IBOutlet private var contentContainerView: UIView!

    private var filtersButton: UIButton {
        filterBarView.filtersButton
    }

    private lazy var resultsVC = makeResultsViewController()

    init(viewModel: EventsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "\(EventsMainViewController.self)", bundle: nil)
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


        viewModel.refreshEvents()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Private APIs

private extension EventsMainViewController {

    func configureViewHierarchy() {
    }

    func makeResultsViewController() -> EventListViewController {
        let resultsViewController = EventListViewController(items: [])
        resultsViewController.didSelectHandler = { [weak self] in
            self?.didSelectHandler?($0, $1, $2, $3)
        }
        return resultsViewController
    }

    func makeEmptyResultsViewController() -> UIViewController {
        UIViewController.emptyViewController(
            detailedText: .localized("label_events_empty_state_subtitle")
        )
    }

    func makeLoadingViewController() -> LoadingViewController {
        LoadingViewController()
    }

    func addRefreshControl(to viewController: UIRefreshableViewController, isLoading: Bool) {
        let refreshControl = UIRefreshControl()
        refreshControl.publisher(for: .valueChanged)
            .sink { [weak viewModel] in
                viewModel?.refreshEvents()
            }
            .store(in: &subscriptions)
        viewController.refreshControl = refreshControl
        refreshControl.isLoading = isLoading
    }

    func configureBindings() {
        filtersButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.showFilters()
            }
            .store(in: &subscriptions)

        viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self
                else { return }

                if let refreshableContent = self.content as? UIRefreshableViewController,
                   let refreshControl = refreshableContent.refreshControl {
                    refreshControl.isLoading = isLoading
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

        viewModel.$eventResults
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self
                else { return }

                self.resultsVC.items = results ?? []
                switch results?.isEmpty {
                case nil:
                    break
                case false?:
                    self.content = self.resultsVC
                case true?:
                    self.content = self.makeEmptyResultsViewController()
                }
            }
            .store(in: &subscriptions)

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

        viewModel.$dateIntervalFilter
            .sink { [weak self] newActiveFilter in
                guard let self
                else { return }

                self.filterBarView.filtersBarView.indexOfSelectedItem = DateIntervalFilter.allCases.firstIndex(of: newActiveFilter)
            }
            .store(in: &subscriptions)
    }
}

// MARK: FilterBarViewDelegate

extension EventsMainViewController: FiltersBarViewDelegate {

    func filtersBarView(
        _ filtersBarView: FiltersBarView,
        didSelectItemAt index: Int
    ) {
        let newDateIntervalFilter = DateIntervalFilter.allCases[index]
        viewModel.dateIntervalFilter = newDateIntervalFilter
        viewModel.refreshEvents()
    }

}
