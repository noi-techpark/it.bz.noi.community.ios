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
    }
}
