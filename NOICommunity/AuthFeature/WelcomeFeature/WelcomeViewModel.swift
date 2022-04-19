//
//  WelcomeViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/04/22.
//

import Foundation
import Combine

// MARK: - WelcomePage

struct WelcomePage: Hashable {
    let backgroundImageURL: URL
    let title: String
    let description: String
}

// MARK: - WelcomeViewModel

final class WelcomeViewModel {
    
    private let loginSubject = PassthroughSubject<Void, Never>()
    lazy var startLoginPublisher = loginSubject.eraseToAnyPublisher()
    
    private let signUpSubject = PassthroughSubject<Void, Never>()
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
