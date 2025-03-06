// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsFiltersViewController.swift
//  NOICommunity
//
//  Created by Camilla on 27/02/25.
//

import UIKit
import ArticleTagsClient

class NewsFiltersViewController: UIViewController {

    @IBOutlet private var contentContainer: UIView!

    @IBOutlet private var actionsContainersView: FooterView!

    @IBOutlet private var resetActiveFiltersButton: UIButton! {
        didSet {
            resetActiveFiltersButton
                .configureAsTertiaryActionButton()
                .withMinimumHeight(44)
                .withTitle(.localized("reset_filters_btn"))
        }
    }

    @IBOutlet private var showResultsButton: UIButton! {
        didSet {
            showResultsButton
                .configureAsPrimaryActionButton()
                .setTitle("Show Results", for: .normal) // Testo statico per ora
        }
    }

    private lazy var resultsVC = makeResultsViewController()
    
    init() {
        super.init(nibName: "NewsFiltersViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filters"
        embedChild(resultsVC, in: contentContainer)
    }
    
    private func makeResultsViewController() -> NewsFiltersListViewController {
        let articleTags: [ArticleTag] = [
            ArticleTag(
                id: "dce044b2-e5e5-4e86-992a-b7e6562e5934",
                tagName: ["it": "A1", "de": "A1", "en": "A1"],
                types: ["noicommunitycategory"]
            ),
            ArticleTag(
                id: "6f6a4377-f9a5-4536-aab6-72470e5ab2ca",
                tagName: ["it": "A3", "de": "A3", "en": "A3"],
                types: ["noicommunitycategory"]
            ),
            ArticleTag(
                id: "4fa326d5-37a8-43f0-866e-c87faaabb075",
                tagName: ["de": "A4", "en": "A4", "it": "A4"],
                types: ["noicommunitycategory"]
            )
        ]
        
        return NewsFiltersListViewController(items: articleTags, onItemsIds: [])
    }
}
