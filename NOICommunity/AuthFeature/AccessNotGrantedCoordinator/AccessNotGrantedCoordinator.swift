// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AccessNotGrantedCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 02/05/22.
//

import Foundation

// MARK: - RootCoordinator

final class AccessNotGrantedCoordinator: BaseNavigationCoordinator {
    
    override func start(animated: Bool) {
        showAccessNotGranted(animated: animated)
    }
    
}

// MARK: Private APIs

private extension AccessNotGrantedCoordinator {
    
    func showAccessNotGranted(animated: Bool) {
        let myAccountViewModel = dependencyContainer.makeMyAccountViewModel()
        let accessNotGrantedVC = dependencyContainer
            .makeAccessNotGrantedViewController(viewModel: myAccountViewModel)
        navigationController.setViewControllers(
            [accessNotGrantedVC],
            animated: animated
        )
    }
    
}
