//
//  MyAccountViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 29/04/22.
//

import Foundation
import Combine
import AuthClient
import SwiftCache

// MARK: - MyAccountViewModel

class MyAccountViewModel {
    
    @Published var error: Error!
    
    @Published var userInfoIsLoading = false
    @Published var userInfoResult: UserInfo!
    
    @Published var logoutIsLoading = false
    @Published var logoutResult: Void!
    
    private var userInfoRequestCancellable: AnyCancellable?
    private var logoutRequestCancellable: AnyCancellable?
    
    private let authClient: AuthClient
    
    enum CacheKey: Hashable {
        case userInfo
    }
    private var cache: Cache<CacheKey, UserInfo>?
    
    init(authClient: AuthClient, cache: Cache<CacheKey, UserInfo>? = nil) {
        self.authClient = authClient
        self.cache = cache
        userInfoResult = cache?[.userInfo]
    }
    
    func fetchUserInfo(refresh: Bool = false) {
        let userInfoPublisher: AnyPublisher<UserInfo, Error>

        if !refresh,
           let availableUserInfo = cache?[.userInfo] {
            userInfoIsLoading = false
            
            userInfoPublisher = Just(availableUserInfo)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            userInfoIsLoading = true
            
            userInfoPublisher = authClient.userInfo()
        }
        
        userInfoRequestCancellable = userInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.userInfoIsLoading = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] in
                    guard let self = self
                    else { return }
                    
                    self.userInfoResult = $0
                    self.cache?[.userInfo] = $0
                }
            )
    }
    
    func logout() {
        logoutIsLoading = true
        
        logoutRequestCancellable = authClient.endSession()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.logoutIsLoading = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] in
                    self?.logoutResult = ()
                    
                    NotificationCenter
                        .default
                        .post(name: logoutNotification, object: self)
                }
            )
    }
    
}
