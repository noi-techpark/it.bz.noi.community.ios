// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AuthConstants.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 03/05/22.
//

import Foundation

enum AuthConstant {
    
    private static let NOIOAuth2BaseURL: URL = {
#if TESTINGMACHINE_OAUTH
        return URL(string: "https://auth.opendatahub.testingmachine.eu/auth/realms/noi-community/")!
#else
        return URL(string: "https://auth.opendatahub.com/auth/realms/noi-community/")!
#endif
    }()
    
    static let issuerURL: URL = {
        NOIOAuth2BaseURL
    }()
    
    static let signupURL: URL = {
        var urlComponents = URLComponents(
            url: NOIOAuth2BaseURL,
            resolvingAgainstBaseURL: false
        )!
        urlComponents.path += "protocol/openid-connect/registrations"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: "https://noi.bz.it"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid"),
        ]
        return urlComponents.url!
    }()
    
    //static let clientID = "it.bz.noi.community"

    static let clientID = {
        return "community-app"
    }()
    
    static let redirectURI = URL(string: "noi-community://oauth2redirect/login-callback")!
    
    static let endSessionURI = URL(string: "noi-community://oauth2redirect/end_session-callback")!
    
}
