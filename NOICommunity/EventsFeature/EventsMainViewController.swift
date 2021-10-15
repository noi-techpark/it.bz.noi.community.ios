//
//  EventsMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 16/09/21.
//

import UIKit
import Combine

final class EventsMainViewController: UIViewController {

    let viewModel: EventsViewModel

    var didSelectHandler: ((
        UICollectionView,
        UICollectionViewCell,
        IndexPath,
        Event
    ) -> Void)?

    private var subscriptions: Set<AnyCancellable> = []

    private var navigationBarFrameObserver: NSKeyValueObservation?

    @IBOutlet private var filterBarContainerView: UIView!
    @IBOutlet private var filterBarView: FiltersBarView!
    @IBOutlet private var filterBarViewTopConstraint: NSLayoutConstraint!

    private var dateIntervalsControl: UISegmentedControl {
        filterBarView.dateIntervalsControl
    }

    private var dateIntervalsScrollView: UIScrollView {
        filterBarView.scrollView
    }

    private var refreshControl: UIRefreshControl!

    private lazy var resultsVC = makeResultsViewController()

    init(viewModel: EventsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "\(EventsMainViewController.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    @available(*, unavailable)
    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        fatalError("\(#function) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureBindings()

        // Observe manually navigation bar frame, since there is a bug on
        // safe area insets when you make bounce navigation bar and scroll view
        // vertically
        navigationBarFrameObserver = navigationController?.navigationBar
            .observe(\.frame, options: [.new]) { [weak self] navigationBar, _ in
                guard let self = self
                else { return }

                let navBarMaxY = navigationBar.frame.maxY
                let safeAreaTop = self.view.safeAreaInsets.top
                self.filterBarViewTopConstraint.constant = navBarMaxY - safeAreaTop
            }

        viewModel.refreshEvents()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Private APIs

private extension EventsMainViewController {

    func configureViewHierarchy() {
        refreshControl = UIRefreshControl()
    }

    func makeResultsViewController() -> EventListViewController {
        let resultsViewController = EventListViewController(items: [])
        resultsViewController.didSelectHandler = { [weak self] in
            self?.didSelectHandler?($0, $1, $2, $3)
        }
        resultsViewController.refreshControl = refreshControl
        return resultsViewController
    }

    func makeEmptyResultsViewController() -> MessageViewController {
        let emptyResultsVC = MessageViewController(
            text: .localized("label_events_empty_state_title"),
            detailedText: .localized("label_events_empty_state_subtitle")
        )
        emptyResultsVC.refreshControl = refreshControl
        return emptyResultsVC
    }

    func makeLoadingViewController() -> LoadingViewController {
        LoadingViewController()
    }

    func configureBindings() {
        refreshControl.publisher(for: .valueChanged)
            .sink { [weak viewModel] in
                viewModel?.refreshEvents()
            }
            .store(in: &subscriptions)

        dateIntervalsControl.publisher(for: .valueChanged)
            .sink { [unowned dateIntervalsControl, weak viewModel, weak dateIntervalsScrollView] in
                let selectedSegmentIndex = dateIntervalsControl.selectedSegmentIndex

                let newDateIntervalFilter = DateIntervalFilter
                    .allCases[dateIntervalsControl.selectedSegmentIndex]
                viewModel?.refreshEvents(
                    dateIntervalFilter: newDateIntervalFilter
                )

                if let dateIntervalsScrollView = dateIntervalsScrollView {
                    let convertRect: (UIView) -> CGRect = {
                        $0.convert($0.frame, to: dateIntervalsScrollView)
                    }
                    let selectedControls = dateIntervalsControl
                        .recursiveSubviews { $0 is UILabel }
                        .sorted { convertRect($0).minX < convertRect($1).minX }
                    let selectedControl = selectedControls[selectedSegmentIndex]
                    let selectedControlRect = convertRect(selectedControl)
                    if !dateIntervalsScrollView.bounds.contains(
                        selectedControlRect
                    ) {
                        let targetScrollingRect = selectedControlRect
                            .insetBy(dx: -100, dy: 0)
                        dateIntervalsScrollView.scrollRectToVisible(
                            targetScrollingRect,
                            animated: true
                        )
                    }
                }
            }
            .store(in: &subscriptions)

        viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self
                else { return }

                if !self.children.isEmpty {
                    if isLoading {
                        if !self.refreshControl.isRefreshing {
                            self.refreshControl.beginRefreshing()
                        }
                    } else {
                        if self.refreshControl.isRefreshing {
                            self.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    if isLoading {
                        self.display(content: self.makeLoadingViewController())
                    }
                }
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

        viewModel.$eventResults
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self
                else { return }

                guard let results = results
                else { return }

                self.resultsVC.items = results
                if results.isEmpty {
                    self.display(content: self.makeEmptyResultsViewController())
                } else {
                    self.display(content: self.resultsVC)
                }
            }
            .store(in: &subscriptions)
    }

    func display(content: UIViewController) {
        guard children.last != content
        else { return }

        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        content.additionalSafeAreaInsets = UIEdgeInsets(
            top: filterBarContainerView.bounds.height,
            left: 0,
            bottom: 0,
            right: 0
        )

        addChild(content)
        let contentView = content.view!
        view.insertSubview(contentView, at: 0)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        content.didMove(toParent: self)
    }
}
