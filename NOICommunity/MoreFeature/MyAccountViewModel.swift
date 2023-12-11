// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MyAccountViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 29/04/22.
//

import Foundation
import Combine
import AuthClient
import Core
import AppPreferencesClient

// MARK: - MyAccountViewModel

enum MyAccountViewModelError: LocalizedError {
    
    case fetchUserInfoError(underlyingError: Error?)
    case logoutError(underlyingError: Error?)
    
    var errorDescription: String? {
        switch self {
        case .fetchUserInfoError:
            return .localized("user_info_error_msg")
        case .logoutError:
            return .localized("logout_error_msg")
        }
    }
    
    var failureReason: String? {
        switch self {
        case .fetchUserInfoError(let localizedError as LocalizedError):
            return localizedError.localizedDescription
        case .fetchUserInfoError(let nsError as CustomNSError):
            return nsError.localizedDescription
        case .logoutError(let localizedUnderlyingError as LocalizedError):
            return localizedUnderlyingError.errorDescription
        case .logoutError(let nsError as CustomNSError):
            return nsError.localizedDescription
        default:
            return nil
        }
    }
    
}

final class MyAccountViewModel {
    
    @Published var error: Error!
    
    @Published var userInfoIsLoading = false
    @Published var userInfoResult: UserInfo!
    
    @Published var logoutIsLoading = false
    @Published var logoutResult: Void!
    
    private var userInfoRequestCancellable: AnyCancellable?
    private var logoutRequestCancellable: AnyCancellable?
    
    private let authClient: AuthClient
    private let appPreferencesClient: AppPreferencesClient
    
    var requestAccountDeletionHandler: (() -> Void)?
    
    enum CacheKey: Hashable {
        case userInfo
    }
    private var cache: Cache<CacheKey, UserInfo>?
    
    init(
        authClient: AuthClient,
        appPreferencesClient: AppPreferencesClient,
        cache: Cache<CacheKey, UserInfo>? = nil
    ) {
        self.authClient = authClient
        self.appPreferencesClient = appPreferencesClient
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
                    case .failure(AuthError.OAuthTokenInvalidGrant):
                        self?.error = AuthError.OAuthTokenInvalidGrant
                    case .failure(let error):
                        self?.error = MyAccountViewModelError
                            .fetchUserInfoError(underlyingError: error)
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
                    case .failure(AuthError.OAuthTokenInvalidGrant):
                        self?.error = AuthError.OAuthTokenInvalidGrant
                    case .failure(AuthError.userCanceledAuthorizationFlow):
                        self?.error = AuthError.userCanceledAuthorizationFlow
                    case .failure(let error):
                        self?.error = MyAccountViewModelError
                            .logoutError(underlyingError: error)
                    }
                },
                receiveValue: { [weak self] in
                    guard let self
                    else { return }

                    self.appPreferencesClient.delete()

                    self.logoutResult = ()

                    
                    NotificationCenter
                        .default
                        .post(name: logoutNotification, object: self)
                }
            )
    }
    
    func requestAccountDeletion() {
        requestAccountDeletionHandler?()
    }
    
}
