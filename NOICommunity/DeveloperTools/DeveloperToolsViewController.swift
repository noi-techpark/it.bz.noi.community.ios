// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  DeveloperToolsViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/08/24.
//

import UIKit
import Combine

class DeveloperToolsViewController: UICollectionViewController {

    private var viewModel: DeveloperToolsViewModel!
    private var subscriptions: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, DeveloperToolsOption>! = nil

    init(viewModel: DeveloperToolsViewModel) {
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

        configureCollectionView()
        configureDataSource()
        configureBindings()
    }

}

// MARK: Private APIs
extension DeveloperToolsViewController {

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let selectedOption = dataSource.itemIdentifier(for: indexPath)
        else { return }

        viewModel.perform(option: selectedOption)
    }
}

// MARK: Private APIs

private extension DeveloperToolsViewController {

    enum Section: Hashable {
        case main
    }

    func configureLayout() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .noiSecondaryBackgroundColor
        if #available(iOS 14.5, *) {
            config.itemSeparatorHandler = { [weak collectionView] indexPath, sectionSeparatorConfiguration in
                guard let collectionView
                else { return sectionSeparatorConfiguration }

                var configuration = sectionSeparatorConfiguration
                if collectionView.isLastIndexPathInItsSection(indexPath) {
                    configuration.bottomSeparatorVisibility = .hidden
                }
                return configuration
            }
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <UICollectionViewListCell, DeveloperToolsOption> { cell, _, option in
            var contentConfiguration = UIListContentConfiguration.noiCell()
            contentConfiguration.text = option.rawValue
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
        
        setInitialSnapshot()
    }

    func configureBindings() {
        viewModel.$options
            .sink { [weak self] newOptions in
                self?.updateUI(options: newOptions)
            }
            .store(in: &subscriptions)
    }

    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        configureLayout()
    }

    func updateUI(options: [DeveloperToolsOption]) {
        let isOnScreen = viewIfLoaded?.window != nil
        updateUI(options: options, animated: isOnScreen)
    }

    func updateUI(options: [DeveloperToolsOption], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DeveloperToolsOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(options, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func setInitialSnapshot() {
        let snapshot = NSDiffableDataSourceSnapshot<Section, DeveloperToolsOption>()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

