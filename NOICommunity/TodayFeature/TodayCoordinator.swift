//
//  TodayCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit
import Foundation

// MARK: - TodayCoordinator

final class TodayCoordinator: BaseTopTabBarCoordinator {
    
    override func start(animated: Bool) {
        navigationController.viewControllers
            .first?.navigationItem.title = .localized("title_today")
        
        let newsCoordinator = NewsCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        newsCoordinator.start()
        childCoordinators.append(newsCoordinator)
        
        let eventsCoordinator = EventsCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        eventsCoordinator.start()
        childCoordinators.append(eventsCoordinator)
        
        topTabBarController.viewControllers = [
            newsCoordinator.rootViewController,
            eventsCoordinator.rootViewController
        ]
    }
}
