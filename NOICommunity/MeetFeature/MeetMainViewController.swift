//
//  MeetMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit

// MARK: - MeetViewModel

final class MeetViewModel {
    struct Entry: Hashable, CaseIterable {
        static var allCases: [Entry] = [
            .companies,
            .startups,
            .university,
            .researchInstitution,
            .institutionalSupport,
            .laboratories,
            .teamNOI
        ]

        let localizedTitle: String
        let url: URL

        static let companies = Self(
            localizedTitle: .localized("meet_item_companies"),
            url: .companies
        )
        static let startups = Self(
            localizedTitle: .localized("meet_item_startups"),
            url: .startups
        )
        static let university = Self(
            localizedTitle: .localized("meet_item_university"),
            url: .university
        )
        static let researchInstitution = Self(
            localizedTitle: .localized("meet_item_research"),
            url: .research
        )
        static let institutionalSupport = Self(
            localizedTitle: .localized("meet_item_institutions"),
            url: .institutions
        )
        static let laboratories = Self(
            localizedTitle: .localized("meet_item_lab"),
            url: .lab
        )
        static let teamNOI = Self(
            localizedTitle: .localized("meet_item_team"),
            url: .aboutUs
        )
    }
}

// MARK: - MeetMainViewController

final class MeetMainViewController: UICollectionViewController {

    typealias Entry = MeetViewModel.Entry
    private var dataSource: UICollectionViewDiffableDataSource<Section, Entry>! = nil

    var didSelectHandler: ((Entry) -> Void)?

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

        configureDataSource()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Private APIs

private extension MeetMainViewController {
    enum Section: Hashable {
        case main
    }

    static func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .noiSecondaryBackgroundColor
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Entry> { cell, _, entry in
            var contentConfiguration = UIListContentConfiguration.noiCell()
            contentConfiguration.text = entry.localizedTitle
            cell.contentConfiguration = contentConfiguration

            cell.backgroundConfiguration = .noiListPlainCell(for: cell)

            cell.accessories = [.noiDisclosureIndicator()]
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

// MARK: UICollectionViewDelegate

extension MeetMainViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedEntry = dataSource.itemIdentifier(for: indexPath)!
        didSelectHandler?(selectedEntry)
    }
}
