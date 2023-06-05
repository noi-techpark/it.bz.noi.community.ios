// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BaseTopTabBarCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/03/2022.
//

import UIKit

class BaseTopTabBarCoordinator: BaseNavigationCoordinator, TopTabCoordinatorType {
    
    var topTabBarController: TopTabBarController
    
    @available(*, unavailable)
    override init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyRepresentable
    ) {
        fatalError("\(#function) not available")
    }
    
    init(
        navigationController: UINavigationController,
        topTabBarController: TopTabBarController,
        dependencyContainer: DependencyRepresentable
    ) {
        self.topTabBarController = topTabBarController
        super.init(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
    }
    
    override func start(animated: Bool) {
        guard type(of: self) != BaseTopTabBarCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }
    
}
