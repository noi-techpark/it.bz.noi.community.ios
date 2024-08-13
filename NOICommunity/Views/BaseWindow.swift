// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BaseWindow.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/08/24.
//

import UIKit

// MARK: - BaseWindow

class BaseWindow: UIWindow {

    var dependencyContainer: DependencyRepresentable!

    private var developerToolsCoordinator: DeveloperToolsCoordinator?

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        switch motion {
        case .motionShake:
#if DEVELOPER_MENU
            showDeveloperTools()
#endif
        default:
            break
        }
    }
}

// MARK: Private APIs

private extension BaseWindow {

#if DEVELOPER_MENU
    func showDeveloperTools(animated: Bool = true) {
        guard let rootViewController
        else { return }

        let isAlreadyShown = developerToolsCoordinator?.navigationController != nil && rootViewController.presentedViewController == developerToolsCoordinator?.navigationController
        guard !isAlreadyShown
        else { return }

        let navigationController = NavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let developerToolsCoordinator = DeveloperToolsCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        self.developerToolsCoordinator = developerToolsCoordinator
        developerToolsCoordinator.start()
        rootViewController.present(navigationController, animated: animated)
    }
#endif

}
