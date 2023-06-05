// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  TabCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit

final class TabCoordinator: BaseTabCoordinator {
    
    override func start(animated: Bool) {
        let todayTabBarController = TopTabBarController()
        let todayNavController = NavigationController(
            rootViewController: todayTabBarController
        )
        todayNavController.navigationBar.prefersLargeTitles = true
        todayNavController.tabBarItem.title = .localized("tab_title_today")
        todayNavController.tabBarItem.image = UIImage(named: "ic_today")
        let todayCoordinator = TodayCoordinator(
            navigationController: todayNavController,
            topTabBarController: todayTabBarController,
            dependencyContainer: dependencyContainer
        )
        todayCoordinator.start(animated: false)
        childCoordinators.append(todayCoordinator)
        
        let eventsNavController = NavigationController()
        eventsNavController.tabBarItem.title = .localized("tab_title_today")
        eventsNavController.tabBarItem.image = UIImage(named: "ic_today")
        eventsNavController.navigationBar.prefersLargeTitles = true
        let eventsCoordinator = EventsCoordinator(
            navigationController: eventsNavController,
            dependencyContainer: dependencyContainer
        )
        eventsCoordinator.start()
        childCoordinators.append(eventsCoordinator)
        
        let orientateNavController = NavigationController()
        orientateNavController.tabBarItem.title = .localized("tab_title_orientate")
        orientateNavController.tabBarItem.image = UIImage(named: "ic_orientate")
        orientateNavController.navigationBar.prefersLargeTitles = true
        let orientateCoordinator = OrientateCoordinator(
            navigationController: orientateNavController,
            dependencyContainer: dependencyContainer
        )
        orientateCoordinator.start()
        childCoordinators.append(orientateCoordinator)
        
        let meetNavController = NavigationController()
        meetNavController.tabBarItem.title = .localized("tab_title_meet")
        meetNavController.tabBarItem.image = UIImage(named: "ic_meet")
        meetNavController.navigationBar.prefersLargeTitles = true
        let meetCoordinator = MeetCoordinator(
            navigationController: meetNavController,
            dependencyContainer: dependencyContainer
        )
        meetCoordinator.start()
        childCoordinators.append(meetCoordinator)
        
        let eatNavController = NavigationController()
        eatNavController.tabBarItem.title = .localized("tab_title_eat")
        eatNavController.tabBarItem.image = UIImage(named: "ic_eat")
        eatNavController.navigationBar.prefersLargeTitles = true
        let eatCoordinator = EatCoordinator(
            navigationController: eatNavController,
            dependencyContainer: dependencyContainer
        )
        eatCoordinator.start()
        childCoordinators.append(eatCoordinator)
        
        let moreNavController = NavigationController()
        moreNavController.tabBarItem.title = .localized("tab_title_more")
        moreNavController.tabBarItem.image = UIImage(named: "ic_more")
        moreNavController.navigationBar.prefersLargeTitles = true
        let moreCoordinator = MoreCoordinator(
            navigationController: moreNavController,
            dependencyContainer: dependencyContainer
        )
        moreCoordinator.start()
        childCoordinators.append(moreCoordinator)
        
        tabBarController.viewControllers = [
            todayNavController,
            orientateNavController,
            meetNavController,
            eatNavController,
            moreNavController
        ]
    }

}
