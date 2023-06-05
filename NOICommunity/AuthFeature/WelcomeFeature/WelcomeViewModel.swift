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
    lazy var startLoginPublisher = loginSubject.eraseToAnyPublisher()
    
    private let signUpSubject: PassthroughSubject<Void, Never> = .init()
    lazy var startSignUpPublisher = signUpSubject.eraseToAnyPublisher()
        
    private(set) var pages: [WelcomePage]
    
    init(with pages: [WelcomePage]) {
        self.pages = pages
    }
    
    func index(of page: WelcomePage) -> Int? {
        pages.firstIndex(of: page)
    }
    
    func startLogin() {
        loginSubject.send()
    }
    
    func startSignUp() {
        signUpSubject.send()
    }
    
}
