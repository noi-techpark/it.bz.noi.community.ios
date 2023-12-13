// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AppCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/11/21.
//

import UIKit
import AppPreferencesClient

// MARK: - Refresh News List Notification

let refreshNewsListNotification = Notification.Name("refreshNewsList")

// MARK: - RootCoordinator

final class RootCoordinator: BaseRootCoordinator {
    
    private weak var appCoordinator: AppCoordinator!
    
    private lazy var appPreferencesClient = dependencyContainer
        .makeAppPreferencesClient()
    
    private var appPreferences: AppPreferences!
    
    private var pendingDeepLinkIntent: DeepLinkIntent?
    
    override func start(animated: Bool) {
        appPreferences = appPreferencesClient.fetch()
        if appPreferences.skipIntro {
            startAppCoordinator()
        } else {
            showIntro()
        }
    }
    
    func handle(notificationPayload: [AnyHashable: Any]) {
        if let deepLinkIntent = DeepLinkManager.deepLinkIntent(
            from: notificationPayload
        ) {
            handle(deepLinkIntent: deepLinkIntent)
        }
    }
    
    func handleWillPresent(notificationPayload: [AnyHashable: Any]) {
        switch DeepLinkManager.deepLinkIntent(from: notificationPayload) {
        case nil:
            return
        case .showNews(newsId: _):
            refreshNewsList()
        }
    }
    
}

// MARK: Private APIs

private extension RootCoordinator {
    
    func startAppCoordinator() {
        let navigationController = NavigationController()
        navigationController.navigationBar.isHidden = true
        navigationController.navigationBar.prefersLargeTitles = true
        let appCoordinator = AppCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        childCoordinators.append(appCoordinator)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
        window.rootViewController = navigationController
        
        if let pendingDeepLinkIntent = pendingDeepLinkIntent {
            appCoordinator.handle(deepLinkIntent: pendingDeepLinkIntent)
            self.pendingDeepLinkIntent = nil
        }
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
    
    func handle(deepLinkIntent: DeepLinkIntent) {
        if let appCoordinator = appCoordinator {
            appCoordinator.handle(deepLinkIntent: deepLinkIntent)
        } else {
            pendingDeepLinkIntent = deepLinkIntent
        }
    }
    
    func refreshNewsList() {
        NotificationCenter
            .default
            .post(name: refreshNewsListNotification, object: self)
    }
    
}
