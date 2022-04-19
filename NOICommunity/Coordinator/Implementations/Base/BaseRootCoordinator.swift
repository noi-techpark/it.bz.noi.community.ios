//
//  BaseRootCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/04/22.
//

import UIKit

class BaseRootCoordinator: NSObject, RootCoordinatorType {
    
    var childCoordinators: [CoordinatorType] = []

    var window: UIWindow

    var dependencyContainer: DependencyRepresentable

    init(
        window: UIWindow,
        dependencyContainer: DependencyRepresentable
    ) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }

    func start(animated: Bool) {
        guard type(of: self) != BaseRootCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }

}
