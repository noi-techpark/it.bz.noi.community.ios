// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  LoadingViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 08/10/21.
//

import UIKit

class LoadingViewController: UIViewController {

    enum Style {
        case light
        case dark
    }
    let style: Style

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            let color: UIColor?
            switch style {
            case .light:
                color = nil
            case .dark:
                color = .noiPrimaryColor
            }
            activityIndicatorView.color = color
        }
    }

    init(style: Style = .light) {
        self.style = style
        super.init(nibName: "\(LoadingViewController.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }

    override func loadView() {
        super.loadView()

        let backgroundColor: UIColor
        switch style {
        case .light:
            backgroundColor = .noiSecondaryBackgroundColor
        case .dark:
            backgroundColor = .noiBackgroundColor
        }
        view.backgroundColor = backgroundColor
    }

}
