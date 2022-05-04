//
//  AppCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/11/21.
//

import UIKit
import AppPreferencesClient

// MARK: - RootCoordinator

final class RootCoordinator: BaseRootCoordinator {
    
    private var appCoordinator: AppCoordinator!
    
    private lazy var appPreferencesClient = dependencyContainer
        .makeAppPreferencesClient()
    
    private var appPreferences: AppPreferences!
    
    override func start(animated: Bool) {
        appPreferences = appPreferencesClient.fetch()
        if appPreferences.skipIntro {
            startAppCoordinator()
        } else {
            showIntro()
        }
    }
    
}

// MARK: Private APIs

private extension RootCoordinator {
    
    func startAppCoordinator() {
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        appCoordinator = AppCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        childCoordinators.append(appCoordinator)
        appCoordinator.start()
        window.rootViewController = navigationController
    }
    
    func showIntro() {
        let introVC = IntroViewController()
        introVC.didFinishHandler = { [weak self] in
            self?.handleIntroDidFinish()
        }
        window.rootViewController = introVC
    }
    
    func handleIntroDidFinish() {
        appPreferences.skipIntro = true
        appPreferencesClient.update(appPreferences)
        
        startAppCoordinator()
    }
    
}
