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
            setIsLoading(newIsLoading, scrollToTop: false)
        }
    }
    
    func beginRefreshing(forced: Bool, scrollToTop: Bool) {
        guard !isRefreshing
        else { return }
        
        guard forced
        else {
            beginRefreshing()
            return
        }
        
        if let scrollView = superview as? UIScrollView {
            var newContentOffset = scrollView.contentOffset
            if scrollToTop {
                newContentOffset = scrollView.contentOffset(for: .top)
            }
            newContentOffset.y -= frame.height
            scrollView.setContentOffset(newContentOffset, animated: true)
        }
        beginRefreshing()
    }
    
    func setIsLoading(_ isLoading: Bool, scrollToTop: Bool) {
        guard self.isLoading != isLoading
        else { return }
        
        if isLoading {
            beginRefreshing(forced: true, scrollToTop: scrollToTop)
        } else {
            endRefreshing()
        }
    }
    
}
