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
        configureBindings()
        
        collectionView.refreshControl = UIRefreshControl()
        viewModel.fetchUserInfo()
    }
    
}

// MARK: Private APIs

private extension MyAccountViewController {
    
    enum Section: Hashable {
        case main
        case logout
    }
    
    func configureBindings() {
        viewModel.$userInfoIsLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak collectionView] in
                collectionView?.refreshControl?.isLoading = $0
            }
            .store(in: &subscriptions)
        
        viewModel.$userInfoResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                guard let self = self
                else { return }
                
                self.userInfo = userInfo
                
                var snapshot = self.dataSource.snapshot()
                
                switch (userInfo?.name, userInfo?.email) {
                case (nil, nil):
                    snapshot.deleteSections([.main])
                case (nil, let email?):
                    snapshot.insertSections([.main], beforeSection: .logout)
                    snapshot.appendItems([.email], toSection: .main)
                case (let name?, nil):
                    snapshot.insertSections([.main], beforeSection: .logout)
                    snapshot.appendItems([.fullname], toSection: .main)
                case (let name?, let email?):
                    snapshot.insertSections([.main], beforeSection: .logout)
                    snapshot.appendItems([.fullname], toSection: .main)
                    snapshot.appendItems([.email], toSection: .main)
                }
                
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
            .dropFirst()
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
                contentConfiguration = UIListContentConfiguration.noiCell()
                contentConfiguration.text = self.userInfo!.name
            case .email:
                contentConfiguration = UIListContentConfiguration.noiCell()
                contentConfiguration.text = self.userInfo!.email
            case .logoutAction:
                contentConfiguration = .noiDestructiveCell()
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        snapshot.appendSections([.logout])
        snapshot.appendItems([.logoutAction])
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
