//
//  AppDelegate.swift
//  NOI Community
//
//  Created by Matteo Matassoni on 30/07/21.
//

import UIKit
#if RELEASE
import Firebase
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
#if RELEASE
        FirebaseApp.configure()
#endif
        configureAppearances()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: Private APIs

private extension AppDelegate {
    func configureAppearances() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .noiBackgroundColor
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.noiPrimaryColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.noiPrimaryColor]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance

        let button = UIBarButtonItemAppearance()
        button.normal.titleTextAttributes = [.foregroundColor: UIColor.noiPrimaryColor]
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.noiPrimaryColor
        navBarAppearance.buttonAppearance = button
        navBarAppearance.backButtonAppearance = button
        let doneButton = UIBarButtonItemAppearance(style: .done)
        doneButton.normal.titleTextAttributes = [.foregroundColor: UIColor.noiPrimaryColor]
        navBarAppearance.doneButtonAppearance = doneButton

        let tabBarAppearance = UITabBarAppearance()
        func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
            itemAppearance.normal.iconColor = .noiDisabled1Color
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.noiDisabled1Color]

            itemAppearance.selected.iconColor = .noiPrimaryColor
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.noiPrimaryColor]
        }
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .noiBackgroundColor
        [
            tabBarAppearance.stackedLayoutAppearance,
            tabBarAppearance.inlineLayoutAppearance,
            tabBarAppearance.compactInlineLayoutAppearance
        ].forEach { setTabBarItemColors($0) }
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
