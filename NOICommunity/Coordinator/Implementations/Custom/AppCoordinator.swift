//
//  AppCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/04/22.
//

import Foundation
import Combine
import AuthStateStorageClient

let logoutNotification = Notification.Name("logout")

// MARK: - AppCoordinator

final class AppCoordinator: BaseNavigationCoordinator {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var isAutorizedClient = dependencyContainer
        .makeIsAutorizedClient()
    
    override func start(animated: Bool) {
        NotificationCenter
            .default
            .publisher(for: logoutNotification)
            .sink { [weak self] _ in
                self?.logout(animated: true)
            }
            .store(in: &subscriptions)
        
        guard isAutorizedClient()
        else {
            showAuthCoordinator()
            return
        }
        
        showTabCoordinator()
    }
    
}

// MARK: - AppCoordinator

private extension AppCoordinator {
    
    func authCoordinatorDidFinish(_ authCoordinator: AuthCoordinator) {
        sacrifice(child: authCoordinator)
        showTabCoordinator(animated: true)
    }
    
    func showAuthCoordinator(animated: Bool = false) {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        authCoordinator.didFinishHandler = { [weak self] in
            self?.authCoordinatorDidFinish($0)
        }
        childCoordinators.append(authCoordinator)
        authCoordinator.start(animated: animated)
    }
    
    func showTabCoordinator(animated: Bool = false) {
        let tabBarController = TabBarController()
        let tabCoordinator = TabCoordinator(
            tabBarController: tabBarController,
            dependencyContainer: dependencyContainer
        )
        childCoordinators.append(tabCoordinator)
        tabCoordinator.start()
        navigationController.setViewControllers(
            [tabBarController],
            animated: animated
        )
    }
    
    func logout(animated: Bool) {
        childCoordinators = []
        showAuthCoordinator(animated: animated)
    }
    
}
