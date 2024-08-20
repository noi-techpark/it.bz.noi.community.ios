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

// MARK: - EventsFiltersBarView

class EventsFiltersBarView: UIView {

    @IBOutlet private(set) var contentView: UIView!

    @IBOutlet private(set) var filtersBarView: FiltersBarView! {
        didSet {
            filtersBarView.items = DateIntervalFilter.allCases.map(\.localizedString)
            filtersBarView.scrollView.contentInset = .init(
                top: 0,
                left: 17,
                bottom: 0,
                right: 17
            )
        }
    }

    @IBOutlet private(set) var filtersButton: UIButton! {
        didSet {
            filtersButton.configureAsFiltersButton()
        }
    }

    var dateIntervalsControl: UISegmentedControl {
        filtersBarView.segmentedControl
    }

    var scrollView: UIScrollView {
        filtersBarView.scrollView
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

private extension EventsFiltersBarView {

    func setup() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(EventsFiltersBarView.self)",
            owner: self,
            options: nil
        )


        embedSubview(contentView)
    }

}
