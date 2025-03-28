// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  GalleryCollectionViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/05/22.
//

import UIKit
import AVKit
import Kingfisher

struct MediaItem: Hashable {
    let imageURL: URL?
    let videoURL: URL?
    
    init(imageURL: URL? = nil, videoURL: URL? = nil) {
        self.imageURL = imageURL
        self.videoURL = videoURL
    }
}

class GalleryCollectionViewController: UICollectionViewController {

    private var dataSource: UICollectionViewDiffableDataSource<Section, MediaItem>! = nil
    
    var mediaItems: [MediaItem] {
        didSet {
            guard isViewLoaded
            else { return }
            
            let isOnScreen = view.window != nil
            update(mediaItems: mediaItems, animated: isOnScreen)
        }
    }
        
    let imageSize: CGSize
    let spacing: CGFloat
    let placeholderImage: UIImage?
    
    init(
        mediaItems: [MediaItem] = [],
        imageSize: CGSize,
        spacing: CGFloat,
        placeholderImage: UIImage? = nil
    ) {
        self.mediaItems = mediaItems
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let selectedVideoURL = dataSource.itemIdentifier(for: indexPath)?.videoURL
		else { return }

		openVideoPlayer(videoURL: selectedVideoURL)
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
        let cellRegistration = UICollectionView.CellRegistration<IdentifiableCollectionViewCell<MediaItem>, MediaItem> { cell, _, mediaItem in
            cell.id = mediaItem
            var contentConfiguration = ImageContentConfiguration()

			contentConfiguration.image = self.placeholderImage
            var imageProperties = ImageContentConfiguration.ImageProperties()
            imageProperties.contentMode = .scaleAspectFill
            contentConfiguration.imageProperties = imageProperties

			if mediaItem.videoURL != nil {
				contentConfiguration.overlappingImage = #imageLiteral(resourceName: "play-circle-solid.pdf")
				var overlappingImageProperties = ImageContentConfiguration.ImageProperties()
				overlappingImageProperties.contentMode = .scaleAspectFill
				overlappingImageProperties.tintColor =
					.noiSecondaryColor
				contentConfiguration.overlappingImageProperties = overlappingImageProperties
			} else {
				contentConfiguration.overlappingImage = nil
			}

			cell.contentConfiguration = contentConfiguration

            if let imageURL = mediaItem.imageURL {
                
                KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                    guard
                        cell.id == mediaItem,
                        case let .success(imageInfo) = result,
                        var contentConfiguration = cell.contentConfiguration as? ImageContentConfiguration
                    else { return }
                    
                    contentConfiguration.image = imageInfo.image
                    cell.contentConfiguration = contentConfiguration
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
        update(mediaItems: mediaItems, animated: false)
    }
    
    func update(mediaItems: [MediaItem], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MediaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(mediaItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

	func openVideoPlayer(videoURL: URL) {
		let player = AVPlayer(url: videoURL)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		playerViewController.modalPresentationStyle = .fullScreen
		present(playerViewController, animated: true) {
			player.play()
		}
	}

}
