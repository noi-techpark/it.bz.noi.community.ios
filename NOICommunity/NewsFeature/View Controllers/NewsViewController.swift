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
import Kingfisher
import ArticlesClient
import ArticleTagsClient

private let loadNextPageOnItemIndexOffset = 0

// MARK: - NewsViewController

class NewsViewController: UICollectionViewController {
    
    let viewModel: NewsListViewModel
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var newsFilterBarView: NewsFilterBarView!
    
    private var refreshControl: UIRefreshControl? {
        get { collectionView.refreshControl }
        set { collectionView.refreshControl = newValue }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
    private var imagePrefetcher: ImagePrefetcher?
    
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
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
    
    @available(*, unavailable)
    init() {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNewsFilterBar()
        
        defer {
            viewModel.fetchNews()
        }
        
        refreshControl = UIRefreshControl()
        configureCollectionView()
        configureDataSource()
        configureBindings()
    }
    
    private func setupNewsFilterBar() {
        let filterBarContainerView = UIView()
        filterBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        filterBarContainerView.backgroundColor = .noiSecondaryBackgroundColor
        view.addSubview(filterBarContainerView)

        newsFilterBarView = NewsFilterBarView()
        newsFilterBarView.translatesAutoresizingMaskIntoConstraints = false
        filterBarContainerView.addSubview(newsFilterBarView)
        
        // Add action to the filter button
        newsFilterBarView.filtersButton.addTarget(
            self,
            action: #selector(goToFilters),
            for: .touchUpInside
        )
        
        // Reposition the collection view to start after the filter bar
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Remove collection view from its current position
        collectionView.removeFromSuperview()
        // Add it back to the view hierarchy
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            // Filter bar container anchored to the top
            filterBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Filter bar inside container with proper spacing
            newsFilterBarView.topAnchor.constraint(equalTo: filterBarContainerView.topAnchor, constant: 17),
            newsFilterBarView.leadingAnchor.constraint(equalTo: filterBarContainerView.leadingAnchor),
            newsFilterBarView.trailingAnchor.constraint(equalTo: filterBarContainerView.trailingAnchor),
            newsFilterBarView.bottomAnchor.constraint(equalTo: filterBarContainerView.bottomAnchor, constant: -17),
            
            // Position collection view BELOW the filter bar container
            collectionView.topAnchor.constraint(equalTo: filterBarContainerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Reset content insets since we're properly positioning the collection view now
        collectionView.contentInset.top = 0
        collectionView.scrollIndicatorInsets.top = 0
    }
    
    @objc private func goToFilters() {
        viewModel.showFiltersHandler()
    }
    
    @objc private func closeFilters() {
        dismiss(animated: true, completion: nil)
    }




    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}

// MARK: Private APIs

private extension NewsViewController {
    
    enum Section {
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
            
            let estimatedHeight = NSCollectionLayoutDimension.estimated(137)
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
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            )
            return section
        }
        return layout
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<IdentifiableCollectionViewCell<String>, String> { cell, indexPath, newsId in
            cell.id = newsId
            
            let item = self.viewModel.news(withId: newsId)
            
            cell.backgroundConfiguration = UIBackgroundConfiguration.noiListPlainCell(for: cell)
            
            let contentConfiguration = NewsCardContentConfiguration
                .makeContentConfiguration(for: item)
            
            cell.contentConfiguration = contentConfiguration
            
            if let author = localizedValue(from: item.languageToAuthor),
               let authorImageURL = author.logoURL {
                KingfisherManager.shared
                    .retrieveImage(with: authorImageURL) { result in
                        guard
                            cell.id == item.id,
                            case let .success(imageInfo) = result,
                            var contentConfiguration = cell.contentConfiguration as? NewsCardContentConfiguration
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
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.prefetchDataSource = self
        collectionView.collectionViewLayout = createLayout()
    }
    
    func configureBindings() {
        refreshControl?.publisher(for: .valueChanged)
            .sink { [weak viewModel] in
                viewModel?.fetchNews(refresh: true)
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoadingFirstPage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingFirstPage in
                guard let self else { return }
                
                if isLoadingFirstPage {
                    self.updateUI(
                        newsIds: [],
                        animated: self.isInWindowHierarchy
                    )

					if let refreshControl, !refreshControl.isRefreshing {
						refreshControl.beginRefreshing()
					}
				} else {
					self.refreshControl?.endRefreshing()
				}
            })
            .store(in: &subscriptions)
        
        viewModel.$newsIds            
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }

                self.updateUI(newsIds: $0, animated: self.isInWindowHierarchy)
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
    }
    
    func updateUI(newsIds: [String], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(newsIds, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func needsToTriggerNextPageFetchForIndexPath(_ indexPath: IndexPath) -> Bool {
        guard viewModel.hasNextPage, !viewModel.isLoading
        else { return false }

        let lastSectionIndex = collectionView.numberOfSections - 1
        guard indexPath.section == lastSectionIndex
        else { return false }
        
        let lastItemIndex = collectionView.numberOfItems(
            inSection: lastSectionIndex
        ) - 1
        return indexPath.item == lastItemIndex - loadNextPageOnItemIndexOffset
    }
    
}

// MARK: UICollectionViewDataSourcePrefetching

extension NewsViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        // Prefetch images from URLs
        let imageURLs: [URL] = indexPaths
            .compactMap(dataSource.itemIdentifier(for:))
            .map { self.viewModel.news(withId: $0)}
            .compactMap {
                let author = localizedValue(from: $0.languageToAuthor)
                return author?.logoURL
            }
        if !imageURLs.isEmpty {
            let imagePrefetcher = ImagePrefetcher(urls: imageURLs)
            self.imagePrefetcher = imagePrefetcher
            imagePrefetcher.start()
        }
        
        if indexPaths.contains(where: {
            self.needsToTriggerNextPageFetchForIndexPath($0)
        }) {
            viewModel.fetchNews()
        }
        
    }
    
}

// MARK: UICollectionViewDelegate

extension NewsViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let newsId = dataSource.itemIdentifier(for:indexPath)!
        let selectedCell = collectionView.cellForItem(at: indexPath)!
        viewModel.showNewsDetails(of: newsId, sender: selectedCell)
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if needsToTriggerNextPageFetchForIndexPath(indexPath) {
            viewModel.fetchNews()
        }
    }
    
}
