//
//  MoreMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/09/21.
//

import UIKit

// MARK: - MoreMainViewController

final class MoreMainViewController: UICollectionViewController {

    typealias Entry = MoreViewModel.Entry
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Private APIs

private extension MoreMainViewController {
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    enum Section: Hashable {
        case main
    }

    static func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .noiSecondaryBackgroundColor
        config.footerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <UICollectionViewListCell, Entry> { cell, _, entry in
            var contentConfiguration = UIListContentConfiguration.noiCell()
            contentConfiguration.text = entry.localizedTitle
            cell.contentConfiguration = contentConfiguration

            cell.backgroundConfiguration = .noiListPlainCell(for: cell)

            cell.accessories = [.noiDisclosureIndicator()]
        }

        let footerRegistration = UICollectionView.SupplementaryRegistration
        <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) { footerView, _, _ in
            var contentConfiguration = VersionContentConfiguration()
            if
                let infoDictionary = Bundle.main.infoDictionary,
                let version = infoDictionary["CFBundleShortVersionString"] as? String,
                let buildNumber = infoDictionary["CFBundleVersion"] as? String {
                contentConfiguration.version = "\(version) (\(buildNumber))"
            }
            footerView.contentConfiguration = contentConfiguration
            footerView.backgroundConfiguration = UIBackgroundConfiguration.clear()
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
            case UICollectionView.elementKindSectionFooter:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: footerRegistration,
                    for: indexPath
                )
            default:
                return nil
            }
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Entry.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UICollectionViewDelegate

extension MoreMainViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedEntry = dataSource.itemIdentifier(for: indexPath)!
        didSelectHandler?(selectedEntry)
    }
}
