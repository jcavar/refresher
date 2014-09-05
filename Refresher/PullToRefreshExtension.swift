//
//  PullToRefresh.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 13/08/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import Foundation
import UIKit

let pullToRefreshTag = 324
let pullToRefreshDefaultHeight: CGFloat = 50

extension UIScrollView {
    
    // Actual UIView subclass which is added as subview to desired UIScrollView. If you want customize appearance of this object, do that after addPullToRefreshWithAction
    public var pullToRefreshView: PullToRefreshView? {
        
        get {
            var pullToRefreshView = viewWithTag(pullToRefreshTag)
            return pullToRefreshView as? PullToRefreshView
        }
    }
    
    // If you want to add pull to refresh functionality to your UIScrollView just call this method and pass action closure you want to execute while pull to refresh is animating. If you want to stop pull to refresh you must do that manually calling stopPullToRefreshView methods on your scroll view
    public func addPullToRefreshWithAction(action :(() -> ())) {

        var pullToRefreshView = PullToRefreshView(action: action, frame: CGRectMake(0, -pullToRefreshDefaultHeight, self.frame.size.width, pullToRefreshDefaultHeight))
        pullToRefreshView.tag = pullToRefreshTag
        addSubview(pullToRefreshView)
    }
    
    // If you want to use your custom animation when pull to refresh is animating, you should call this method and pass your animator object.
    public func addPullToRefreshWithAction(action :(() -> ()), withAnimator animator: PullToRefreshViewAnimator) {
        
        var pullToRefreshView = PullToRefreshView(action: action, frame: CGRectMake(0, -pullToRefreshDefaultHeight, self.frame.size.width, pullToRefreshDefaultHeight), animator: animator)
        pullToRefreshView.tag = pullToRefreshTag
        addSubview(pullToRefreshView)
    }
    
    // Manually start pull to refresh
    public func startPullToRefresh() {

        pullToRefreshView?.loading = true
    }
    
    // Manually stop pull to refresh
    public func stopPullToRefresh() {
        
        pullToRefreshView?.loading = false
    }
}