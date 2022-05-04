//
//  BaseTabCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseTabCoordinator: NSObject, TabCoordinatorType {
    
    var childCoordinators: [CoordinatorType] = []

    var tabBarController: UITabBarController

    var dependencyContainer: DependencyRepresentable

    init(
        tabBarController: UITabBarController,
        dependencyContainer: DependencyRepresentable
    ) {
        self.tabBarController = tabBarController
        self.dependencyContainer = dependencyContainer
    }

    func start(animated: Bool) {
        guard type(of: self) != BaseTabCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }

}
