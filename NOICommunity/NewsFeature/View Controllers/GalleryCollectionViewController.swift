//
//  GalleryCollectionViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/05/22.
//

import UIKit
import Kingfisher

class GalleryCollectionViewController: UICollectionViewController {

    private var dataSource: UICollectionViewDiffableDataSource<Section, URL>! = nil
    
    var imageURLs: [URL] {
        didSet {
            guard isViewLoaded
            else { return }
            
            let isOnScreen = view.window != nil
            update(imageURL: imageURLs, animated: isOnScreen)
        }
    }
        
    let imageSize: CGSize
    let spacing: CGFloat
    let placeholderImage: UIImage?
    
    init(
        imageURL: [URL] = [],
        imageSize: CGSize,
        spacing: CGFloat,
        placeholderImage: UIImage? = nil
    ) {
        self.imageURLs = imageURL
        self.imageSize = imageSize
        self.spacing = spacing
        self.placeholderImage = placeholderImage
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
    }

}

private extension GalleryCollectionViewController {
    
    enum Section {
        case main
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = Self.createLayout(
            imageSize: imageSize,
            spacing: spacing
        )
    }

    static func createLayout(
        imageSize: CGSize,
        spacing: CGFloat
    ) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(imageSize.width),
                heightDimension: .absolute(imageSize.height)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = itemSize
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        return layout
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<IdentifiableCollectionViewCell<URL>, URL> { cell, _, imageURL in
            cell.id = imageURL
            var contentConfiguration = ImageContentConfiguration()
            contentConfiguration.image = self.placeholderImage
            var imageProperties = ImageContentConfiguration.ImageProperties()
            imageProperties.contentMode = .scaleAspectFill
            contentConfiguration.imageProperties = imageProperties
            cell.contentConfiguration = contentConfiguration

            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                guard
                    cell.id == imageURL,
                    case let .success(imageInfo) = result,
                    var contentConfiguration = cell.contentConfiguration as? ImageContentConfiguration
                else { return }

                contentConfiguration.image = imageInfo.image
                cell.contentConfiguration = contentConfiguration
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
        update(imageURL: imageURLs, animated: false)
    }
    
    func update(imageURL: [URL], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, URL>()
        snapshot.appendSections([.main])
        snapshot.appendItems(imageURL, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
}
