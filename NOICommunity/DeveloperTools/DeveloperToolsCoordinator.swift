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

final class DeveloperToolsCoordinator: BaseNavigationCoordinator {

    override func start(animated: Bool) {
        let developerToolsViewModel = dependencyContainer.makeDeveloperToolsViewModel()
        let developerToolsViewController = dependencyContainer.makeDeveloperToolsViewController(
            viewModel: developerToolsViewModel
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
