//
// PullToRefresh.swift
//
// Copyright (c) 2014 Josip Cavar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit

private let pullToRefreshTag = 324
private let pullToRefreshDefaultHeight: CGFloat = 50

extension UIScrollView {
    
    // Actual UIView subclass which is added as subview to desired UIScrollView. If you want customize appearance of this object, do that after addPullToRefreshWithAction
    public var pullToRefreshView: PullToRefreshView? {
        get {
            let pullToRefreshView = viewWithTag(pullToRefreshTag)
            return pullToRefreshView as? PullToRefreshView
        }
    }
    
    // If you want to add pull to refresh functionality to your UIScrollView just call this method and pass action closure you want to execute while pull to refresh is animating. If you want to stop pull to refresh you must do that manually calling stopPullToRefreshView methods on your scroll view
    public func addPullToRefreshWithAction(_ action: @escaping (() -> ())) {
        let pullToRefreshView = PullToRefreshView(action: action, frame: CGRect(x: 0, y: -pullToRefreshDefaultHeight, width: self.frame.size.width, height: pullToRefreshDefaultHeight))
        pullToRefreshView.tag = pullToRefreshTag
        addSubview(pullToRefreshView)
    }
    
    // If you want to use your custom animation and custom subview when pull to refresh is animating, you should call this method and pass your animator and view objects.
    public func addPullToRefreshWithAction(_ action: @escaping (() -> ()), withAnimator animator: PullToRefreshViewDelegate, withSubview subview: UIView) {
        let height = subview.frame.height
        let pullToRefreshView = PullToRefreshView(action: action, frame: CGRect(x: 0, y: -height, width: self.frame.size.width, height: height), animator: animator, subview: subview)
        pullToRefreshView.tag = pullToRefreshTag
        addSubview(pullToRefreshView)
    }
    
    //
    public func addPullToRefreshWithAction<T: UIView>(_ action: @escaping (() -> ()), withAnimator animator: T) where T: PullToRefreshViewDelegate {
        let height = animator.frame.height
        let pullToRefreshView = PullToRefreshView(action: action, frame: CGRect(x: 0, y: -height, width: self.frame.size.width, height: height), animator: animator, subview: animator)
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
