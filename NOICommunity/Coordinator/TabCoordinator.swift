//
//  Coordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

/// Coordinator protocol. Coordinators are responsible to handle navigations and object creations.
protocol TabCoordinator: AnyObject {

    typealias DependencyRepresentable = ViewModelFactory & ViewControllerFactory

    /// childCoordinators: child coordinators should be append to this array to keep them alive!
    var childCoordinators: [Coordinator] { get set }

    /// Since main task of tab coordinators is handling tabs, they directly interact with a tab bar controller
    var tabBarController: UITabBarController { get set }

    /// Coordinators need container for creating view controllers
    var dependencyContainer: DependencyRepresentable { get set }

    /// Start function triggers view controller creation and navigations.
    func start(animated: Bool)
}
