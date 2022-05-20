//
//  AppDelegate.swift
//  NOI Community
//
//  Created by Matteo Matassoni on 30/07/21.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: UIApplication Lifecycle
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        configurePushNotifications(application: application)
        
        configureAppearances()
        
        handle(launchOptions: launchOptions)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    // MARK: Remote Notification Registration's Callbacks
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // FCM stuff
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("\(#function) error: \(error.localizedDescription)")
    }
}

// MARK: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        handleWillPresent(
            notificationPayload: notification.request.content.userInfo
        )
        
        completionHandler([.sound, .banner, .list])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handle(
            notificationPayload: response.notification.request.content.userInfo
        )
        
        completionHandler()
    }
    
}

// MARK: MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        updateFCMTopicsSubscriptions()
    }
    
}

// MARK: Private APIs

private extension AppDelegate {
    
    func configurePushNotifications(application: UIApplication) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        userNotificationCenter.requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
    
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
        
        let refreshControlAppearanceInsideNavigationBar = UIRefreshControl.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        refreshControlAppearanceInsideNavigationBar.tintColor = .noiPrimaryColor
        
        UISwitch.appearance().onTintColor = .noiSecondaryColor
    }
    
    func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let notificationPayload = launchOptions?[.remoteNotification] as? [AnyHashable : Any] {
            handle(notificationPayload: notificationPayload)
        }
    }
    
    func handle(notificationPayload: [AnyHashable: Any]) {
        // FCM stuff
        Messaging.messaging().appDidReceiveMessage(notificationPayload)
        
        // App stuff
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        else { return }
        
        sceneDelegate.rootCoordinator.handle(
            notificationPayload: notificationPayload
        )
    }
    
    func handleWillPresent(notificationPayload: [AnyHashable: Any]) {
        // FCM stuff
        Messaging.messaging().appDidReceiveMessage(notificationPayload)
        
        // App stuff
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        else { return }
        
        sceneDelegate.rootCoordinator.handleWillPresent(
            notificationPayload: notificationPayload
        )
    }
    
    func updateFCMTopicsSubscriptions() {
        let preferredNewsTopic = Bundle.main.preferredNoiNewsTopic
        let allNewsTopics = NoiNewsTopic.allCases
        
        // Unsubscribe user from all news topic except the preferred one
        allNewsTopics
            .filter { $0 != preferredNewsTopic}
            .forEach { newsTopic in
                Messaging.messaging().unsubscribe(fromTopic: newsTopic.rawValue) { errorOrNil in
                    if let error = errorOrNil {
                        print("\(newsTopic) unsubscription failed with error: \(error.localizedDescription)")
                    }
                }
            }
        
        // Subscribe user to the preferred news topic
        Messaging.messaging().subscribe(toTopic: preferredNewsTopic.rawValue) { errorOrNil in
            if let error = errorOrNil {
                print("\(preferredNewsTopic) subscription failed with error: \(error.localizedDescription)")
            }
        }
    }
    
}
