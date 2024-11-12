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

protocol FiltersBarViewDelegate: AnyObject {
    func filtersBarView(
        _ filtersBarView: FiltersBarView,
        didSelectItemAt index: Int
    )
}

internal class FiltersBarView: UIView {
    // MARK: - Public Properties
    weak internal var delegate: FiltersBarViewDelegate?
    
    internal var items: [String] = [] {
        didSet {
            updateDataSource()
        }
    }
    
    internal var indexOfSelectedItem: Int? {
        didSet {
            if let index = indexOfSelectedItem {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            } else {
                if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
                    selectedIndexPaths.forEach { indexPath in
                        collectionView.deselectItem(at: indexPath, animated: true)
                    }
                }
            }
        }
    }
    
    internal var contentInset: UIEdgeInsets = .zero {
        didSet {
            updateCollectionViewLayout()
        }
    }
    
    // MARK: - Private Properties
    private enum Section: Hashable {
        case main
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
    // Visual properties from original SegmentedControl
    private let spacing: CGFloat = 5
    private let height: CGFloat = 40
    
    // MARK: - Initialization
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        configureDataSource()
    }
    
    required internal init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
        configureDataSource()
    }
    
    // MARK: - Private Methods
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.backgroundColor = .noiSecondaryBackgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.reuseIdentifier)
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ in
            guard let self = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(100),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(100),
                heightDimension: .absolute(self.height)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = self.spacing // Usando il spacing definito
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(
                top: self.contentInset.top,
                leading: self.contentInset.left,
                bottom: self.contentInset.bottom,
                trailing: self.contentInset.right
            )
            
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, String>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FilterCell.reuseIdentifier,
                for: indexPath
            ) as? FilterCell else {
                fatalError("Failed to dequeue FilterCell")
            }
            
            cell.configure(with: item)
            return cell
        }
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateCollectionViewLayout() {
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension FiltersBarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    static let reuseIdentifier = "FilterCell"
    
    // MARK: - Constants from parent view
    private let lineWidth: CGFloat = 1
    private let cornerRadius: CGFloat = 1
    private let height: CGFloat = 40
    
    private let activeColor = UIColor.noiSecondaryColor
    private let inactiveColor = UIColor.noiSecondaryColor.withAlphaComponent(0.5)
    private let normalFont: UIFont = .NOI.fixed.caption1Semibold
    private let selectedFont: UIFont = .NOI.fixed.caption1Semibold
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.backgroundColor = .noiPrimaryColor
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.borderWidth = lineWidth
        contentView.clipsToBounds = false // Per permettere l'ombra
        
        // Shadow setup
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = cornerRadius
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        
        // Label setup
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentView.heightAnchor.constraint(equalToConstant: height) // Aggiungiamo il vincolo dell'altezza
        ])
        
        updateSelectionState()
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        updateSelectionState()
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
    private func updateSelectionState() {
        if isSelected {
            contentView.layer.borderColor = activeColor.cgColor
            titleLabel.textColor = activeColor
            titleLabel.font = selectedFont
            layer.shadowOpacity = 0.2
        } else {
            contentView.layer.borderColor = UIColor.noiInactiveColor.cgColor
            titleLabel.textColor = inactiveColor
            titleLabel.font = normalFont
            layer.shadowOpacity = 0.1
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        isSelected = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Aggiorna il layer dell'ombra
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }
}
