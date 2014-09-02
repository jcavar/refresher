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
    
    public var pullToRefreshView: PullToRefreshView? {
        
        get {
            var pullToRefreshView = viewWithTag(pullToRefreshTag)
            return pullToRefreshView as? PullToRefreshView
        }
    }
    
    public func addPullToRefreshWithAction(action :(() -> ())) {

        var pullToRefreshView = PullToRefreshView(action: action, frame: CGRectMake(0, -pullToRefreshDefaultHeight, self.frame.size.width, pullToRefreshDefaultHeight))
        pullToRefreshView.tag = pullToRefreshTag
        addSubview(pullToRefreshView)
    }
    
    public func addPullToRefreshWithAction(action :(() -> ()), withAnimator animator: PullToRefreshViewAnimator) {
        
        var pullToRefreshView = PullToRefreshView(action: action, frame: CGRectMake(0, -pullToRefreshDefaultHeight, self.frame.size.width, pullToRefreshDefaultHeight), animator: animator)
        pullToRefreshView.tag = pullToRefreshTag
        addSubview(pullToRefreshView)
    }
    
    public func startPullToRefresh() {

        pullToRefreshView?.loading = true
    }
    
    public func stopPullToRefresh() {
        
        pullToRefreshView?.loading = false
    }
}