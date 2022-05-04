//
//  BaseNavigationCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseCoordinator: NSObject, CoordinatorType {
    
    var childCoordinators: [CoordinatorType] = []

    var dependencyContainer: DependencyRepresentable

    init(dependencyContainer: DependencyRepresentable) {
        self.dependencyContainer = dependencyContainer
    }

    func start(animated: Bool) {
        guard type(of: self) != BaseCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }

}
