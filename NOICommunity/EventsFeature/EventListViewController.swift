//
//  EventListViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import UIKit
import Kingfisher

class EventListViewController: UICollectionViewController {
    var items: [Event] {
        didSet {
            guard isViewLoaded
            else { return }
            
            let animated = view.window != nil
            updateUI(items: items, animated: animated)
        }
    }
    
    let embeddedHorizontally: Bool
    
    var refreshControl = UIRefreshControl()
    
    var didSelectHandler: ((IndexPath, Event) -> Void)?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Event>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Event>! = nil
    private var imagePrefetcher: ImagePrefetcher?
    
    init(items: [Event], embeddedHorizontally: Bool = false) {
        self.items = items
        self.embeddedHorizontally = embeddedHorizontally
        let collectionViewLayout = Self.createLayout(embeddedHorizontally: embeddedHorizontally)
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }
    
    @available(*, unavailable)
    override init(
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        fatalError("\(#function) not implemented")
    }
    
    @available(*, unavailable)
    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        fatalError("\(#function) not implemented")
    }
    
    @available(*, unavailable)
    init() {
        fatalError("\(#function) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
        updateUI(items: items, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = collectionView.contentSize
    }
}

// MARK: Private APIs

private extension EventListViewController {
    enum Section {
        case main
    }
    
    static func columnCount(
        for layoutEnviroment: NSCollectionLayoutEnvironment,
        embeddedHorizontally: Bool
    ) -> Int {
        switch (
            embeddedHorizontally,
            layoutEnviroment.container.effectiveContentSize.width
        ) {
        case (true, _),
            (_, 0..<600):
            return 1
        default:
            return 2
        }
    }
    
    static func createLayout(embeddedHorizontally: Bool) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let columns = self.columnCount(
                for: layoutEnvironment,
                   embeddedHorizontally: embeddedHorizontally
            )
            
            let estimatedHeight = NSCollectionLayoutDimension.estimated(300)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: estimatedHeight
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize: NSCollectionLayoutSize
            if embeddedHorizontally {
                groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: estimatedHeight
                )
            } else {
                groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: estimatedHeight
                )
            }
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: columns
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            if embeddedHorizontally {
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = .zero
            } else {
                section.orthogonalScrollingBehavior = .none
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 17,
                    bottom: 20,
                    trailing: 17
                )
            }
            return section
        }
        return layout
    }
    
    func configureDataSource() {
        let dayMonthIntervalFormatter = DateIntervalFormatter.dayMonth()
        let timeIntervalFormatter = DateIntervalFormatter.time()
        
        let cellRegistration = UICollectionView.CellRegistration<IdentifiableCollectionViewCell<Event>, Event> { cell, indexPath, item in
            cell.identifiable = item
            
            let contentConfiguration = EventCardContentConfiguration.makeContentConfiguration(
                for: item,
                   dayMonthIntervalFormatter: dayMonthIntervalFormatter,
                   timeIntervalFormatter: timeIntervalFormatter
            )
            cell.contentConfiguration = contentConfiguration
            
            if let imageURL = item.imageURL {
                KingfisherManager.shared
                    .retrieveImage(with: imageURL) { result in
                        guard
                            cell.identifiable.id == item.id,
                            case let .success(imageInfo) = result,
                            var contentConfiguration = cell.contentConfiguration as? EventCardContentConfiguration
                        else { return }
                        
                        contentConfiguration.image = imageInfo.image
                        cell.contentConfiguration = contentConfiguration
                    }
            }
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
    
    func configureCollectionView() {
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .secondaryBackgroundColor
        collectionView.prefetchDataSource = self
    }
    
    func updateUI(items: [Event], animated: Bool) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Event>()
        
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}

// MARK: UICollectionViewDataSourcePrefetching

extension EventListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        let imageUrls = indexPaths
            .compactMap(dataSource.itemIdentifier(for:))
            .compactMap(\.imageURL)
        guard !imageUrls.isEmpty
        else { return }

        let imagePrefetcher = ImagePrefetcher(urls: imageUrls)
        self.imagePrefetcher = imagePrefetcher
        imagePrefetcher.start()
    }
}

// MARK: UICollectionViewDelegate

extension EventListViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = dataSource.itemIdentifier(for:indexPath)!
        didSelectHandler?(indexPath, item)
    }
}
