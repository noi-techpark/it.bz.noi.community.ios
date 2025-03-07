// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  SceneDelegate.swift
//  NOI Community
//
//  Created by Matteo Matassoni on 30/07/21.
//

import UIKit
import AppAuth
import EventShortClient
import AppPreferencesClientLive
import EventShortTypesClient
import EventShortTypesClientLive
import Core
import AuthClientLive
import AuthStateStorageClient
import ArticlesClient
import ArticleTagsClient
import PeopleClientLive
import VimeoOEmbedClient
import VimeoVideoThumbnailClient

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
    lazy var articleTagsCache = Cache<String, ArticleTagListResponse>()
    
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
			eventShortClient: EventShortClientImplementation(
				baseURL: EventsFeatureConstants.clientBaseURL,
				transport: URLSession.shared
			),
            eventShortTypesClient: {
                if let fileURL = Bundle.main.url(
                    forResource: "EventShortTypes",
                    withExtension: "json"
                ) {
                    return .live(
                        baseURL: EventsFeatureConstants.clientBaseURL,
                        memoryCache: cache,
                        diskCacheFileURL: fileURL
                    )
                } else {
                    return .live(baseURL: EventsFeatureConstants.clientBaseURL)
                }
            }(),
			articleClient: ArticlesClientImplementation(
				baseURL: EventsFeatureConstants.clientBaseURL,
				transport: URLSession.shared
            ), 
            articleTagsClient: {
                if let fileURL = Bundle.main.url(
                    forResource: "ArticleTags",
                    withExtension: "json"
                ) {
                    return ArticleTagsClientImplementation(
                        baseURL: EventsFeatureConstants.clientBaseURL,
                        transport: URLSession.shared,
                        memoryCache: articleTagsCache,
                        diskCacheFileURL: fileURL
                    )
                } else {
                    return ArticleTagsClientImplementation(
                        baseURL: EventsFeatureConstants.clientBaseURL,
                        transport: URLSession.shared,
                        memoryCache: articleTagsCache
                    )
                }
            }(),
			peopleClient: .live(baseURL: MeetConstant.clientBaseURL),
			vimeoVideoThumbnailClient: VimeoVideoThumbnailClientImplementation(vimeoOEmbedClient: VimeoOEmbedClientImplementation(transport: URLSession.shared))
				.cached()
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

        let window = {
            let window = BaseWindow(windowScene: windowScene)
            window.dependencyContainer = dependencyContainer
            return window
        }()
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
