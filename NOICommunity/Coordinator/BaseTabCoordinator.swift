//
//  BaseTabCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseTabCoordinator: TabCoordinator {
    var childCoordinators: [Coordinator] = []

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

    /// This method should be called when a child coordinator have finished its job.
    /// - Parameter child: child of the parent going to be terminated.
    func sacrifice(child: Coordinator) {
        guard let childPosition = childCoordinators
                .firstIndex(where: { $0 === child })
        else { return }

        childCoordinators.remove(at: childPosition)
    }
}
