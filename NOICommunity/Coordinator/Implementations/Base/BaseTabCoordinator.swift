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

}
