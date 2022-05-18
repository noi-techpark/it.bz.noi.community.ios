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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if AppFeatureSwitches.isCrashlyticsEnabled {
            FirebaseApp.configure()
        }
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        userNotificationCenter.requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
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
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        
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
        
        let refreshControlAppearanceInsideNavigationBar = UIRefreshControl.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        refreshControlAppearanceInsideNavigationBar.tintColor = .noiPrimaryColor
        
        UISwitch.appearance().onTintColor = .noiSecondaryColor
    }
}

// MARK: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            
            let data = try? JSONSerialization.data(withJSONObject: userInfo)
            let jsonString = String(data: data!, encoding: .utf8)
            
            Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Change this to your preferred presentation option
            completionHandler([.sound, .banner, .list])
        }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler()
    }
    
}

// MARK: MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        let preferredNewsTopic = Bundle.main.preferredNoiNewsTopic
        let allNewsTopics = NoiNewsTopic.allCases
        
        allNewsTopics
            .filter { $0 != preferredNewsTopic}
            .forEach { newsTopic in
                Messaging.messaging().unsubscribe(fromTopic: newsTopic.rawValue) { errorOrNil in
                    if let error = errorOrNil {
                        print("\(newsTopic) unsubscription failed with error: \(error.localizedDescription)")
                    }
                }
            }
        Messaging.messaging().subscribe(toTopic: preferredNewsTopic.rawValue) { errorOrNil in
            if let error = errorOrNil {
                print("\(preferredNewsTopic) subscription failed with error: \(error.localizedDescription)")
            }
        }
    }
    
}
