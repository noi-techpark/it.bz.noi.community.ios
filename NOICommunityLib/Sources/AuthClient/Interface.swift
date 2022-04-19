//
//  Interface.swift
//  AuthClient
//
//  Created by Matteo Matassoni on 21/04/22.
//

import Foundation
import Combine

public enum AuthError: Error {
    case userCanceledAuthorizationFlow
}

public struct AuthClient {
    
    public var accessToken: () -> AnyPublisher<String, Error>
    
    public init(
        accessToken: @escaping () -> (AnyPublisher<String, Error>)
    ) {
        self.accessToken = accessToken
    }
}
