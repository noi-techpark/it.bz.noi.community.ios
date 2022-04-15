//
//  WelcomePagesViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/04/22.
//

import Foundation

// MARK: - WelcomePage

struct WelcomePage: Hashable {
    let backgroundImageURL: URL
    let title: String
    let description: String
}

// MARK: - WelcomePagesViewModel

final class WelcomePagesViewModel {
    
    private(set) var pages: [WelcomePage]
    
    init(with pages: [WelcomePage]) {
        self.pages = pages
    }
    
    func index(of page: WelcomePage) -> Int? {
        pages.firstIndex(of: page)
    }
    
}
