// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsFiltersListViewController.swift
//  NOICommunity
//
//  Created by Camilla on 27/02/25.
//

import UIKit

class NewsFiltersListViewController: UICollectionViewController {

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }

}

// MARK: Private APIs

private extension NewsFiltersListViewController {

    func configureCollectionView() {
        collectionView.backgroundColor = .yellow
        collectionView.allowsSelection = false
    }

}
