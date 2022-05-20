//
//  UIRefreshControlAdditions.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/11/21.
//

import UIKit
import ObjectiveC

extension NSNumber {
    
    class func numberWithCGFloat(value: CGFloat) -> NSNumber {
        var value = value
        return CFNumberCreate(nil , .cgFloatType, &value)
    }
    
    var cgFloatValue: CGFloat {
        var value: CGFloat = 0
        CFNumberGetValue(self, .cgFloatType, &value)
        return value
    }
    
}

fileprivate extension UIScrollView {
    
    var refreshControlVerticalSpace: CGFloat? {
        get {
            let nsNumber = objc_getAssociatedObject(
                self,
                "refreshControlVerticalSpace"
            ) as? NSNumber
            return nsNumber?.cgFloatValue
        }
        set {
            let nsNumber: NSNumber?
            
            if let newValue = newValue {
                nsNumber = NSNumber.numberWithCGFloat(value: newValue)
            } else {
                nsNumber = nil
            }
            
            objc_setAssociatedObject(
                self,
                "refreshControlVerticalSpace",
                nsNumber,
                .OBJC_ASSOCIATION_RETAIN
            )
        }
    }
    
}

extension UIRefreshControl {
    
    var isLoading: Bool {
        get { isRefreshing }
        set(newIsLoading) {
            setIsLoading(newIsLoading, forced: true, scrollToTop: false)
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
            let refreshControlHeight = frame.height
            newContentOffset.y -= refreshControlHeight
            scrollView.refreshControlVerticalSpace = refreshControlHeight
            scrollView.setContentOffset(newContentOffset, animated: true)
        }
        
        beginRefreshing()
    }
    
    private func endRefreshing(forced: Bool) {
        guard isRefreshing
        else { return }
        
        guard forced
        else {
            endRefreshing()
            return
        }
        
        if let scrollView = superview as? UIScrollView,
           scrollView.contentOffset.y < 0,
           let refreshControlVerticalSpace = scrollView.refreshControlVerticalSpace {
            var newContentOffset = scrollView.contentOffset
            newContentOffset.y += refreshControlVerticalSpace
            scrollView.refreshControlVerticalSpace = nil
            scrollView.setContentOffset(newContentOffset, animated: true)
        }
        
        endRefreshing()
    }
    
    func setIsLoading(
        _ isLoading: Bool,
        forced: Bool,
        scrollToTop: Bool
    ) {
        guard self.isLoading != isLoading
        else { return }
        
        if isLoading {
            beginRefreshing(forced: forced, scrollToTop: scrollToTop)
        } else {
            endRefreshing(forced: forced)
        }
    }
    
}
