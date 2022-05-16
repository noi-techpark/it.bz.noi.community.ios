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

final class MyAccountViewController: UICollectionViewController {
    
    enum Entry: Int {
        case fullname
        case email
        case logoutAction
    }
    
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
        
        configureDataSource()
        configureBindings()
        
        viewModel.fetchUserInfo()
    }
    
}

// MARK: Private APIs

private extension MyAccountViewController {
    
    enum Section: Hashable {
        case main
        case logout
    }
    
    func makeSnapshot(
        fromUserInfo userInfo: UserInfo? = nil,
        oldUserInfo: UserInfo? = nil
    ) -> NSDiffableDataSourceSnapshot<Section, Entry> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        snapshot.appendSections([.logout])
        snapshot.appendItems([.logoutAction])
        switch (userInfo?.name, userInfo?.email) {
        case (nil, nil):
            snapshot.deleteSections([.main])
        case (nil, _?):
            snapshot.insertSections([.main], beforeSection: .logout)
            snapshot.appendItems([.email], toSection: .main)
        case (_?, nil):
            snapshot.insertSections([.main], beforeSection: .logout)
            snapshot.appendItems([.fullname], toSection: .main)
        case (_?, _?):
            snapshot.insertSections([.main], beforeSection: .logout)
            snapshot.appendItems([.fullname], toSection: .main)
            snapshot.appendItems([.email], toSection: .main)
        }
        var reconfigureItems: [Entry] = []
        if oldUserInfo?.name != userInfo?.name {
            reconfigureItems.append(.fullname)
        }
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
        return snapshot
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
                let snapshot = self.makeSnapshot(
                    fromUserInfo: userInfo,
                    oldUserInfo: oldUserInfo
                )
                self.dataSource.apply(snapshot, animatingDifferences: true)
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
        config.backgroundColor = .noiSecondaryBackgroundColor
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <UICollectionViewListCell, Entry> { cell, _, entry in
            var contentConfiguration: UIListContentConfiguration
            
            switch entry {
            case .fullname:
                contentConfiguration = UIListContentConfiguration.noiValueCell()
                contentConfiguration.text = .localized("label_name")
                contentConfiguration.secondaryText = self.viewModel.userInfoResult!.name
            case .email:
                contentConfiguration = UIListContentConfiguration.noiValueCell()
                contentConfiguration.text = .localized("label_email")
                contentConfiguration.secondaryText = self.viewModel.userInfoResult!.email
            case .logoutAction:
                contentConfiguration = .noiCell()
                contentConfiguration.text = .localized("btn_logout")
            }
            
            cell.contentConfiguration = contentConfiguration
            
            cell.backgroundConfiguration = .noiListPlainCell(for: cell)
            
            switch entry {
            case .fullname,
                    .email:
                cell.accessories = []
            case .logoutAction:
                cell.accessories = [.noiLogoutIndicator()]
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
        
        // initial data
        let snapshot = makeSnapshot(
            fromUserInfo: viewModel.userInfoResult,
            oldUserInfo: viewModel.userInfoResult
        )
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UICollectionViewDelegate

extension MyAccountViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        let entry = dataSource.itemIdentifier(for: indexPath)!
        switch entry {
        case .fullname,
                .email:
            return false
        case .logoutAction:
            return true
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let entry = dataSource.itemIdentifier(for: indexPath)!
        switch entry {
        case .fullname,
                .email:
            return false
        case .logoutAction:
            return true
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedEntry = dataSource.itemIdentifier(for: indexPath)!
        switch selectedEntry {
        case .fullname,
                .email:
            break
        case .logoutAction:
            viewModel.logout()
        }
    }
    
}
