//
//  Live.swift
//  AuthClientLive
//
//  Created by Matteo Matassoni on 21/04/22.
//

import Foundation
import Combine
import UIKit
import AppAuth
import AuthClient
import AuthStateStorageClient

// MARK: - AuthLiveError

enum AuthLiveError: Error {
    case shouldNeverHappen
    case noViewController
    case invalidGrant
    case noPreviousAuthState
}

// MARK: - OpenIDConfiguration

public struct OpenIDConfiguration {
    
    var authorizationEndpoint: URL
    var tokenEndpoint: URL
    var clientID: String
    var clientSecret: String
    var redirectURL: URL
    
    public init(
        authorizationEndpoint: URL,
        tokenEndpoint: URL,
        clientID: String,
        clientSecret: String,
        redirectURL: URL
    ) {
        self.authorizationEndpoint = authorizationEndpoint
        self.tokenEndpoint = tokenEndpoint
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURL = redirectURL
    }
}

// MARK: - AuthContext

public protocol AuthContext {
    var presentationContext: () -> UIViewController { get }
}

// MARK: - EventShortClient+Live

public extension AuthClient {
    
    static func live<T: AuthStateStorageClient>(
        client: OpenIDConfiguration,
        context: AuthContext,
        tokenStorage: T?
    ) -> Self where T.AuthState == OIDAuthState {
        let stateChangeDelegate = StateChangeDelegate(tokenStorage: tokenStorage)
        
        var authState: OIDAuthState? = tokenStorage?.state {
            didSet {
                authState?.stateChangeDelegate = stateChangeDelegate
                if let authState = authState {
                    authState.stateChangeDelegate?.didChange(authState)
                }
                authState?.errorDelegate = stateChangeDelegate
            }
        }
        
        var authSession: OIDExternalUserAgentSession? {
            didSet {
                debugPrint("Acquired new auth session: \(String(describing: authSession))")
            }
        }
        
        return Self(
            accessToken: {
                Self.performActionWithFreshToken(authState: authState)
                    .catch { (error: Error) -> AnyPublisher<String, Error> in
                        debugPrint("Full login required")
                        
                        let (newAuthSession, ssoPublisher) = Self.startSSO(
                            config: client,
                            from: context.presentationContext()
                        )
                        authSession = newAuthSession
                        
                        return ssoPublisher.map { newAuthState in
                            authState = newAuthState
                            return newAuthState.refreshToken!
                        }
                        .eraseToAnyPublisher()
                    }
                    .mapError { error in
                        switch error {
                        case let userCanceledAuthorizationFlow as NSError
                            where userCanceledAuthorizationFlow.domain == OIDGeneralErrorDomain &&
                            userCanceledAuthorizationFlow.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue:
                            return AuthError.userCanceledAuthorizationFlow
                        default:
                            return error
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
}

// MARK: Private APIs

private extension AuthClient {
    
    static func performActionWithFreshToken(
        authState: OIDAuthState?
    ) -> AnyPublisher<String, Error> {
        Future { promise in
            guard let authState = authState
            else {
                return promise(.failure(AuthLiveError.noPreviousAuthState))
            }
            debugPrint("using existing authState")
            
            authState.performAction { accessToken, idToken, error in
                let result: Result<String, Error>
                
                switch (accessToken, error) {
                case (let accessToken?, _):
                    result = .success(accessToken)
                case (_, let error?):
                    result = .failure(error)
                case (nil, nil):
                    result = .failure(AuthLiveError.shouldNeverHappen)
                }
                
                switch result {
                case .success:
                    debugPrint("accessToken acquired")
                case .failure(let error):
                    debugPrint("accessToken not acquired due: \(error.localizedDescription)")
                }
                
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func discoverConfiguration(
        of issuer: URL
    ) -> AnyPublisher<OIDServiceConfiguration, Error> {
        Future { promise in
            OIDAuthorizationService.discoverConfiguration(
                forIssuer: issuer
            ) { configuration, error in
                let result: Result<OIDServiceConfiguration, Error>
                
                switch (configuration, error) {
                case (let configuration?, _):
                    result = .success(configuration)
                case (_, let error?):
                    result = .failure(error)
                case (nil, nil):
                    result = .failure(AuthLiveError.shouldNeverHappen)
                }
                
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func startSSO(
        config: OpenIDConfiguration,
        from presentationContext: UIViewController
    ) -> (
        OIDExternalUserAgentSession,
        AnyPublisher<OIDAuthState, Error>
    ){
        let subject = PassthroughSubject<OIDAuthState, Error>()
        let request = OIDAuthorizationRequest(
            configuration: OIDServiceConfiguration(
                authorizationEndpoint: config.authorizationEndpoint,
                tokenEndpoint: config.tokenEndpoint
            ),
            clientId: config.clientID,
            clientSecret: config.clientSecret,
            scopes: [OIDScopeOpenID, OIDScopeProfile, "roles"],
            redirectURL: config.redirectURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: ["prompt": "login"]
        )
        
        let authSession = OIDAuthState.authState(
            byPresenting: request,
            presenting: presentationContext
        ) { authState, error in
            switch (authState, error) {
            case (let authState?, _):
                subject.send(authState)
            case (_, let error?):
                subject.send(completion: .failure(error))
            case (nil, nil):
                subject.send(completion: .failure(AuthLiveError.shouldNeverHappen))
            }
        }
        
        return (
            authSession,
            subject.eraseToAnyPublisher()
        )
    }
    
    final class StateChangeDelegate<T: AuthStateStorageClient>: NSObject, OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate where T.AuthState == OIDAuthState {
        
        private var tokenStorage: T?
        
        init(tokenStorage: T?) {
            self.tokenStorage = tokenStorage
        }
        
        func didChange(_ state: OIDAuthState) {
            tokenStorage?.state = state
        }
        
        func authState(
            _ state: OIDAuthState,
            didEncounterAuthorizationError error: Error
        ) {
            debugPrint("\(#function) \(error.localizedDescription)")
        }
    }
    
}

extension OIDAuthState: AuthStateType {}
