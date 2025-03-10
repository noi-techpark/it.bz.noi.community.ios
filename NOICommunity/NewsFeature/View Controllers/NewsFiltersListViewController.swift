// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsFiltersListViewController.swift
//  NOICommunity
//
//  Created by Camilla on 27/02/25.
//

import UIKit
import ArticleTagsClient

class NewsFiltersListViewController: UICollectionViewController {

    var items: [ArticleTag] {
        didSet {
            guard items != oldValue, isViewLoaded else { return }
            let animated = view.window != nil
            updateUI(items: items, animated: animated)
        }
    }

    var onItemsIds: Set<ArticleTag.Id> = [] {
        didSet {
            guard onItemsIds != oldValue, isViewLoaded else { return }
            updateUI(oldOnItemsIds: oldValue, newOnItemsIds: onItemsIds)
        }
    }
    
    private var dict: [ArticleTag.Id: ArticleTag]

    var filterValueDidChangeHandler: ((ArticleTag, Bool) -> Void)!

    private var dataSource: UICollectionViewDiffableDataSource<Section, ArticleTag.Id>! = nil

    init(items: [ArticleTag], onItemsIds: Set<ArticleTag.Id> = []) {
        self.items = items
        self.onItemsIds = onItemsIds
        self.dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
}

// MARK: Private APIs

private extension NewsFiltersListViewController {
    
    func filter(_ item: ArticleTag, didChangeValue isOn: Bool) {
        filterValueDidChangeHandler(item, isOn)
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ArticleTag.Id> { cell, _, id in
            let item = self.dict[id]!
            
            var contentConfiguration = UIListContentConfiguration.noiCell2()
            contentConfiguration.text = localizedValue(from: item.tagName, defaultValue: item.id)
            cell.contentConfiguration = contentConfiguration
            cell.backgroundConfiguration = .noiListPlainCell(for: cell)
            
            let `switch` = UISwitch()
            `switch`.isOn = self.onItemsIds.contains(id)
            `switch`.addAction(
                .init(handler: { [weak self] action in
                    let `switch` = action.sender as! UISwitch
                    self?.filter(item, didChangeValue: `switch`.isOn)
                }),
                for: .valueChanged
            )
            let customAccessory = UICellAccessory.CustomViewConfiguration(
                customView: `switch`,
                placement: .trailing(displayed: .always)
            )
            cell.accessories = [.customView(configuration: customAccessory)]
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        updateUI(items: items, animated: false)
    }

    func updateUI(items: [ArticleTag], animated: Bool) {
        dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, ArticleTag.Id>()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems(items.map(\ .id), toSection: .main)
        dataSource.apply(newSnapshot, animatingDifferences: animated)
    }

    func updateUI(oldOnItemsIds: Set<ArticleTag.Id>, newOnItemsIds: Set<ArticleTag.Id>) {
        let itemsWithChangedIsOn = Array(oldOnItemsIds.union(newOnItemsIds))
        reconfigureFiltersWithIds(itemsWithChangedIsOn, animated: true)
    }

    func reconfigureFiltersWithIds(_ filterIds: [ArticleTag.Id], animated: Bool) {
        let reconfigureIndexPaths = filterIds.compactMap {
            dataSource.indexPath(for: $0)
        }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let foundIndexPaths = visibleIndexPaths
            .filter { reconfigureIndexPaths.contains($0) }

        for foundIndexPath in foundIndexPaths {
            guard let cell = collectionView.cellForItem(at: foundIndexPath) as? UICollectionViewListCell,
                  let id = dataSource.itemIdentifier(for: foundIndexPath),
                  let item = self.dict[id] else { return }

            cell.configureItem(
                item,
                isActive: onItemsIds.contains(id),
                animated: animated,
                isActiveDidChangeHandler: { [weak self] in
                    self?.filter($0, didChangeValue: $1)
                }
            )
        }
    }

    
    func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // Configurazione per una lista con celle singole
            var config = UICollectionLayoutListConfiguration(appearance: .grouped)
            config.showsSeparators = true // Aggiungi separatori tra le celle
            config.backgroundColor = .noiSecondaryBackgroundColor
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            return section
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.allowsSelection = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: UICollectionViewListCell Configure Helper

private extension UICollectionViewListCell {

    func configureItem(
        _ item: ArticleTag,
        isActive: Bool,
        animated: Bool,
        isActiveDidChangeHandler: @escaping (ArticleTag, Bool) -> Void
    ) {
        for accessory in accessories {
            guard
                case let .customView(customView) = accessory.accessoryType,
                let `switch` = customView as? UISwitch
            else { continue }

            `switch`.setOn(isActive, animated: animated)
        }
    }

}

private enum Section: Int {
    case main
}
