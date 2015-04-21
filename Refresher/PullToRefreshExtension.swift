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
import ObjectiveC

private var PullToRefreshViewKey = "PullToRefreshView"

extension UIScrollView {
    
    // Actual UIView subclass which is added as subview to desired UIScrollView. If you want customize appearance of this object, do that after addPullToRefreshWithAction
    public private(set) var pullToRefreshView: PullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &PullToRefreshViewKey) as? PullToRefreshView
        }
        set {
            self.pullToRefreshView?.removeFromSuperview()
            objc_setAssociatedObject(self, &PullToRefreshViewKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            if let view = newValue {
                view.setTranslatesAutoresizingMaskIntoConstraints(false)
                addSubview(view)
                let constraints = [
                    NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
                ]
                addConstraints(constraints)
            }
        }
    }
    
    // Returns if pull to refresh is enabled for this scrollview
    public var hasPullToRefresh: Bool { return pullToRefreshView != nil }
    
    // If you want to add pull to refresh functionality to your UIScrollView just call this method and pass action closure you want to execute while pull to refresh is animating. If you want to stop pull to refresh you must do that manually calling stopPullToRefreshView methods on your scroll view
    // If you want to use your custom view, pass your own PullToRefreshView subclass here.
    public func addPullToRefreshWithAction(view: PullToRefreshView = DefaultPullToRefreshView(), action: PullToRefreshView.PullToRefreshAction) {
        view.action = action
        pullToRefreshView = view
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