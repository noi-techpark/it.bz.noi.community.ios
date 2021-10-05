//
//  BaseCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

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
        guard type(of: self) != BaseCoordinator.self
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
