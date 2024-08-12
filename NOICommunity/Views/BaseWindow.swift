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
        switch motion {
        case .motionShake:
#if DEBUG
            showDeveloperTools()
#endif
        default:
            break
        }
    }
}

// MARK: Private APIs

private extension BaseWindow {

#if DEBUG
    func showDeveloperTools() {
        developerToolsCoordinator?.dismiss(animated: true)

        guard let rootViewController
        else { return }

        let navigationController = UINavigationController()
        let developerToolsCoordinator = DeveloperToolsCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        self.developerToolsCoordinator = developerToolsCoordinator
        developerToolsCoordinator.start()
        rootViewController.present(navigationController, animated: true)
    }
#endif

}
