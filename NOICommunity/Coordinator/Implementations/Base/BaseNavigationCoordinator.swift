// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BaseNavigationCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseNavigationCoordinator: BaseCoordinator, NavigationCoordinatorType {

    var navigationController: UINavigationController
    
    var rootViewController: UIViewController? {
        navigationController.viewControllers.first
    }

	override var topViewController: UIViewController {
		super.topViewController ?? navigationController
	}

    @available(*, unavailable)
    override init(dependencyContainer: DependencyRepresentable) {
        fatalError("\(#function) not available")
    }
    
    init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyRepresentable
    ) {
        self.navigationController = navigationController
        super.init(dependencyContainer: dependencyContainer)
    }
    
    override func start(animated: Bool) {
        guard type(of: self) != BaseNavigationCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }

}
