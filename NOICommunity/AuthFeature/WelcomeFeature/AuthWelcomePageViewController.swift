// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AuthWelcomePageViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/04/22.
//

import UIKit

// MARK: - AuthWelcomePageViewController

final class AuthWelcomePageViewController: UIViewController {
    
    @IBOutlet var backgroundImageView: UIImageView!

    @IBOutlet var textLabel: UILabel! {
        didSet {
            textLabel.font = .NOI.dynamic.headlineSemibold
        }
    }
    
    @IBOutlet var detailedTextLabel: UILabel! {
        didSet {
            detailedTextLabel.font = .NOI.dynamic.bodyRegular
        }
    }
    
    @IBOutlet var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.lastColor = .noiBackgroundColor
            backgroundGradientView.thirdColor = backgroundGradientView
                .thirdColor
                .withAlphaComponent(0.87)
            backgroundGradientView.secondColor = backgroundGradientView
                .thirdColor
                .withAlphaComponent(0.60)
            backgroundGradientView.firstColor = backgroundGradientView
                .thirdColor
                .withAlphaComponent(0.0)
            backgroundGradientView.backgroundColor = .clear
        }
    }
    
    var topMargin: CGFloat = 0 {
        didSet {
            constraint.constant = topMargin
            constraint.isActive = true
        }
    }
    
    private lazy var constraint: NSLayoutConstraint! = {
        let constraint = detailedTextLabel.lastBaselineAnchor.constraint(
            equalTo: view.topAnchor,
            constant: topMargin
        )
        return constraint
    }()
    
}

extension AuthWelcomePageViewController: Identifiable {
    
    
}
