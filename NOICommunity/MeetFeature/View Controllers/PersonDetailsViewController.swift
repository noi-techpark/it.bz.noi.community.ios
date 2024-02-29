// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsDetailViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 26/05/22.
//

import UIKit
import Combine
import PeopleClient
import SwiftUI

// MARK: - PersonDetailsViewController

final class PersonDetailsViewController: UIViewController {
    
    let person: Person
    
    let company: Company?
    
    var composeMailActionPublisher: AnyPublisher<Void, Never>! {
        loadViewIfNeeded()
        
        return mailButton
            .publisher(for: .primaryActionTriggered)
            .eraseToAnyPublisher()
    }
    
    var callActionPublisher: AnyPublisher<Void, Never>! {
        loadViewIfNeeded()
        
        return phoneButton
            .publisher(for: .primaryActionTriggered)
            .eraseToAnyPublisher()
    }
    
    var findActionPublisher: AnyPublisher<Void, Never>! {
        loadViewIfNeeded()
        
        return findButton
            .publisher(for: .primaryActionTriggered)
            .eraseToAnyPublisher()
    }
    
    @IBOutlet private var footerView: UIView!
    
    @IBOutlet private var mailButton: UIButton! {
        didSet {
            mailButton
                .configureAsSecondaryActionButton(numberOfLines: 1)
                .withTitle(.localized("btn_mail"))
            
            mailButton.isHidden = person.primaryEmail == nil
        }
    }
    
    @IBOutlet private var phoneButton: UIButton! {
        didSet {
            phoneButton
                .configureAsSecondaryActionButton(numberOfLines: 1)
                .withTitle(.localized("btn_call"))
            
            phoneButton.isHidden = company?.phoneNumber == nil
        }
    }
    
    @IBOutlet private var findButton: UIButton! {
        didSet {
            findButton
                .configureAsSecondaryActionButton(numberOfLines: 1)
                .withTitle(.localized("btn_find"))
            
            findButton.isHidden = !FeatureFlag.displayFindCTA || company?.fullAddress == nil
        }
    }
    
    private lazy var contentVC = CollectionViewController(
        person: person,
        company: company
    )
    
    init(person: Person, company: Company?) {
        self.person = person
        self.company = company
        
        super.init(nibName: "\(PersonDetailsViewController.self)", bundle: nil)
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
        
        embedChild(contentVC)
        view.bringSubviewToFront(footerView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionView = contentVC.collectionView!
        var contentInset = collectionView.contentInset
        if footerView.superview != nil {
            contentInset.bottom = footerView.frame.height - view.safeAreaInsets.bottom
        }
        collectionView.contentInset = contentInset
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
}

// MARK: - PersonDetailsViewController.CollectionViewController

private extension PersonDetailsViewController {
    
    final class CollectionViewController: UICollectionViewController {
        
        let person: Person
        
        let company: Company?
        
        private var dataSource: UICollectionViewDiffableDataSource<Section, Info>! = nil
        
        private var subscriptions: Set<AnyCancellable> = []
        
        private var selectedInfos: Set<Info> = []
        
        private var selectedInfosTimers: [Info: AnyCancellable] = [:]
        
        init(person: Person, company: Company?) {
            self.person = person
            self.company = company
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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            configureCollectionView()
            configureDataSource()
        }
        
    }
    
}

// MARK: Private APIs
private extension FeatureFlag {

    static let displayAddress = false
    static let displayFindCTA = false
}

private extension PersonDetailsViewController.CollectionViewController {
    
    enum Section: Hashable {
        case main
    }
    
    enum Info: String, CaseIterable {
        case email
        case phoneNumber
        case address
        
        var localizedString: String {
            switch self {
            case .email:
                return .localized("label_email")
            case .phoneNumber:
                return .localized("label_phone")
            case .address:
                return .localized("label_address")
            }
        }

        static var allCases: [PersonDetailsViewController.CollectionViewController.Info] {
            var result: [PersonDetailsViewController.CollectionViewController.Info] = [
                email,
                phoneNumber,
                address
            ]
            if !FeatureFlag.displayAddress {
                result.removeAll { $0 == .address }
            }
            return result
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.backgroundColor = .noiTertiaryBackgroundColor
        config.headerMode = .supplementary
        config.showsSeparators = false
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.collectionViewLayout = createLayout()
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Info> { [person, company] cell, _, info in
            var contentConfiguration = UIListContentConfiguration.noiDetailsSubtitleCell()
            
            contentConfiguration.text = info.localizedString
            switch info {
            case .email:
                contentConfiguration.secondaryText = person.primaryEmail
            case .phoneNumber:
                contentConfiguration.secondaryText = company?.phoneNumber
            case .address:
                contentConfiguration.secondaryText = company?.fullAddress?
                    .components(separatedBy: .newlines)
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
            }
            
            cell.contentConfiguration = contentConfiguration
            
            cell.backgroundConfiguration = .noiListPlainCell(for: cell)
            
            let isSelected = self.selectedInfos.contains(info)
            
            if case let .customView(view) = cell.accessories.last?.accessoryType,
               let imageView = view as? UIImageView {
                let image: UIImage?
                
                if isSelected {
                    image = UIImage(named: "ic_copied")
                } else {
                    image = UIImage(named: "ic_copy")
                }
                
                imageView.setImage(image, animated: true)
            } else  {
                if isSelected {
                    cell.accessories = [.noiCopiedIndicator()]
                } else {
                    cell.accessories = [.noiCopyIndicator()]
                }
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
            ) { [person, company] cell, kind, indexPath in
                var config = PersonDetailHeaderContentConfiguration()
                
                if company?.tags.contains(.company) == true {
                    config.image = #imageLiteral(resourceName: "Companies")
                } else if company?.tags.contains(.startup) == true {
                    config.image = #imageLiteral(resourceName: "Start-up")
                } else if company?.tags.contains(.researchInstitution) == true {
                    config.image = #imageLiteral(resourceName: "Institutions")
                } else {
                    config.image = nil
                }
                
                var components = PersonNameComponents()
                components.familyName = person.lastname
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                components.givenName = person.firstname
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                config.fullname = PersonNameComponentsFormatter.localizedString(
                    from: components,
                    style: .default
                )
                config.company = company?.name
                config.avatarText = PersonNameComponentsFormatter.localizedString(
                    from: components,
                    style: .abbreviated
                )
                
                cell.contentConfiguration = config
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
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Info>()
        snapshot.appendSections([.main])
        let diplayItems = {
            var result = Info.allCases
            if person.primaryEmail == nil {
                result.removeAll { $0 == .email }
            }
            if company?.phoneNumber == nil {
                result.removeAll { $0 == .phoneNumber }
            }
            if company?.fullAddress == nil {
                result.removeAll { $0 == .address }
            }
            return result
        }()
        snapshot.appendItems(diplayItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

// MARK: UICollectionViewDelegate

extension PersonDetailsViewController.CollectionViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        let selectedInfo = dataSource.itemIdentifier(for: indexPath)!
        selectedInfos.insert(selectedInfo)
        
        switch selectedInfo {
        case .email:
            UIPasteboard.general.string = person.primaryEmail!
        case .phoneNumber:
            UIPasteboard.general.string = company!.phoneNumber!
        case .address:
            UIPasteboard.general.string = company!.fullAddress
        }
        
        var snapshot = dataSource.snapshot()
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems([selectedInfo])
        } else {
            snapshot.reloadItems([selectedInfo])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
        
        let deselectPublisher: AnyPublisher<Void, Never> = Future { promise in
            DispatchQueue.main.asyncAfter(deadline:.now() + 1) {
                promise(Result.success(()))
            }
        }
            .eraseToAnyPublisher()
        let cancellable = deselectPublisher.sink { [selectedInfo, weak self] in
            guard let self = self
            else { return }
            
            self.selectedInfos.remove(selectedInfo)
            var snapshot = self.dataSource.snapshot()
            if #available(iOS 15.0, *) {
                snapshot.reconfigureItems([selectedInfo])
            } else {
                snapshot.reloadItems([selectedInfo])
            }
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        selectedInfosTimers[selectedInfo] = cancellable
    }
    
}
