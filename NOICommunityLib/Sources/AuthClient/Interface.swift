//
//  Interface.swift
//  AuthClient
//
//  Created by Matteo Matassoni on 21/04/22.
//

import Foundation
import Combine

// MARK: - UserInfo

///  UserInfo Response. See https://openid.net/specs/openid-connect-basic-1_0-23.html#UserInfoResponse.
public struct UserInfo {
    
    /// Subject's unique identifier
    public let sub: String
    
    /// Full name
    public let name: String?
    
    /// Surname(s) or last name(s)
    public let familyName: String?
    
    /// Given name(s) or first name(s)
    public let givenName: String?
    
    /// Middle name(s)
    public let middleName: String?
    
    /// End-User's preferred e-mail address. This value MUST NOT be relied upon to be unique by the RP.
    public let email: String?
}

// MARK: Codable

extension UserInfo: Codable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case sub
        case name
        case givenName = "given_name"
        case familyName = "family_name"
        case middleName = "middle_name"
        case email
    }
    
}

// MARK: Hashable

extension UserInfo: Hashable {
    
}

// MARK: - AuthError

public enum AuthError: Error, Hashable {
    case userCanceledAuthorizationFlow
    case OAuthTokenInvalidGrant
}

// MARK: - AuthClient

public struct AuthClient {
    
    public var accessToken: () -> AnyPublisher<String, Error>
    
    public var userInfo: () -> AnyPublisher<UserInfo, Error>
    
    public var endSession: () -> AnyPublisher<Void, Error>
    
    public init(
        accessToken: @escaping () -> (AnyPublisher<String, Error>),
        userInfo: @escaping() -> AnyPublisher<UserInfo, Error>,
        endSession: @escaping () -> (AnyPublisher<Void, Error>)
    ) {
        self.accessToken = accessToken
        self.userInfo = userInfo
        self.endSession = endSession
    }
}
