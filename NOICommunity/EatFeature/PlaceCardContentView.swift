//
//  PlaceCardContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/09/21.
//

import UIKit

// MARK: - PlaceCardContentView

class PlaceCardContentView: UIView, UIContentView {
    @IBOutlet var containerView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var detailTextLabel: UILabel!
    @IBOutlet var actionButton: UIButton! {
        didSet {
            actionButton
                .configureAsPrimaryActionButton()
        }
    }
    @IBOutlet var collectionView: UICollectionView!
    
    private var currentConfiguration: PlaceCardContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? PlaceCardContentConfiguration
            else { return }
            
            apply(configuration: newConfiguration)
        }
    }
    
    private var actionHandler: (() -> Void)?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>! = nil
    
    init(configuration: PlaceCardContentConfiguration) {
        super.init(frame: .zero)
        
        configureViewHierarchy()
        configureCollectionView()
        configureDataSource()
        
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}

// MARK: Private APIs

private extension PlaceCardContentView {
    enum Section {
        case main
    }
    
    func configureViewHierarchy() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(PlaceCardContentView.self)",
            owner: self,
            options: nil
        )
        
        embedSubview(containerView)
    }
    
    private func apply(configuration: PlaceCardContentConfiguration) {
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Update text label
        textLabel?.setText(
            (configuration.attributedText, configuration.text),
            textProperties: configuration.textProprieties
        )
        
        // Update detail text label
        detailTextLabel?.setText(
            (configuration.secondaryAttributedText, configuration.secondaryText),
            textProperties: configuration.secondaryTextProprieties
        )
        
        // Update action button
        actionButton.titleLabel?.setText(
            (configuration.actionAttributedText, configuration.actionText),
            textProperties: configuration.actionTextProprieties
        )
        actionHandler = configuration.actionHandler
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(configuration.imagesNames)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @IBAction private func triggerAction(sender: Any?) {
        actionHandler?()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = Self.createLayout()
    }
    
    static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(167),
                heightDimension: .absolute(250)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = itemSize
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 7
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        return layout
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<IdentifiableCollectionViewCell<String>, String> { cell, _, imageName in
            cell.id = imageName
            var contentConfiguration = ImageContentConfiguration()
            contentConfiguration.image = UIImage(named: imageName)
            var imageProperties = ImageContentConfiguration.ImageProperties()
            imageProperties.contentMode = .scaleAspectFill
            contentConfiguration.imageProperties = imageProperties
            cell.contentConfiguration = contentConfiguration
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
    }
}

// MARK: - PlaceCardContentConfiguration

struct PlaceCardContentConfiguration: UIContentConfiguration {
    
    /// The urls of images to display.
    var imagesNames: [String] = []
    
    /// The primary text.
    var text: String?
    
    /// An attributed variant of the primary text.
    var attributedText: NSAttributedString?
    
    /// Properties for configuring the primary text.
    var textProprieties = ContentConfiguration.TextProperties(
        font: .NOI.dynamic.title2Semibold
    )
    
    /// The secondary text.
    var secondaryText: String?
    
    /// An attributed variant of the secondary text.
    var secondaryAttributedText: NSAttributedString?
    
    /// Properties for configuring the secondary text.
    var secondaryTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.dynamic.bodyRegular
    )
    
    /// The action text.
    var actionText: String?
    
    /// An attributed variant of the action text.
    var actionAttributedText: NSAttributedString?
    
    /// Properties for configuring the action text.
    var actionTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.dynamic.bodySemibold
    )
    
    /// The action handler callback.
    var actionHandler: (() -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        return PlaceCardContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
