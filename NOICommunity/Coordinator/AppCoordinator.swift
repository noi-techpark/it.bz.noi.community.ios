//
//  AppCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/11/21.
//

import UIKit
import AppPreferencesClient

class AppCoordinator {

    var window: UIWindow

    typealias DependencyRepresentable = ViewModelFactory & ViewControllerFactory
    var dependencyContainer: DependencyRepresentable

    var mainCoordinator: MainCoordinator?

    private var appPreferences: AppPreferences!

    init(
        window: UIWindow,
        dependencyContainer: DependencyRepresentable
    ) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }

    func start() {
        let loadAppPreferencesMainVC = LoadAppPreferencesMainViewController(
            viewModel: dependencyContainer.makeLoadAppPreferencesViewModel(),
            didLoadHandler: { [weak self] in
                self?.handleDidLoadAppPreferences($0)
            })
        window.rootViewController = loadAppPreferencesMainVC
    }
    
}

private extension AppCoordinator {

    func startMainCoordinator() {
        let tabBarController = TabBarController()
        let mainCoordinator = MainCoordinator(
            tabBarController: tabBarController,
            dependencyContainer: self.dependencyContainer
        )
        self.mainCoordinator = mainCoordinator
        mainCoordinator.start(animated: false)
        window.rootViewController = tabBarController
    }

    func handleIntroDidFinish() {
        appPreferences.skipIntro = true
        let updateAppPreferencesViewModel = dependencyContainer.makeUpdateAppPreferencesViewModel()
        updateAppPreferencesViewModel.update(appPreferences: appPreferences)
        startMainCoordinator()
    }

    func handleDidLoadAppPreferences(_ appPreferences: AppPreferences) {
        self.appPreferences = appPreferences
        if appPreferences.skipIntro {
            startMainCoordinator()
        } else {
            let introVC = IntroViewController()
            introVC.didFinishHandler = { [weak self] in
                self?.handleIntroDidFinish()
            }
            window.rootViewController = introVC
        }
    }
}
