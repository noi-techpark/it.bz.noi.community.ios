//
//  UIRefreshControlAdditions.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/11/21.
//

import UIKit

extension UIRefreshControl {
    
    var isLoading: Bool {
        get { isRefreshing }
        set(newIsLoading) {
            if newIsLoading {
                beginRefreshing()
            } else {
                endRefreshing()
            }
        }
    }
    
}
