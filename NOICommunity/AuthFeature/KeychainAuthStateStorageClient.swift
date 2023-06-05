// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  KeychainAuthStateStorageClient.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 02/05/22.
//

import Foundation
import AppAuth
import KeychainAccess
import AuthStateStorageClient

// MARK: - KeychainAuthStateStorageClient

final class KeychainAuthStateStorageClient: AuthStateStorageClient {
    
    private let keychain: Keychain
    
    init(keyChainAccessGroup accessGroup: String) {
        keychain = Keychain(accessGroup: accessGroup)
    }
    
    private var _state: OIDAuthState?
    
    
    // MARK: AuthStateStorageClient
    
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

// MARK: Private APIs

private let authStateKey = "authState"

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
