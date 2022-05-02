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

protocol ClientFactory {
    
    func makeAppPreferencesClient() -> AppPreferencesClient
    
    func makeIsAutorizedClient() -> () -> Bool
    
    func makeHasAccessGrantedClient() -> () -> Bool
    
    func makeAuthClient() -> AuthClient
    
}
