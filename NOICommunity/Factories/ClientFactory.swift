// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ClientFactory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/04/22.
//

import Foundation
import AppPreferencesClient
import AuthStateStorageClient
import AuthClient
import ArticlesClient
import PeopleClient

protocol ClientFactory {
    
    func makeAppPreferencesClient() -> AppPreferencesClient
    
    func makeIsAutorizedClient() -> () -> Bool
    
    func makeHasAccessGrantedClient() -> () -> Bool
    
    func makeAuthClient() -> AuthClient
    
    func makeArticlesClient() -> ArticlesClient
    
    func makePeopleClient() -> PeopleClient
    
}
