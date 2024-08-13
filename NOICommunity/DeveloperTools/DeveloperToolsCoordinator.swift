// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  DeveloperToolsCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/08/24.
//

import Foundation
import UIKit

// MARK: - DeveloperToolsCoordinator

final class DeveloperToolsCoordinator: BaseNavigationCoordinator {

    override func start(animated: Bool) {
        let developerToolsViewModel = dependencyContainer.makeDeveloperToolsViewModel()
        let developerToolsViewController = dependencyContainer.makeDeveloperToolsViewController(
            viewModel: developerToolsViewModel
        )
        developerToolsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapClose(_:))
        )
        developerToolsViewController.title = "Developer Tools"
        navigationController.setViewControllers(
            [developerToolsViewController],
            animated: animated
        )
    }

    func dismiss(animated: Bool) {
        navigationController.dismiss(animated: animated)
    }
}

// MARK: Private APIs

private extension DeveloperToolsCoordinator {

    @objc func didTapClose(_ sender: Any?) {
        dismiss(animated: true)
    }
}
