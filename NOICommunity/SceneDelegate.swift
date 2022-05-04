//
//  SceneDelegate.swift
//  NOI Community
//
//  Created by Matteo Matassoni on 30/07/21.
//

import UIKit
import AppAuth
import SwiftJWT
import EventShortClientLive
import AppPreferencesClientLive
import EventShortTypesClient
import EventShortTypesClientLive
import SwiftCache
import AuthClientLive
import AuthStateStorageClient

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
                guard let authState = tokenStorage.state
                else { return false }
                
                
                return authState.isAuthorized
            },
            hasAccessGrantedClient: {
                guard let authState = tokenStorage.state,
                      let accessToken = authState.lastTokenResponse?.accessToken
                else { return false }
                
                return self.verify(
                    jwt: accessToken,
                    roles: [AuthConstant.accessGrantedRole],
                    of: AuthConstant.clientID
                )
            },
            authClient: .live(
                client: .init(
                    issuer: AuthConstant.issuerURL,
                    clientID: AuthConstant.clientID,
                    redirectURI: AuthConstant.redirectURI,
                    endSessionURI: AuthConstant.endSessionURI
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


// MARK: Private APIs

private extension SceneDelegate {
    
    func verify(
        jwt: String,
        roles: [String],
        of clientID: String
    ) -> Bool {
        struct MyClaims: Claims {
            
            let resourceAccess: [String: RolesContainer]
            
            private enum CodingKeys: String, CodingKey {
                case resourceAccess = "resource_access"
            }
            
            struct RolesContainer: Codable {
                var roles: [String]
            }
        }
        
        guard let newJWT = try? JWT<MyClaims>(jwtString: jwt)
        else {
            return false
        }
        
        let jwtRoles = Set(newJWT.claims.resourceAccess[clientID]?.roles ?? [])
        let verifyRoles = Set(roles)
        return jwtRoles.intersection(verifyRoles) == verifyRoles
    }
    
}
