//
//  SceneDelegate.swift
//  NOI Community
//
//  Created by Matteo Matassoni on 30/07/21.
//

import UIKit
import EventShortClientLive

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene)
        else { return }

        let eventsViewModel = EventsViewModel(eventShortClient: .live)
        let eventsVC = EventsViewController(viewModel: eventsViewModel)
        eventsVC.navigationItem.title = .localized("title_today")
        eventsVC.navigationItem.largeTitleDisplayMode = .always
        let todayNavController = NavigationController(rootViewController: eventsVC)
        todayNavController.tabBarItem.title = .localized("tab_title_today")
        todayNavController.tabBarItem.image = UIImage(named: "ic_today")
        todayNavController.navigationBar.prefersLargeTitles = true

        let orientateNavController = NavigationController()
        orientateNavController.tabBarItem.title = .localized("tab_title_orientate")
        orientateNavController.tabBarItem.image = UIImage(named: "ic_orientate")
        orientateNavController.navigationBar.prefersLargeTitles = true

        let meetNavController = NavigationController()
        meetNavController.tabBarItem.title = .localized("tab_title_meet")
        meetNavController.tabBarItem.image = UIImage(named: "ic_meet")
        meetNavController.navigationBar.prefersLargeTitles = true

        let eatNavController = NavigationController()
        eatNavController.tabBarItem.title = .localized("tab_title_eat")
        eatNavController.tabBarItem.image = UIImage(named: "ic_eat")
        eatNavController.navigationBar.prefersLargeTitles = true

        let moreNavController = NavigationController()
        moreNavController.tabBarItem.title = .localized("tab_title_more")
        moreNavController.tabBarItem.image = UIImage(named: "ic_more")
        moreNavController.navigationBar.prefersLargeTitles = true

        let tabBarController = TabBarController()
        tabBarController.viewControllers = [
            todayNavController,
            orientateNavController,
            meetNavController,
            eatNavController,
            moreNavController
        ]

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

