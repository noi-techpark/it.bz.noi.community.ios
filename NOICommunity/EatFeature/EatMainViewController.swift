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
            .noisteria,
            .noiCommunityBar,
            .alumix
        ]

        let name: String
        let openeningText: String
        let menuUrl: URL
        let imageUrls: [URL]

        static let noisteria = Self(
            name: "Noisteria",
            openeningText: .localized("noisteria_openings"),
            menuUrl: .noisteriaMenu,
            imageUrls: [
                .noisteriaaußenImageURL,
                .noisteriaBarImageURL,
                .noisteriaInnenImageURL,
                .noisteriaInnen2ImageURL,
                .noisteriaSaladImageURL
            ]
        )
        static let noiCommunityBar = Self(
            name: "NOI Community Bar",
            openeningText: .localized("community_bar_openings"),
            menuUrl: .noiBarMenu,
            imageUrls:[
                .rockinBeetsAsparagiLasagneImageURL,
                .rockinBeetsMealPrepImageURL,
                .rockinBeetsMealsImageURL,
                .rockinBeetsObstmarktImageURL
            ]
        )
        static let alumix = Self(
            name: "Alumix",
            openeningText: .localized("alumix_openings"),
            menuUrl: .alumixMenu,
            imageUrls: [
                .alumixImageURL,
                .alumixFritturaImageURL,
                .alumixPizzaImageURL,
                .alumixSalagardenImageURL
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
        collectionView.backgroundColor = .secondaryBackgroundColor
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
            contentConfiguration.imagesURLs = entry.imageUrls
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
