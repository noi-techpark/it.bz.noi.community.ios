//
//  EatMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/09/21.
//

import UIKit

// MARK: - EatViewModel

final class EatViewModel {
    struct Entry: Hashable, CaseIterable {
        static var allCases: [Entry] = [
            .noiCommunityBar,
            .noisteria,
            .alumix
        ]

        let name: String
        let openeningText: String
        let menuURL: URL
        let imagesNames: [String]

        static let noisteria = Self(
            name: .localized("noisteria_name"),
            openeningText: .localized("noisteria_openings"),
            menuURL: .noisteriaMenu,
            imagesNames: [
                "noisteria_außen",
                "noisteria_bar",
                "noisteria_innen",
                "noisteria_innen2",
                "noisteria_salad"
            ]
        )
        static let noiCommunityBar = Self(
            name: .localized("community_bar_name"),
            openeningText: .localized("community_bar_openings"),
            menuURL: .noiBarMenu,
            imagesNames:[
                "rockin beets_asparagi_lasagne",
                "rockin beets_meal prep",
                "rockin beets_meals",
                "rockin beets_obstmarkt"
            ]
        )
        static let alumix = Self(
            name: .localized("alumix_name"),
            openeningText: .localized("alumix_openings"),
            menuURL: .alumixMenu,
            imagesNames: [
                "alumix",
                "alumix_frittura",
                "alumix_pizza",
                "alumix_sala-garden"
            ]

        )
    }
}

// MARK: - EatMainViewController

final class EatMainViewController: UICollectionViewController {

    typealias Entry = EatViewModel.Entry
    private var dataSource: UICollectionViewDiffableDataSource<Section, Entry>! = nil

    var showMenuHandler: ((Entry) -> Void)?

    init() {
        super.init(collectionViewLayout: Self.createLayout())
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
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Private APIs

private extension EatMainViewController {
    enum Section: Hashable {
        case main
    }

    static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let estimatedHeight = NSCollectionLayoutDimension.estimated(300)
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
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 50
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 20,
                leading: 17,
                bottom: 50,
                trailing: 17
            )
            return section
        }
        return layout
    }

    func configureCollectionView() {
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Entry> { cell, _, entry in
            var contentConfiguration = PlaceCardContentConfiguration()
            contentConfiguration.text = entry.name
            contentConfiguration.secondaryText = entry.openeningText
            contentConfiguration.actionText = .localized("btn_menu")
            contentConfiguration.actionHandler = { [weak self] in
                self?.showMenuHandler?(entry)
            }
            contentConfiguration.imagesNames = entry.imagesNames
            cell.contentConfiguration = contentConfiguration
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
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

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Entry.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
