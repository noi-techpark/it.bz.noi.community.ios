//
//  PlaceCardContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/09/21.
//

import UIKit
import Kingfisher

// MARK: - PlaceCardContentView

class PlaceCardContentView: UIView, UIContentView {
    @IBOutlet var containerView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var detailTextLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
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

    private var dataSource: UICollectionViewDiffableDataSource<Section, URL>! = nil

    private var imagePrefetcher: ImagePrefetcher?

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
        textLabel.setAttributedText(
            configuration.attributedText,
            or: configuration.text
        )
        textLabel.apply(textProperties: configuration.textProprieties)

        // Update detail text label
        detailTextLabel.setAttributedText(
            configuration.secondaryAttributedText,
            or: configuration.secondaryText
        )
        detailTextLabel.apply(
            textProperties: configuration.secondaryTextProprieties
        )

        // Update action button
        actionButton.setAttributedText(
            configuration.actionAttributedText,
            or: configuration.actionText
        )
        actionHandler = configuration.actionHandler

        var snapshot = NSDiffableDataSourceSnapshot<Section, URL>()
        snapshot.appendSections([.main])
        snapshot.appendItems(configuration.imagesURLs)
        dataSource.apply(snapshot, animatingDifferences: false)
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

            let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(167),
                    heightDimension: .absolute(250)
                )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        return layout
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<IdentifiableCollectionViewCell<URL>, URL> { cell, _, imageUrl in
            cell.id = imageUrl
            var contentConfiguration = ImageContentConfiguration()
            contentConfiguration.image = UIImage(named: "placeholder_noi_events")
            var imageProperties = ImageContentConfiguration.ImageProperties()
            imageProperties.contentMode = .scaleAspectFill
            contentConfiguration.imageProperties = imageProperties
            cell.contentConfiguration = contentConfiguration

            KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
                guard
                    cell.id == imageUrl,
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
    }
}

// MARK: - PlaceCardContentConfiguration

struct PlaceCardContentConfiguration: UIContentConfiguration {

    /// The urls of images to display.
    var imagesURLs: [URL] = []

    /// The primary text.
    var text: String?

    /// An attributed variant of the primary text.
    var attributedText: NSAttributedString?

    /// Properties for configuring the primary text.
    var textProprieties = TextProperties()

    /// The secondary text.
    var secondaryText: String?

    /// An attributed variant of the secondary text.
    var secondaryAttributedText: NSAttributedString?

    /// Properties for configuring the secondary text.
    var secondaryTextProprieties = TextProperties()

    /// The action text.
    var actionText: String?

    /// An attributed variant of the action text.
    var actionAttributedText: NSAttributedString?

    /// The action handler callback.
    var actionHandler: (() -> Void)?

    func makeContentView() -> UIView & UIContentView {
        return PlaceCardContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

extension PlaceCardContentConfiguration {
    struct TextProperties: Hashable {
        /// The maximum number of lines for the text.
        var numberOfLines: Int = 0
    }
}

// MARK: - UILabel+setAttributedText

private extension UILabel {
    func setAttributedText(
        _ attributedText: NSAttributedString?,
        or text: String?
    ) {
        if let attributedText = attributedText {
            self.attributedText = attributedText
        } else {
            self.text = text
        }
    }

    func apply(textProperties: PlaceCardContentConfiguration.TextProperties) {
        numberOfLines = textProperties.numberOfLines
    }
}

// MARK: - UIButton+setAttributedText

private extension UIButton {
    func setAttributedText(
        _ attributedText: NSAttributedString?,
        or text: String?
    ) {
        titleLabel?.setAttributedText(attributedText, or: text)
    }
}
