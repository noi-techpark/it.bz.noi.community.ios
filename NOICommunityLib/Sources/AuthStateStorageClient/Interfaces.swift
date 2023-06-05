// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AuthStateStorage.swift
//  AuthStateStorageClient
//
//  Created by Matteo Matassoni on 27/04/22.
//

import Foundation

// MARK: - AuthState

public protocol AuthStateType {
    
    var isAuthorized: Bool { get }
    
}

// MARK: - AuthStateStorage

public protocol AuthStateStorageClient: AnyObject {
    
    associatedtype AuthState = AuthStateType
    
    var state: AuthState? { get set }
    
}

// MARK: - AnyAuthStateStorageClient

public final class AnyAuthStateStorageClient<T: AuthStateType>: AuthStateStorageClient {
    
    private let read: () -> T?
    private let write: (T?) -> Void
    
    public var state: T? {
        get { read() }
        set { write(newValue) }
    }
    
    public init<C: AuthStateStorageClient>(_ client: C)
    where C.AuthState == T {
        read = { client.state }
        write = { client.state = $0 }
    }
    
}
