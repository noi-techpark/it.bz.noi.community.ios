//
//  AppCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/04/22.
//

import Foundation
import Combine
import AuthStateStorageClient
import AuthClient

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
        
        showLoadUserInfo(animated: false) { [weak self] in
            self?.showAuthorizedContent(animated: true)
        }
    }
    
}

// MARK: - AppCoordinator

private extension AppCoordinator {
    
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
    
    func showLoadUserInfo(
        animated: Bool,
        onSuccess successHandler: @escaping () -> Void
    ) {
        let loadUserInfoCoordinator = LoadUserInfoCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        loadUserInfoCoordinator.didFinishHandler = { [weak self] in
            self?.loadUserInfoCoordinatorDidFinish(
                $0,
                with: $1,
                onSuccess: successHandler
            )
        }
        childCoordinators.append(loadUserInfoCoordinator)
        loadUserInfoCoordinator.start(animated: animated)
    }
    
    func showAuthorizedContent(animated: Bool) {
        func showAccessNotGrantedCoordinator(animated: Bool) {
            let accessNotGrantedCoordinator = AccessNotGrantedCoordinator(
                navigationController: navigationController,
                dependencyContainer: dependencyContainer
            )
            childCoordinators.append(accessNotGrantedCoordinator)
            accessNotGrantedCoordinator.start(animated: animated)
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
        
        let hasAccessGrantedClient = dependencyContainer
            .makeHasAccessGrantedClient()
        if hasAccessGrantedClient() {
            showTabCoordinator(animated: true)
        } else {
            showAccessNotGrantedCoordinator(animated: true)
        }
    }
    
    
    func authCoordinatorDidFinish(
        _ authCoordinator: AuthCoordinator
    ) {
        sacrifice(child: authCoordinator)
        showLoadUserInfo(animated: false) { [weak self] in
            self?.showAuthorizedContent(animated: true)
        }
    }
    
    func loadUserInfoCoordinatorDidFinish(
        _ loadUserInfoCoordinator: LoadUserInfoCoordinator,
        with result: Result<Void, Error>,
        onSuccess successHandler: @escaping () -> Void
    ) {
        sacrifice(child: loadUserInfoCoordinator)
        switch result {
        case .success():
            successHandler()
        case .failure(AuthError.OAuthTokenInvalidGrant):
            logout(animated: true)
        case .failure(_):
            successHandler()
        }
    }
    
    func logout(animated: Bool) {
        childCoordinators = []
        showAuthCoordinator(animated: animated)
    }
    
}
