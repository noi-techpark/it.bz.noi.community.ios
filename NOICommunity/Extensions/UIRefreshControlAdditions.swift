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
            guard newIsLoading != isLoading
            else { return }
            
            if newIsLoading {
                beginRefreshing(forced: true)
            } else {
                endRefreshing()
            }
        }
    }
    
    func beginRefreshing(forced: Bool) {
        guard !isRefreshing
        else { return }
        
        guard forced
        else {
            beginRefreshing()
            return
        }
        
        if let scrollView = superview as? UIScrollView {
            var newContentOffset = scrollView.contentOffset
            newContentOffset.y -= frame.height
            scrollView.setContentOffset(newContentOffset, animated: true)
        }
        beginRefreshing()
    }
    
}
