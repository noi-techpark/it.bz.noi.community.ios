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

    private lazy var dateIntervalsControl: UISegmentedControl = {
        let activeColor = UIColor.black
        let color = activeColor.withAlphaComponent(0.5)
        var imageFactory = UnderlineSegmentedControlImageFactory()
        imageFactory.size.height = 40
        imageFactory.lineWidth = 2
        imageFactory.selectedLineWidth = 2
        imageFactory.lineColor = color
        imageFactory.selectedLineColor = activeColor
        imageFactory.extraSpacing = 12
        var builder = SegmentedControlBuilder(
            imageFactory: imageFactory
        )
        builder.tintColor = color
        builder.selectedTintedColor = activeColor
        builder.font = .boldSystemFont(ofSize: 19)
        builder.font = .boldSystemFont(ofSize: 19)
        builder.selectedFont = builder.font
        builder.class = SegmentedControl.self
        return builder.makeSegmentedControl(
            items: DateIntervalFilter.allCases.map(\.localizedString)
        )
    }()

    @IBOutlet private var dateIntervalsScrollView: UIScrollView! {
        didSet {
            dateIntervalsScrollView.contentInset = .init(
                top: 0,
                left: 0,
                bottom: 0,
                right: 17
            )
            dateIntervalsScrollView.addSubview(dateIntervalsControl)
            dateIntervalsControl.translatesAutoresizingMaskIntoConstraints = false
            let contentGuide = dateIntervalsScrollView.contentLayoutGuide
            let frameGuide = dateIntervalsScrollView.frameLayoutGuide
            NSLayoutConstraint.activate([
                dateIntervalsControl.leadingAnchor
                    .constraint(equalTo: contentGuide.leadingAnchor),
                dateIntervalsControl.trailingAnchor
                    .constraint(equalTo: contentGuide.trailingAnchor),
                dateIntervalsControl.bottomAnchor
                    .constraint(equalTo: contentGuide.bottomAnchor),
                dateIntervalsControl.topAnchor
                    .constraint(equalTo: contentGuide.topAnchor),
                frameGuide.heightAnchor
                    .constraint(equalTo: contentGuide.heightAnchor),
            ])
        }
    }

    private var contentContainerVC: ContainerViewController!

    @IBOutlet private var topStackView: UIStackView!
    @IBOutlet private var contentContainerView: UIView!

    private var resultsVC: EventListViewController!

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
        configureChilds()
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

    func configureChilds() {
        resultsVC = makeResultsViewController()
        contentContainerVC = ContainerViewController(content: resultsVC)
        embedChild(contentContainerVC, in: contentContainerView)
    }

    func makeResultsViewController() -> EventListViewController {
        let resultsViewController = EventListViewController(items: [])
        resultsViewController.didSelectHandler = { [weak self] in
            self?.didSelectHandler?($0, $1, $2, $3)
        }
        return resultsViewController
    }

    func configureBindings() {
        resultsVC.refreshControl.publisher(for: .valueChanged)
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
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak resultsVC] isLoading in
                guard let refreshControl = resultsVC?.refreshControl
                else { return }

                if isLoading {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            })
            .store(in: &subscriptions)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &subscriptions)

        viewModel.$eventResults
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] results in
                resultsVC?.items = results
            }
            .store(in: &subscriptions)

        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak contentContainerVC, resultsVC] isEmpty in
                if isEmpty {
                    contentContainerVC?.content = MessageViewController(
                        text: .localized("label_events_empty_state_title"),
                        detailedText: .localized("label_events_empty_state_subtitle")
                    )
                } else {
                    contentContainerVC?.content = resultsVC
                }
            }
            .store(in: &subscriptions)
    }
}

private extension EventsMainViewController {
    class SegmentedControl: UISegmentedControl {

        // Removes swipe gesture
        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // Force a square shape
            layer.cornerRadius = 0
        }
    }
}
