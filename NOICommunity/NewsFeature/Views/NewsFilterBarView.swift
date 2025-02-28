// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventsFiltersBarView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 15/10/21.
//

import UIKit

// MARK: - NewsFilterBarView

class NewsFilterBarView: UIView {

    @IBOutlet private(set) var contentView: UIView!

    @IBOutlet private(set) var filtersBarView: FiltersBarView!
    @IBOutlet private(set) var filtersButton: UIButton! {
        didSet {
            filtersButton.configureAsFiltersButton()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

}

// MARK: Private APIs

private extension NewsFilterBarView {

    func setup() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(NewsFilterBarView.self)",
            owner: self,
            options: nil
        )


        embedSubview(contentView)
    }

}
