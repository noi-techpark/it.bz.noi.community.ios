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
            url: .urlCompanies
        )
        static let startups = Self(
            localizedTitle: .localized("meet_item_startups"),
            url: .urlStartups
        )
        static let university = Self(
            localizedTitle: .localized("meet_item_university"),
            url: .urlUniversity
        )
        static let researchInstitution = Self(
            localizedTitle: .localized("meet_item_research"),
            url: .urlResearch
        )
        static let institutionalSupport = Self(
            localizedTitle: .localized("meet_item_support"),
            url: .urlInstitutions
        )
        static let laboratories = Self(
            localizedTitle: .localized("meet_item_lab"),
            url: .urlLab
        )
        static let teamNOI = Self(
            localizedTitle: .localized("meet_item_team"),
            url: .urlAboutUs
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

        configureDataSource()
    }
}

// MARK: Private APIs

private extension MeetMainViewController {
    enum Section: Hashable {
        case main
    }

    static func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .secondaryBackgroundColor
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Entry> { cell, _, entry in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = entry.localizedTitle
            cell.contentConfiguration = contentConfiguration

            cell.accessories = [.disclosureIndicator()]
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
