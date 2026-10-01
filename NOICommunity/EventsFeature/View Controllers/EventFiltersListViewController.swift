// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventFiltersListViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/03/22.
//

import UIKit
import EventTagsClient

class EventFiltersListViewController: UICollectionViewController {

    var items: [Tag] {
        didSet {
            guard items != oldValue
            else { return }

            guard isViewLoaded
            else { return }

            let animated = view.window != nil
            updateUI(items: items, animated: animated)
        }
    }

    var onItemsIds: Set<Tag.Id> = [] {
        didSet {
            guard onItemsIds != oldValue
            else { return }

            guard isViewLoaded
            else { return }

            updateUI(oldOnItemsIds: oldValue, newOnItemsIds: onItemsIds)
        }
    }

    private var dict: [Tag.Id: Tag]

    var filterValueDidChangeHandler: ((Tag, Bool) -> Void)!

    private var dataSource: UICollectionViewDiffableDataSource<Section, FilterItemId>! = nil

    init(items: [Tag], onItemsIds: Set<Tag.Id> = []) {
        self.items = items
        self.onItemsIds = onItemsIds
        self.dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
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

        configureCollectionView()
        configureDataSource()
    }

}

// MARK: Private APIs

private extension EventFiltersListViewController {

    enum Section: Int {
        case customTagging
        case technologyFields
    }

    /// A single `Tag` can belong to more than one category (e.g. a tag can be
    /// both a custom tag and a technology field), so it may need to be shown
    /// as a row in more than one section. The diffable data source requires
    /// globally unique item identifiers, so the section is part of the identity.
    struct FilterItemId: Hashable {
        let section: Section
        let tagId: Tag.Id
    }

    func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.headerMode = .supplementary
        config.backgroundColor = .noiSecondaryBackgroundColor
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func filter(_ item: Tag, didChangeValue isOn: Bool) {
        filterValueDidChangeHandler(item, isOn)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, FilterItemId> { cell, _, itemId in
                let item = self.dict[itemId.tagId]!

                var contentConfiguration = UIListContentConfiguration.noiCell2()
                contentConfiguration.text = localizedValue(
                    from: item.tagName,
                    defaultValue: item.id
                )
                cell.contentConfiguration = contentConfiguration

                cell.backgroundConfiguration = .noiListPlainCell(for: cell)

                let `switch` = UISwitch()
                `switch`.isOn = self.onItemsIds.contains(itemId.tagId)
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

        let headerRegistration = UICollectionView
            .SupplementaryRegistration<UICollectionViewCell>(
                elementKind: UICollectionView.elementKindSectionHeader
            ) { cell, kind, indexPath in
                var config = UIListContentConfiguration.noiGroupedHeader()

                switch self.dataSource.snapshot().sectionIdentifiers[indexPath.section] {
                case .customTagging:
                    config.text = .localized("filter_by_type")
                case .technologyFields:
                    config.text = .localized("filter_by_sector")
                }

                cell.contentConfiguration = config
            }

        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, itemId in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemId
            )
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }

        // initial data
        updateUI(items: items, animated: false)
    }

    func updateUI(items: [Tag], animated: Bool) {
        dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, FilterItemId>()

        let customTaggingFilters = items.filter(\.isCustomTagging)
        if !customTaggingFilters.isEmpty {
            newSnapshot.appendSections([.customTagging])
            newSnapshot.appendItems(
                customTaggingFilters.map { FilterItemId(section: .customTagging, tagId: $0.id) },
                toSection: .customTagging
            )
        }

        let technologyFieldsFilters = items.filter(\.isTechnologyFields)
        if !technologyFieldsFilters.isEmpty {
            newSnapshot.appendSections([.technologyFields])
            newSnapshot.appendItems(
                technologyFieldsFilters.map { FilterItemId(section: .technologyFields, tagId: $0.id) },
                toSection: .technologyFields
            )
        }

        dataSource.apply(newSnapshot, animatingDifferences: animated)
    }

    func updateUI(
        oldOnItemsIds: Set<Tag.Id>,
        newOnItemsIds: Set<Tag.Id>
    ) {
        let itemsWithChangedIsOn = Array(oldOnItemsIds.union(newOnItemsIds))
        reconfigureFiltersWithIds(itemsWithChangedIsOn, animated: true)
    }

    func reconfigureFiltersWithIds(
        _ tagIds: [Tag.Id],
        animated: Bool
    ) {
        let itemIds = tagIds.flatMap { tagId in
            [Section.customTagging, Section.technologyFields].map {
                FilterItemId(section: $0, tagId: tagId)
            }
        }
        let reconfigureIndexPaths = itemIds.compactMap {
            dataSource.indexPath(for: $0)
        }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let foundIndexPaths = visibleIndexPaths
            .filter { reconfigureIndexPaths.contains($0) }

        for foundIndexPath in foundIndexPaths {
            guard let cell = collectionView
                    .cellForItem(at: foundIndexPath) as? UICollectionViewListCell
            else { return }

            guard let itemId = dataSource.itemIdentifier(for: foundIndexPath)
            else { return }

            let item = self.dict[itemId.tagId]!

            cell.configureItem(
                item,
                isActive: onItemsIds.contains(itemId.tagId),
                animated: animated,
                isActiveDidChangeHandler: { [weak self] in
                    self?.filter($0, didChangeValue: $1)
                }
            )
        }
    }

    func configureCollectionView() {
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.allowsSelection = false
        collectionView.collectionViewLayout = createLayout()
        collectionView.contentInset = .init(
            top: 24,
            left: 0,
            bottom: 0,
            right: 0
        )
    }

}

// MARK: UICollectionViewListCell Configure Helper

private extension UICollectionViewListCell {

    func configureItem(
        _ item: Tag,
        isActive: Bool,
        animated: Bool,
        isActiveDidChangeHandler: @escaping (Tag, Bool) -> Void
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

// MARK: UICollectionViewDelegate

extension EventFiltersListViewController {

}
