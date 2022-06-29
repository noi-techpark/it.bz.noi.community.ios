//
//  MeetMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit
import Combine
import PeopleClient

// MARK: - MeetMainViewController

final class MeetMainViewController: UIViewController {
    
    @IBOutlet private var barView: MeetFilterBarView!
    
    @IBOutlet private var containerView: UIView!
    
    @IBOutlet private var topBarViewContraint: NSLayoutConstraint!
    
    private var firstLoadingRequest: AnyCancellable?
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var collectionVC = CollectionViewController(
        viewModel: viewModel
    )
    
    let viewModel: PeopleViewModel
    
    init(viewModel: PeopleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
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
        
        defer {
            viewModel.fetchPeople()
        }
        embedChild(collectionVC, in: containerView)
        
        configureBindings()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}

// MARK: UISearchBarDelegate {

extension MeetMainViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.returnKeyType = .done
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(
            searchTerm: searchText,
            companyIds: viewModel.activeCompanyIdsFilter
        )
    }
    
}

// MARK: Private APIs

private extension MeetMainViewController {
    
    func configureBindings() {
        barView.searchBar.delegate = self
        
        barView.filtersButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel, filtersButton = barView.filtersButton] in
                viewModel?.showFiltersHandler(filtersButton)
            }
            .store(in: &subscriptions)
        
        viewModel.$activeSearchTerm.receive(on: DispatchQueue.main)
            .sink { [unowned searchBar = barView.searchBar] searchTerm in
                searchBar?.text = searchTerm
            }
            .store(in: &subscriptions)
        
        viewModel.$activeCompanyIdsFilter
            .map { $0?.count ?? 0 }
            .receive(on: DispatchQueue.main)
            .sink { [unowned filtersButton = barView.filtersButton] numberOfFilters in
                let title: String? = {
                    switch numberOfFilters {
                    case 0:
                        return nil
                    default:
                        return "(\(numberOfFilters))"
                    }
                }()
                filtersButton?.setInsets(
                    forContentPadding: .init(
                        top: 8,
                        left: 8,
                        bottom: 8,
                        right: 8
                    ),
                    imageTitlePadding: title == nil ? 0 : 8
                )
                filtersButton?.setTitle(title, for: .normal)
            }
            .store(in: &subscriptions)
        
        viewModel.$peopleIds
            .receive(on: DispatchQueue.main)
            .sink { [unowned barView] in
                barView?.filtersButton.isEnabled = !$0.isNilOrEmpty
                barView?.searchBar.searchTextField.isEnabled = !$0.isNilOrEmpty
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: - MeetMainViewController.CollectionViewController

private extension MeetMainViewController {
    
    final class CollectionViewController: UICollectionViewController {
        
        let viewModel: PeopleViewModel
        
        private var dataSource: UICollectionViewDiffableDataSource<Section, PersonId>! = nil
        
        private var subscriptions: Set<AnyCancellable> = []
        
        private var refreshControl: UIRefreshControl? {
            get { collectionView.refreshControl }
            set { collectionView.refreshControl = newValue }
        }
        
        var didSelectHandler: ((PersonId) -> Void)?
                
        private lazy var emptyResultsVC: MessageViewController = {
            let emptyResultsVC = UIViewController.emptyViewController(
                detailedText: .localized("label_contacts_empty_state_subtitle")
            )
            emptyResultsVC.loadViewIfNeeded()
            return emptyResultsVC
        }()
        
        init(viewModel: PeopleViewModel) {
            self.viewModel = viewModel
            
            super.init(collectionViewLayout: UICollectionViewFlowLayout())
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            let changes = {
                self.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                    self.collectionView.deselectItem(at: indexPath, animated: animated)
                }
            }
            let enqueued = transitionCoordinator?.animate(
                alongsideTransition: { _ in
                    changes()
                }, completion: { _ in
                    changes()
                }
            ) ?? false
            if !enqueued {
                changes()
            }
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
            
            refreshControl = UIRefreshControl()
            configureCollectionView()
            configureDataSource()
            configureBindings()
        }
    }
    
}


// MARK: Private APIs

private extension MeetMainViewController.CollectionViewController {
    enum Section: Hashable {
        case main
    }
    
    func columnCount(
        for layoutEnviroment: NSCollectionLayoutEnvironment
    ) -> Int {
        switch (
            layoutEnviroment.container.effectiveContentSize.width
        ) {
        case 0..<600:
            return 1
        default:
            return 2
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let columns = self.columnCount(for: layoutEnvironment)
            
            let estimatedHeight = NSCollectionLayoutDimension.estimated(84)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: estimatedHeight
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: estimatedHeight
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: columns
            )
            group.interItemSpacing = .fixed(2)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 2
            
            return section
        }
        return layout
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.collectionViewLayout = createLayout()
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, PersonId> { [viewModel] cell, _, personId in
            let person = viewModel.person(withId: personId)
            let company = person.companyId.flatMap {
                viewModel.company(withId: $0)
            }
            
            var contentConfiguration = PersonCardContentConfiguration()
            
            contentConfiguration.fullname = person.fullname
            contentConfiguration.fullnameTextProprieties.font = .NOI.footnoteSemibold
            
            contentConfiguration.company = company?.name ?? "N/D"
            contentConfiguration.companyTextProprieties.font = .NOI.bodyRegular
            
            contentConfiguration.avatarText = [
                person.firstname.prefix(1),
                person.lastname.prefix(1)
            ]
                .joined()
                .uppercased()
            contentConfiguration.avatarTextProprieties.font = .NOI.bodySemibold
            
            cell.contentConfiguration = contentConfiguration
            
            cell.backgroundConfiguration = .noiListPlainCell(for: cell)
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
    }
    
    func updateUI(peopleIds: [PersonId]?, animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PersonId>()
        if let peopleIds = peopleIds {
            snapshot.appendSections([.main])
            snapshot.appendItems(peopleIds, toSection: .main)
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func configureBindings() {
        refreshControl?.publisher(for: .valueChanged)
            .sink { [weak viewModel] in
                viewModel?.fetchPeople()
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.refreshControl?.isLoading = isLoading
            })
            .store(in: &subscriptions)
        
        viewModel.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let isOnScreen = self?.viewIfLoaded?.window != nil
                self?.updateUI(peopleIds: $0, animated: isOnScreen)
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error
                else { return }
                
                self?.showError(error)
            }
            .store(in: &subscriptions)
        
        viewModel.$results
            .map(\.?.isEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                guard let self = self
                else { return }
                
                guard isEmpty == true
                else {
                    defer {
                        self.collectionView.backgroundView = nil
                    }
                    
                    if self.emptyResultsVC.parent != nil {
                        self.emptyResultsVC.willMove(toParent: nil)
                        self.emptyResultsVC.view.removeFromSuperview()
                        self.emptyResultsVC.removeFromParent()
                    }
                    
                    return
                }
                
                guard self.emptyResultsVC.parent == nil
                else { return }
                
                let containerView = self.collectionView.backgroundView ?? UIView()
                self.collectionView.backgroundView = containerView
                self.embedChild(self.emptyResultsVC, in: containerView)
                self.view.layoutIfNeeded()
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: UICollectionViewDelegate

extension MeetMainViewController.CollectionViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let personId = dataSource.itemIdentifier(for:indexPath)!
        let selectedCell = collectionView.cellForItem(at: indexPath)!
        viewModel.showPersonDetails(of: personId, sender: selectedCell)
    }
    
}
