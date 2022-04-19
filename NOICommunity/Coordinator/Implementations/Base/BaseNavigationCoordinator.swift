//
//  BaseNavigationCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseNavigationCoordinator: NSObject, NavigationCoordinatorType {
    
    var childCoordinators: [CoordinatorType] = []

    var navigationController: UINavigationController

    var dependencyContainer: DependencyRepresentable

    init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyRepresentable
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }

    func start(animated: Bool) {
        guard type(of: self) != BaseNavigationCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }

}
