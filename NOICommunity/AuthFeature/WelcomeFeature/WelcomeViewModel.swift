// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  WelcomeViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/04/22.
//

import Foundation
import UIKit
import Combine

// MARK: - WelcomePage

struct WelcomePage: Hashable {
    let backgroundImageName: String
    let title: String
    let description: String
}

// MARK: - WelcomeViewModel

final class WelcomeViewModel {
    
    private let loginSubject: PassthroughSubject<Void, Never> = .init()
    private(set) lazy var startLoginPublisher = loginSubject.eraseToAnyPublisher()
    
    private let signUpSubject: PassthroughSubject<Void, Never> = .init()
    private(set) lazy var startSignUpPublisher = signUpSubject.eraseToAnyPublisher()

    private let navigateToAppPrivacySubject: PassthroughSubject<Void, Never> = .init()
    private(set) lazy var navigateToAppPrivacyPublisher = navigateToAppPrivacySubject.eraseToAnyPublisher()
        
    private(set) var pages: [WelcomePage]

    @Published private(set) var isLoginButtonEnabled = false
    @Published private(set) var isSignUpButtonEnabled = false

    @Published var isPrivacyToggleOn = false {
        didSet {
            isLoginButtonEnabled = isPrivacyToggleOn
            isSignUpButtonEnabled = isPrivacyToggleOn
        }
    }

    init(with pages: [WelcomePage]) {
        self.pages = pages
    }
    
    func index(of page: WelcomePage) -> Int? {
        pages.firstIndex(of: page)
    }
    
    func startLogin() {
        guard isLoginButtonEnabled
        else { return }

        loginSubject.send()
    }
    
    func startSignUp() {
        guard isSignUpButtonEnabled
        else { return }

        signUpSubject.send()
    }

    func navigateToAppPrivacy() {
        navigateToAppPrivacySubject.send()
    }
    
}
