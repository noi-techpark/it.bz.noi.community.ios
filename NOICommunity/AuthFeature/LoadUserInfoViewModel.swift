// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  LoadUserInfoViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/12/23.
//

import Foundation
import Combine
import AuthClient
import Core
import AppPreferencesClient
import PeopleClient

// MARK: - LoadUserInfoViewModel

enum LoadUserInfoError: Error {
    case accessNotGranted
    case outsider
}

final class LoadUserInfoViewModel {
    
    private(set) lazy var resultPublisher = resultSubject
        .eraseToAnyPublisher()

    private lazy var resultSubject: PassthroughSubject<Void, Error> = .init()
    
    private var userInfoRequestCancellable: AnyCancellable?
    
    private let authClient: AuthClient
    private let hasAccessGrantedClient: HasAccessGrantedClient
    private let peopleClient: PeopleClient
    private let appPreferencesClient: AppPreferencesClient
    
    var requestAccountDeletionHandler: (() -> Void)?
    
    private var cache: Cache<CacheKey, UserInfo>?
    
    init(
        authClient: AuthClient,
        hasAccessGrantedClient: @escaping HasAccessGrantedClient,
        peopleClient: PeopleClient,
        appPreferencesClient: AppPreferencesClient,
        cache: Cache<CacheKey, UserInfo>? = nil
    ) {
        self.authClient = authClient
        self.hasAccessGrantedClient = hasAccessGrantedClient
        self.peopleClient = peopleClient
        self.appPreferencesClient = appPreferencesClient
        self.cache = cache
    }
    
    func fetchVerifiedUserInfo() {
        guard hasAccessGrantedClient()
        else {
            resultSubject.send(completion: .failure(LoadUserInfoError.accessNotGranted))
            return
        }

        let userInfoPublisher = authClient.userInfo()
        let peoplePublisher = authClient.accessToken()
            .flatMap { [peopleClient] accessToken in
                peopleClient.people(accessToken)
            }
            .eraseToAnyPublisher()

        let verifiedUserInfoPublisher = userInfoPublisher
            .flatMap { userInfo in
                return peoplePublisher
                    .replaceError(with: [])
                    .contains { people in
                        people.contains { person in
                            guard let userEmail = userInfo.email
                            else { return false }

                            return userEmail == person.email || userEmail.hasSuffix("@dimension.it")
                        }
                    }
                    .setFailureType(to: Error.self)
                    .flatMap { verified in
                        guard verified
                        else {
                            return Fail(
                                outputType: UserInfo.self,
                                failure: LoadUserInfoError.outsider as Error
                            )
                            .eraseToAnyPublisher()
                        }

                        return Just(userInfo)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
            }

        userInfoRequestCancellable = verifiedUserInfoPublisher
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.resultSubject.send(completion: completion)
                },
                receiveValue: { [weak self] userInfo in
                    guard let self = self
                    else { return }

                    self.cache?[.userInfo] = userInfo
                }
            )
    }
}
