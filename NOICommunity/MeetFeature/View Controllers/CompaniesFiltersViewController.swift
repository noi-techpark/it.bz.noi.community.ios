// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CompaniesFiltersViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 01/06/22.
//

import UIKit
import Combine
import PeopleClient

// MARK: CompaniesFiltersViewController

final class CompaniesFiltersViewController: UIViewController {
    
    @IBOutlet private var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = .localized("search_label")
        }
    }

    @IBOutlet private var filtersBarView: FiltersBarView! {
        didSet {
            filtersBarView.items = companyViewModel
                .filterItems
                .map(\.title)
            filtersBarView.scrollView.contentInset = .init(
                top: 0,
                left: 8,
                bottom: 0,
                right: 8
            )
        }
    }

    @IBOutlet private var searchBarContainerView: UIView!
    
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

    private var filters: UISegmentedControl {
        filtersBarView.segmentedControl
    }

    private var filtersScrollView: UIScrollView {
        filtersBarView.scrollView
    }

    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var companyViewModel = peopleViewModel.makeCompanyViewModel()
    
    private lazy var containerVC = ContainerViewController(content: nil)
    
    private lazy var resultsVC = CollectionViewController(
        peopleViewModel: peopleViewModel,
        companyViewModel: companyViewModel
    )
    
    private lazy var emptyResultsVC: MessageViewController = {
        let emptyResultsVC = UIViewController.emptyViewController(
            detailedText: .localized("label_filters_empty_state_subtitle")
        )
        emptyResultsVC.loadViewIfNeeded()
        return emptyResultsVC
    }()
    
    let peopleViewModel: PeopleViewModel
    
    init(peopleViewModel: PeopleViewModel) {
        self.peopleViewModel = peopleViewModel
        super.init(nibName: "\(Self.self)", bundle: nil)
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
        
        embedChild(containerVC)
        view.bringSubviewToFront(searchBarContainerView)
        view.bringSubviewToFront(actionsContainersView)
        
        configureBindings()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentScrollViews = [
            resultsVC.collectionView!,
            emptyResultsVC.scrollView!
        ]
        contentScrollViews.forEach { scrollView in
            var contentInset = scrollView.contentInset
            contentInset.top = self.searchBarContainerView.frame.height
            contentInset.bottom = self.actionsContainersView.frame.height
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
}

// MARK: Private APIs

private extension CompaniesFiltersViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Initial, CompanyId>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Initial, CompanyId>

    func configureBindings() {
        searchBar.delegate = resultsVC
        
        peopleViewModel.$numberOfResults
            .receive(on: DispatchQueue.main)
            .sink { [weak showResultsButton] numberOfResults in
                showResultsButton?.setTitle(
                    .localizedStringWithFormat(
                        .localized("show_results_btn_format"),
                        numberOfResults
                    ),
                    for: .normal
                )
            }
            .store(in: &subscriptions)
        
        resetActiveFiltersButton.publisher(for: .primaryActionTriggered)
            .sink { [unowned peopleViewModel] in
                peopleViewModel.clearActiveFilters()
            }
            .store(in: &subscriptions)
        
        showResultsButton.publisher(for: .primaryActionTriggered)
            .sink { [unowned peopleViewModel] in
                peopleViewModel.showFilteredResults()
            }
            .store(in: &subscriptions)
        
        companyViewModel
            .$results
            .map { $0?.1.isEmpty }
            .sink { [weak self] isEmpty in
                guard let self = self
                else { return }

                if isEmpty == true {
                    self.containerVC.content = self.emptyResultsVC
                } else {
                    self.containerVC.content = self.resultsVC
                }
            }
            .store(in: &subscriptions)

        companyViewModel
            .$activeFilter
            .sink { [weak filters, weak companyViewModel] newActiveFilter in
                guard let filters,
                      let companyViewModel
                else { return }

                if let matchingIndex = companyViewModel.filterItems.firstIndex(of: newActiveFilter) {
                    filters.selectedSegmentIndex = matchingIndex
                } else {
                    filters.selectedSegmentIndex = UISegmentedControl.noSegment
                }
            }
            .store(in: &subscriptions)

        filters
            .publisher(for: .valueChanged)
            .sink { [weak filters, weak companyViewModel, weak filtersScrollView] in
                guard let filters,
                      let companyViewModel,
                      let filtersScrollView
                else { return }

                let selectedSegmentIndex = filters.selectedSegmentIndex
                let newSelectedFilter = companyViewModel.filterItems[selectedSegmentIndex]
                companyViewModel.filterBy(filter: newSelectedFilter)

                let convertRect: (UIView) -> CGRect = {
                    $0.convert($0.frame, to: filtersScrollView)
                }
                let selectedControls = filters
                    .recursiveSubviews { $0 is UILabel }
                    .sorted { convertRect($0).minX < convertRect($1).minX }
                let selectedControl = selectedControls[selectedSegmentIndex]
                let selectedControlRect = convertRect(selectedControl)
                if !filtersScrollView.bounds.contains(
                    selectedControlRect
                ) {
                    let targetScrollingRect = selectedControlRect
                        .insetBy(dx: -100, dy: 0)
                    filtersScrollView.scrollRectToVisible(
                        targetScrollingRect,
                        animated: true
                    )
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: CompaniesFiltersViewController.CollectionViewController

private extension CompaniesFiltersViewController {
    
    final class CollectionViewController: UICollectionViewController {
        
        let peopleViewModel: PeopleViewModel
        
        let companyViewModel: CompanyViewModel
        
        private var dataSource: DataSource!

        var didSelectHandler: ((CompanyId) -> Void)?
        
        private var subscriptions: Set<AnyCancellable> = []
        
        init(
            peopleViewModel: PeopleViewModel,
            companyViewModel: CompanyViewModel
        ) {
            self.peopleViewModel = peopleViewModel
            self.companyViewModel = companyViewModel
            
            super.init(collectionViewLayout: UICollectionViewFlowLayout())
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("\(#function) not available")
        }
        
        @available(*, unavailable)
        override init(
            collectionViewLayout layout: UICollectionViewLayout
        ) {
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
                        
            configureCollectionView()
            configureDataSource()
            configureBindings()
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            .lightContent
        }
    }
    
}

// MARK: Private APIs

private extension CompaniesFiltersViewController.CollectionViewController {
    
    func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.headerMode = .supplementary
        config.backgroundColor = .noiSecondaryBackgroundColor
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.collectionViewLayout = createLayout()
        collectionView.allowsSelection = false
    }
    
    func filter(_ companyId: CompanyId, didChangeValue isOn: Bool) {
        var newActiveCompanyIdsFilter = peopleViewModel.activeCompanyIdsFilter
        ?? []
        if isOn {
            newActiveCompanyIdsFilter.insert(companyId)
        } else {
            newActiveCompanyIdsFilter.remove(companyId)
        }
        peopleViewModel.filter(
            searchTerm: peopleViewModel.activeSearchTerm,
            companyIds: newActiveCompanyIdsFilter.isEmpty ? nil : newActiveCompanyIdsFilter
        )
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CompanyId> { cell, _, companyId in
            let company = self.companyViewModel.company(withId: companyId)
            
            var contentConfiguration = UIListContentConfiguration.noiCell2()
            
            contentConfiguration.text = company?.name
            cell.contentConfiguration = contentConfiguration
            
            cell.backgroundConfiguration = .noiListPlainCell(for: cell)
            
            let `switch` = UISwitch()
            `switch`.isOn = self.peopleViewModel
                .activeCompanyIdsFilter?
                .contains(companyId) ?? false
            `switch`.addAction(
                .init(handler: { [weak self] action in
                    let `switch` = action.sender as! UISwitch
                    self?.filter(companyId, didChangeValue: `switch`.isOn)
                }),
                for: .valueChanged
            )
            let customAccessory = UICellAccessory.CustomViewConfiguration(
                customView: `switch`,
                placement: .trailing(displayed: .always)
            )
            cell.accessories = [.customView(configuration: customAccessory)]
        }
        
        let headerRegistration = UICollectionView
            .SupplementaryRegistration<UICollectionViewListCell>(
                elementKind: UICollectionView.elementKindSectionHeader
            ) { cell, kind, indexPath in
                let initial = self.dataSource
                    .snapshot()
                    .sectionIdentifiers[indexPath.section]

                var config = UIListContentConfiguration.noiGroupedHeader()
                config.text = initial.value
                cell.contentConfiguration = config
            }
        
        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration,
                    for: indexPath
                )
            default:
                return nil
            }
        }
        
        updateUI(companyViewModel.results, animated: false)
    }
    
    func updateUI(
        _ result: ([Initial], [Initial: [CompanyId]]),
        animated: Bool
    ) {
        let (sections, sectionToItems) = result
        var snapshot = CompaniesFiltersViewController.Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(sectionToItems[section]!, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func updateUI(
        oldOnItemsIds: Set<CompanyId>,
        newOnItemsIds: Set<CompanyId>
    ) {
        let itemsWithChangedIsOn = Array(oldOnItemsIds.union(newOnItemsIds))
        reconfigureFiltersWithIds(itemsWithChangedIsOn, animated: true)
    }
    
    func reconfigureFiltersWithIds(
        _ filterIds: [CompanyId],
        animated: Bool
    ) {
        let reconfigureIndexPaths = filterIds.compactMap {
            dataSource.indexPath(for: $0)
        }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let foundIndexPaths = visibleIndexPaths
            .filter { reconfigureIndexPaths.contains($0) }
        
        for foundIndexPath in foundIndexPaths {
            guard let cell = collectionView
                .cellForItem(at: foundIndexPath) as? UICollectionViewListCell
            else { return }
            
            guard let companyId = dataSource.itemIdentifier(for: foundIndexPath)
            else { return }
            
            let isOn = peopleViewModel.activeCompanyIdsFilter?
                .contains(companyId) ?? false
            cell.setSwitchOn(isOn, animated: animated)
        }
    }
    
    func configureBindings() {
        companyViewModel.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let isOnScreen = self?.viewIfLoaded?.window != nil
                self?.updateUI($0!, animated: isOnScreen)
            }
            .store(in: &subscriptions)
        
        peopleViewModel.$updatedCompanyIdsFilter
            .sink { [weak self] in
                let isOnScreen = self?.viewIfLoaded?.window != nil
                self?.reconfigureFiltersWithIds($0, animated: isOnScreen)
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: UISearchBarDelegate {

extension CompaniesFiltersViewController.CollectionViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.returnKeyType = .done
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        companyViewModel.filterBy(searchTerm: searchText)
    }
    
}

// MARK: UICollectionViewListCell Configure Helper

private extension UICollectionViewListCell {
    
    func setSwitchOn(_ on: Bool, animated: Bool) {
        let switchOrNil: UISwitch? = accessories
            .lazy
            .compactMap { accessory in
                guard case let .customView(customView) = accessory.accessoryType
                else { return nil }
                
                return customView as? UISwitch
            }
            .first
        switchOrNil?.setOn(on, animated: animated)
    }
    
}
