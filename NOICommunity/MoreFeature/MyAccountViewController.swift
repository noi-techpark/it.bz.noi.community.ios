// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MyAccountViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 29/04/22.
//

import UIKit
import Combine
import AuthClient

// MARK: - MyAccountViewController

final class MyAccountViewController: UIViewController {
    
    let viewModel: MyAccountViewModel
    
    private lazy var contentVC = CollectionViewController(viewModel: viewModel)
    
    private var subscriptions: Set<AnyCancellable> = []
    
    @IBOutlet private var footerView: UIView!
    
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            logoutButton
                .configureAsCalloutFooterAction()
                .withTitle(.localized("btn_logout"))
        }
    }
    
    @IBOutlet private var deleteAccountButton: UIButton! {
        didSet {
            deleteAccountButton
                .configureAsCalloutFooterAction()
                .withTitle(.localized("btn_delete_account"))
        }
    }
    
    init(viewModel: MyAccountViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: "\(MyAccountViewController.self)", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
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
        
        configureBindings()
        embedChild(contentVC)
        view.bringSubviewToFront(footerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionView = contentVC.collectionView!
        var contentInset = collectionView.contentInset
        contentInset.bottom = footerView.frame.height
        collectionView.contentInset = contentInset
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}

// MARK: Private APIs

private extension MyAccountViewController {
    
    func configureBindings() {
        logoutButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.logout()
            }
            .store(in: &subscriptions)
        
        deleteAccountButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.requestAccountDeletion()
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: - MyAccountViewController.CollectionViewController

private extension MyAccountViewController {
    
    final class CollectionViewController: UICollectionViewController {
        
        private var dataSource: UICollectionViewDiffableDataSource<Section, Entry>! = nil
        
        let viewModel: MyAccountViewModel
        
        private var subscriptions: Set<AnyCancellable> = []
        
        private var userInfo: UserInfo?
        
        init(viewModel: MyAccountViewModel) {
            self.viewModel = viewModel
            
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
            
            collectionView.refreshControl = .init()
            collectionView.allowsSelection = false
            
            configureDataSource()
            configureBindings()
            
            viewModel.fetchUserInfo()
        }
        
    }
}

// MARK: Private APIs

private extension MyAccountViewController.CollectionViewController {
    
    enum Section: Hashable {
        case main
    }
    
    enum Entry: Int {
        case email
    }
    
    static func makeSnapshot(
        fromUserInfo userInfo: UserInfo? = nil,
        oldUserInfo: UserInfo? = nil
    ) -> NSDiffableDataSourceSnapshot<Section, Entry> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        
        switch (userInfo?.name, userInfo?.email) {
        case (nil, nil):
            break
        case (_?, nil):
            snapshot.appendSections([.main])
        case (_, _?):
            snapshot.appendSections([.main])
            snapshot.appendItems([.email], toSection: .main)
        }
        
        if oldUserInfo?.fullname != userInfo?.fullname {
            snapshot.reloadSections([.main])
        } else {
            var reconfigureItems: [Entry] = []
            
            if oldUserInfo?.email != userInfo?.email {
                reconfigureItems.append(.email)
            }
            
            if !reconfigureItems.isEmpty {
                if #available(iOS 15.0, *) {
                    snapshot.reconfigureItems(reconfigureItems)
                } else {
                    snapshot.reloadItems(reconfigureItems)
                }
            }
        }
        
        return snapshot
    }
    
    func update(
        oldUserInfo: UserInfo?,
        newUserInfo: UserInfo?,
        animated: Bool
    ) {
        let snapshot = Self.makeSnapshot(
            fromUserInfo: userInfo,
            oldUserInfo: oldUserInfo
        )
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func configureBindings() {
        collectionView.refreshControl?
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in
                viewModel?.fetchUserInfo(refresh: true)
            }
            .store(in: &subscriptions)
        
        viewModel.$userInfoIsLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak collectionView] isLoading in
                collectionView?.refreshControl?.isLoading = isLoading
            }
            .store(in: &subscriptions)
        
        viewModel.$userInfoResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                guard let self = self
                else { return }
                
                let oldUserInfo = self.userInfo
                self.userInfo = userInfo
                self.update(
                    oldUserInfo: oldUserInfo,
                    newUserInfo: userInfo,
                    animated: self.viewIfLoaded?.window != nil
                )
            }
            .store(in: &subscriptions)
        
        viewModel.$logoutResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak collectionView] _ in
                guard let collectionView = collectionView
                else { return }
                
                if let selections = collectionView.indexPathsForSelectedItems {
                    selections.forEach {
                        collectionView.deselectItem(at: $0, animated: true)
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error
                else { return }
                
                switch error {
                case AuthError.userCanceledAuthorizationFlow:
                    if let selections = self?.collectionView.indexPathsForSelectedItems {
                        selections.forEach {
                            self?.collectionView.deselectItem(
                                at: $0,
                                animated: true
                            )
                        }
                    }
                default:
                    self?.showError(error)
                }
            }
            .store(in: &subscriptions)
    }
    
    static func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.backgroundColor = .noiTertiaryBackgroundColor
        config.headerMode = .supplementary
        config.showsSeparators = false
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <UICollectionViewListCell, Entry> { cell, _, entry in
            switch entry {
            case .email:
                var contentConfiguration = UIListContentConfiguration.noiDetailsSubtitleCell()
                
                contentConfiguration.text = .localized("label_email")
                contentConfiguration.secondaryText = self.userInfo!.email
                cell.contentConfiguration = contentConfiguration
                
                cell.backgroundConfiguration = .noiListPlainCell(for: cell)
                
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
        
        let headerRegistration = UICollectionView
            .SupplementaryRegistration<UICollectionViewCell>(
                elementKind: UICollectionView.elementKindSectionHeader
            ) { cell, kind, indexPath in
                var contentConfiguration = PersonDetailHeaderContentConfiguration()
                
                let userInfo = self.viewModel.userInfoResult!
                
                contentConfiguration.image = #imageLiteral(resourceName: "General-Profile")
                contentConfiguration.company = nil
                
                var components = PersonNameComponents()
                components.familyName = userInfo.familyName?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                components.givenName = userInfo.givenName?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                contentConfiguration.fullname = PersonNameComponentsFormatter.localizedString(
                    from: components,
                    style: .default
                )
                contentConfiguration.avatarText = PersonNameComponentsFormatter.localizedString(
                    from: components,
                    style: .abbreviated
                )
                
                cell.contentConfiguration = contentConfiguration
            }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration,
                    for: indexPath
                )
            default:
                return nil
            }
        }
        
        // initial data
        update(
            oldUserInfo: userInfo,
            newUserInfo: viewModel.userInfoResult,
            animated: false
        )
    }
}

// MARK: - UserInfo Helpers

private extension UserInfo {
    
    var fullname: String? {
        if let name = name {
            return name
        }
        
        if givenName != nil || familyName != nil {
            return [givenName, familyName]
                .compactMap { $0 }
                .joined(separator: " ")
        }
        
        return nil
    }
    
}

// MARK: - UIButton Helpers

private extension UIButton {
    
    func configureAsCalloutFooterAction() -> UIButton {
        self
            .withDynamicType(numberOfLines: 1)
            .withFont(.NOI.dynamic.caption1Semibold)
            .withTitleColor(.noiSecondaryColor)
            .withTitleColor(
                .noiSecondaryColor.withAlphaComponent(0.6),
                state: .highlighted
            )
            .withTintColor(.noiSecondaryColor)
    }
    
}
