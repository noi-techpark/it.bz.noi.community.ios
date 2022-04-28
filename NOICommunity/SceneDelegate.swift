//
//  SceneDelegate.swift
//  NOI Community
//
//  Created by Matteo Matassoni on 30/07/21.
//

import UIKit
import EventShortClientLive
import AppPreferencesClientLive
import EventShortTypesClient
import EventShortTypesClientLive
import SwiftCache
import AppAuth
import AuthClientLive
import KeychainAccess
import AuthStateStorageClient

let issuer = URL(string: "https://auth.opendatahub.testingmachine.eu/auth/realms/noi/")!
//let userInfoEndpoint = URL(string: "https://auth.opendatahub.testingmachine.eu/auth/realms/noi/protocol/openid-connect/userinfo")!
let clientID = "it.bz.noi.community"
let redirectURI = URL(string: "noi-community://oauth2redirect/login-callback")!

#if DEBUG
private let accessGroupKey = "24PN5XJ85Y.it.dimension.noi-community"
#else
private let accessGroupKey = "5V2Q9SWB7H.it.bz.noi.community"
#endif

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    lazy var cache: Cache<EventShortTypesClient.CacheKey, [EventsFilter]> = Cache()
    
    lazy var dependencyContainer: DependencyContainer = {
        let tokenStorage = KeychainAuthStateStorageClient(
            keyChainAccessGroup: accessGroupKey
        )
        return DependencyContainer(
            appPreferencesClient: .live(),
            isAutorizedClient: {
                tokenStorage.state?.isAuthorized ?? false
            },
            authClient: .live(
                client: .init(
                    issuer: issuer,
                    clientID: clientID,
                    redirectURL: redirectURI
                ),
                context: self,
                tokenStorage: tokenStorage
            ),
            eventShortClient: .live(),
            eventShortTypesClient: {
                if let fileURL = Bundle.main.url(
                    forResource: "EventShortTypes",
                    withExtension: "json"
                ) {
                    return .live(
                        memoryCache: cache,
                        diskCacheFileURL: fileURL
                    )
                } else {
                    return .live()
                }
            }()
        )
    }()
    
    var rootCoordinator: RootCoordinator!
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene)
        else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        rootCoordinator = RootCoordinator(
            window: window,
            dependencyContainer: dependencyContainer
        )
        rootCoordinator.start()
        window.makeKeyAndVisible()
    }
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let url = URLContexts.first?.url
        else { return }
        
        
        if let authorizationFlow = self.currentAuthorizationFlow,
           authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            currentAuthorizationFlow = nil
        }
    }
    
}

// MARK: AuthContext

extension SceneDelegate: AuthContext {
    
    var presentationContext: () -> UIViewController {
        { (self.window?.rootViewController)! }
    }
    
}

// MARK: - Keychain

private let authStateKey = "authState"

// MARK: KeychainAuthStateStorageClient

private class KeychainAuthStateStorageClient: AuthStateStorageClient  {
    
    private let keychain: Keychain
    
    init(keyChainAccessGroup accessGroup: String) {
        keychain = Keychain(accessGroup: accessGroup)
    }
    
    private var _state: OIDAuthState?
    
    var state: OIDAuthState? {
        get {
            if let memoryState = _state {
                return memoryState
            } else {
                let keychainState = loadFromKeychain()
                _state = keychainState
                return keychainState
            }
        }
        
        set(newState) {
            guard _state != newState
            else { return }
            
            _state = newState
            saveInKeychain(newState)
        }
    }
}

private extension KeychainAuthStateStorageClient {
    
    func loadFromKeychain() -> OIDAuthState? {
        var data: Data?
        do {
            data = try keychain.getData(authStateKey)
        } catch {
            print("loadAuthState did fail: \(error)")
        }
        
        guard let nonOptData = data
        else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(nonOptData) as? OIDAuthState
        } catch {
            print("loadAuthState did fail: \(error)")
            return nil
        }
    }
    
    func saveInKeychain(_ newState: OIDAuthState?) {
        do {
            let authStateData = try newState.map {
                try NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: true)
            }
            if let nonOptAuthStateData = authStateData {
                try keychain.set(nonOptAuthStateData, key: authStateKey)
            } else {
                try keychain.remove(authStateKey)
            }
        } catch {
            print("saveAuthState did fail: \(error)")
        }
    }
    
}
