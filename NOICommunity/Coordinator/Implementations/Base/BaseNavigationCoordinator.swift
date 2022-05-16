//
//  BaseNavigationCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

class BaseNavigationCoordinator: BaseCoordinator, NavigationCoordinatorType {

    var navigationController: UINavigationController

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

}
