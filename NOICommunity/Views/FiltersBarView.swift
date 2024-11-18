// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  FiltersBarView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 20/08/24.
//

import UIKit
import CoreUI

// MARK: - FiltersBarViewDelegate

protocol FiltersBarViewDelegate: AnyObject {

    func filtersBarView(
        _ filtersBarView: FiltersBarView,
        didSelectItemAt index: Int
    )

}

// MARK: - FiltersBarView

class FiltersBarView: UIView {

    // MARK: Public Properties

    weak var delegate: FiltersBarViewDelegate?
    
    var items: [String] = [] {
        didSet {
            updateDataSource()
        }
    }
    
    var indexOfSelectedItem: Int? {
        didSet {
            if let index = indexOfSelectedItem {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .centeredHorizontally
                )
            } else {
                (collectionView.indexPathsForSelectedItems ?? [])
                    .forEach {
                        collectionView.deselectItem(at: $0, animated: true)
                    }
            }
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            updateCollectionViewLayout()
        }
    }
    
    // MARK: Private Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCollectionView()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupCollectionView()
        configureDataSource()
    }

}

// MARK: Private Methods

private extension FiltersBarView {

    enum Section: Hashable {
        case main
    }

    func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, _ in
            guard let self
            else { return nil }

            let size = NSCollectionLayoutSize(
                widthDimension: .estimated(SizeAndConstants.estimatedWidth),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(SizeAndConstants.estimatedWidth),
                heightDimension: .absolute(SizeAndConstants.height)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = SizeAndConstants.spacing
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(
                top: self.contentInset.top,
                leading: self.contentInset.left,
                bottom: self.contentInset.bottom,
                trailing: self.contentInset.right
            )

            return section
        }
    }

    func configureDataSource() {
        let cellRegistration: UICollectionView.CellRegistration<FilterCell, String> 
        = .init { cell, _, item in
            cell.configure(with: item)
        }

        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
            return cell
        }
    }

    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func updateCollectionViewLayout() {
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
    }

}

// MARK: UICollectionViewDelegate

extension FiltersBarView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        indexOfSelectedItem = indexPath.item
        delegate?.filtersBarView(self, didSelectItemAt: indexPath.item)
        
        // Scroll to selected item
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
}

// MARK: - Filter Cell

private class FilterCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // Base setup
        contentView.backgroundColor = SizeAndConstants.fillColor
        contentView.layer.cornerRadius = SizeAndConstants.cornerRadius
        contentView.layer.borderWidth = SizeAndConstants.lineWidth
        
        // Label setup
        contentView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo:
                    contentView.topAnchor,
                constant: 8
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo:
                    contentView.bottomAnchor,
                constant: -8
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor,
                constant: -16
            ),
        ])
        
        updateSelectionHighlightedState()
    }
    
    func configure(with title: String) {
        titleLabel.text = title

        updateSelectionHighlightedState()
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelectionHighlightedState()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateSelectionHighlightedState()
        }
    }

    private func updateSelectionHighlightedState() {
        if isSelected || isHighlighted {
            contentView.layer.borderColor = SizeAndConstants.selectedLineColor.cgColor
            titleLabel.textColor = SizeAndConstants.selectedTextColor
            titleLabel.font = SizeAndConstants.selectedFont
        } else {
            contentView.layer.borderColor = SizeAndConstants.lineColor.cgColor
            titleLabel.textColor = SizeAndConstants.textColor
            titleLabel.font = SizeAndConstants.font
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        isSelected = false
        isHighlighted = false
    }

}

private extension SizeAndConstants {

    static let height: CGFloat = 40
    static let estimatedWidth: CGFloat = 100
    static let spacing: CGFloat = 5
    static let lineWidth: CGFloat = 1
    static let cornerRadius: CGFloat = 2

    static let fillColor = UIColor.noiPrimaryColor
    static let lineColor = UIColor.noiInactiveColor
    static let selectedLineColor = UIColor.noiSecondaryColor
    static let textColor = selectedTextColor.withAlphaComponent(0.5)
    static let selectedTextColor = UIColor.noiSecondaryColor
    static let font: UIFont = .NOI.fixed.caption1Semibold
    static let selectedFont: UIFont = .NOI.fixed.caption1Semibold

}
