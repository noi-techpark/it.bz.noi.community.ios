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
    @IBOutlet private var filterBarView: FiltersBarView!
    @IBOutlet private var contentContainerView: UIView!

    private var dateIntervalsControl: UISegmentedControl {
        filterBarView.dateIntervalsControl
    }

    private var dateIntervalsScrollView: UIScrollView {
        filterBarView.scrollView
    }

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

    func makeEmptyResultsViewController() -> MessageViewController {
        let emptyResultsVC = MessageViewController(
            text: .localized("label_events_empty_state_title"),
            detailedText: .localized("label_events_empty_state_subtitle")
        )
        return emptyResultsVC
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
    }
}
