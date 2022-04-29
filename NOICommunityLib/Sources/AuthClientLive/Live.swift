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
import SwiftJWT
import AuthClient
import AuthStateStorageClient

// MARK: - Roles

private enum KnownRole: String {
    case accessGranted = "ACCESS_GRANTED"
}

// MARK: - AuthLiveError

enum AuthLiveError: Error {
    case shouldNeverHappen
    case noViewController
    case invalidGrant
    case noPreviousAuthState
}

// MARK: - OpenIDConfiguration

public struct OpenIDConfiguration {
    
    var issuer: URL
    var clientID: String
    var redirectURL: URL
    
    var logoutURL: URL {
        redirectURL
    }
    
    public init(
        issuer: URL,
        clientID: String,
        redirectURL: URL
    ) {
        self.issuer = issuer
        self.clientID = clientID
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
        tokenStorage: T?,
        urlSession: URLSession = .shared
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
                performActionWithFreshToken(authState: authState)
                    .catch { (error: Error) -> AnyPublisher<String, Error> in
                        debugPrint("Full login required")
                        
                        return startSSO(
                            config: client,
                            from: context.presentationContext()
                        )
                        .tryMap { (newSession, newAuthState) in
                            let accessToken = newAuthState.lastTokenResponse!.accessToken!
                            
                            try verify(
                                jwt: accessToken,
                                roles: [KnownRole.accessGranted.rawValue],
                                of: client.clientID
                            )
                            
                            authSession = newSession
                            authState = newAuthState
                            return accessToken
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
            },
            userInfo: {
                performActionWithFreshToken(authState: authState)
                    .flatMap { accessToken in
                        userInfo(
                            authState: authState,
                            accessToken: accessToken,
                            urlSession: urlSession
                        )
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            },
            endSession: {
                let (newSession, endSessionPublisher) = endSession(
                    config: client,
                    authState: authState,
                    from: context.presentationContext()
                )
                authSession = newSession
                return endSessionPublisher
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
                    .map {
                        tokenStorage?.state = nil
                        return $0
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
        configuration: OIDServiceConfiguration,
        clientID: String,
        redirectURL: URL,
        from presentationContext: UIViewController
    ) -> (OIDExternalUserAgentSession, AnyPublisher<OIDAuthState, Error>) {
        let subject = PassthroughSubject<OIDAuthState, Error>()
        
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: clientID,
            clientSecret: nil,
            scopes: [OIDScopeOpenID, OIDScopeProfile, "roles"],
            redirectURL: redirectURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: ["prompt": "login"]
        )
        
        let session = OIDAuthState.authState(
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
        
        return (session, subject.eraseToAnyPublisher())
    }
    
    static func startSSO(
        config: OpenIDConfiguration,
        from presentationContext: UIViewController
    ) -> AnyPublisher<(OIDExternalUserAgentSession, OIDAuthState), Error> {
        discoverConfiguration(of: config.issuer)
            .flatMap { (discoveredConfig: OIDServiceConfiguration) -> AnyPublisher<(OIDExternalUserAgentSession, OIDAuthState), Error> in
                let (newSession, ssoPublisher) = startSSO(
                    configuration: discoveredConfig,
                    clientID: config.clientID,
                    redirectURL: config.redirectURL,
                    from: presentationContext
                )
                return Just(newSession)
                    .setFailureType(to: Error.self)
                    .zip(ssoPublisher)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    static func verify(
        jwt: String,
        roles: [String],
        of clientID: String
    ) throws {
        struct MyClaims: Claims {
            
            let resourceAccess: [String:RolesContainer]
            
            private enum CodingKeys: String, CodingKey {
                case resourceAccess = "resource_access"
            }
            
            struct RolesContainer: Codable {
                var roles: [String]
            }
        }
        
        let newJWT = try JWT<MyClaims>(jwtString: jwt)
        let jwtRoles = Set(newJWT.claims.resourceAccess[clientID]?.roles ?? [])
        let verifyRoles = Set(roles)
        guard jwtRoles.intersection(verifyRoles) == verifyRoles
        else { throw AuthError.invalidUserRole }
    }
    
    static func userInfo(
        userInfoEndpoint: URL,
        accessToken: String,
        urlSession: URLSession
    ) -> AnyPublisher<UserInfo, Error> {
        var urlRequest = URLRequest(url: userInfoEndpoint)
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: UserInfo.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    static func userInfo(
        authState: OIDAuthState?,
        accessToken: String,
        urlSession: URLSession
    ) -> AnyPublisher<UserInfo, Error> {
        guard let authState = authState
        else {
            return Fail(error: AuthLiveError.noPreviousAuthState)
                .eraseToAnyPublisher()
        }
        
        guard let userInfoEndpoint = authState.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint
        else {
            return Fail(error: AuthLiveError.shouldNeverHappen)
                .eraseToAnyPublisher()
        }
        
        return userInfo(
            userInfoEndpoint: userInfoEndpoint,
            accessToken: accessToken,
            urlSession: urlSession
        )
    }
    
    static func endSession(
        config: OpenIDConfiguration,
        authState: OIDAuthState?,
        from presentationContext: UIViewController
    ) -> (OIDExternalUserAgentSession?, AnyPublisher<Void, Error>) {
        guard let authState = authState,
              let currentIdToken = authState.lastTokenResponse?.idToken
        else {
            return (
                nil,
                Fail(error: AuthLiveError.noPreviousAuthState)
                    .eraseToAnyPublisher()
            )
        }
        
        guard let userAgent = OIDExternalUserAgentIOS(presenting: presentationContext)
        else {
            return (
                nil,
                Fail(error: AuthLiveError.shouldNeverHappen)
                    .eraseToAnyPublisher()
            )
        }
        
        let logoutRequest: OIDEndSessionRequest
        
        if let state = authState.lastAuthorizationResponse.state {
            logoutRequest = OIDEndSessionRequest(
                configuration: .init(
                    discoveryDocument: authState.lastAuthorizationResponse.request.configuration.discoveryDocument!
                ),
                idTokenHint: currentIdToken,
                postLogoutRedirectURL: config.logoutURL,
                state: state,
                additionalParameters: nil
            )
        } else {
            logoutRequest = OIDEndSessionRequest(
                configuration: .init(
                    discoveryDocument: authState.lastAuthorizationResponse.request.configuration.discoveryDocument!
                ),
                idTokenHint: currentIdToken,
                postLogoutRedirectURL: config.logoutURL,
                additionalParameters: nil
            )
        }
        
        let subject = PassthroughSubject<Void, Error>()
        
        let session = OIDAuthorizationService.present(
            logoutRequest,
            externalUserAgent: userAgent
        ) { endSessionResponse, error in
            switch (endSessionResponse, error) {
            case (let endSessionResponse?, _):
                subject.send()
            case (_, let error?):
                subject.send(completion: .failure(error))
            case (nil, nil):
                subject.send(completion: .failure(AuthLiveError.shouldNeverHappen))
            }
        }
        
        return (session, subject.eraseToAnyPublisher())
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
