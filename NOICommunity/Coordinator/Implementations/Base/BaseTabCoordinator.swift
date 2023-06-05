// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BaseTabCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseTabCoordinator: BaseCoordinator, TabCoordinatorType {

    var tabBarController: UITabBarController

    @available(*, unavailable)
    override init(dependencyContainer: DependencyRepresentable) {
        fatalError("\(#function) not available")
    }
    
    init(
        tabBarController: UITabBarController,
        dependencyContainer: DependencyRepresentable
    ) {
        self.tabBarController = tabBarController
        super.init(dependencyContainer: dependencyContainer)
    }

    override func start(animated: Bool) {
        guard type(of: self) != BaseTabCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }
    
}
