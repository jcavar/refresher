//
// PullToRefreshView.swift
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

import UIKit
import QuartzCore

private var KVOContext = "RefresherKVOContext"
private let ContentOffsetKeyPath = "contentOffset"

public enum PullToRefreshViewState {

    case Loading
    case PullToRefresh
    case ReleaseToRefresh
}

public protocol PullToRefreshViewDelegate {
    
    func pullToRefreshAnimationDidStart(view: PullToRefreshView)
    func pullToRefreshAnimationDidEnd(view: PullToRefreshView)
    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat)
    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState)
}

public class PullToRefreshView: UIView {
    
    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsetsZero

    private var animator: PullToRefreshViewDelegate
    private var action: (() -> ()) = {}

    private var previousOffset: CGFloat = 0

    internal var loading: Bool = false {
        
        didSet {
            if loading {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    
    //MARK: Object lifecycle methods

    convenience init(action :(() -> ()), frame: CGRect) {
        var bounds = frame
        bounds.origin.y = 0
        let animator = Animator(frame: bounds)
        self.init(frame: frame, animator: animator)
        self.action = action;
        addSubview(animator.animatorView)
    }

    convenience init(action :(() -> ()), frame: CGRect, animator: PullToRefreshViewDelegate, subview: UIView) {
        self.init(frame: frame, animator: animator)
        self.action = action;
        subview.frame = self.bounds
        addSubview(subview)
    }
    
    convenience init(action :(() -> ()), frame: CGRect, animator: PullToRefreshViewDelegate) {
        self.init(frame: frame, animator: animator)
        self.action = action;
    }
    
    init(frame: CGRect, animator: PullToRefreshViewDelegate) {
        self.animator = animator
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.animator = Animator(frame: CGRectZero)
        super.init(coder: aDecoder)
        // Currently it is not supported to load view from nib
    }
    
    deinit {
        let scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
    }
    
    
    //MARK: UIView methods
    
    public override func willMoveToSuperview(newSuperview: UIView!) {
        superview?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
        if let scrollView = newSuperview as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: .Initial, context: &KVOContext)
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
        }
    }
    
    
    //MARK: KVO methods

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext) {
            if let scrollView = superview as? UIScrollView where object as? NSObject == scrollView {
                if keyPath == ContentOffsetKeyPath {
                    let offsetWithoutInsets = previousOffset + scrollViewInsetsDefaultValue.top
                    if (offsetWithoutInsets < -self.frame.size.height) {
                        if (scrollView.dragging == false && loading == false) {
                            loading = true
                        } else if (loading) {
                            self.animator.pullToRefresh(self, stateDidChange: .Loading)
                        } else {
                            self.animator.pullToRefresh(self, stateDidChange: .ReleaseToRefresh)
                            animator.pullToRefresh(self, progressDidChange: -offsetWithoutInsets / self.frame.size.height)
                        }
                    } else if (loading) {
                        self.animator.pullToRefresh(self, stateDidChange: .Loading)
                    } else if (offsetWithoutInsets < 0) {
                        self.animator.pullToRefresh(self, stateDidChange: .PullToRefresh)
                        animator.pullToRefresh(self, progressDidChange: -offsetWithoutInsets / self.frame.size.height)
                    }
                    previousOffset = scrollView.contentOffset.y
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    //MARK: PullToRefreshView methods

    private func startAnimating() {
        let scrollView = superview as! UIScrollView
        var insets = scrollView.contentInset
        insets.top += self.frame.size.height
        
        // we need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset
        scrollView.bounces = false
        UIView.animateWithDuration(0.3, delay: 0, options:[], animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets.top)
        }, completion: {finished in
            self.animator.pullToRefreshAnimationDidStart(self)
            self.action()
        })
    }
    
    private func stopAnimating() {
        self.animator.pullToRefreshAnimationDidEnd(self)
        let scrollView = superview as! UIScrollView
        scrollView.bounces = self.scrollViewBouncesDefaultValue
        UIView.animateWithDuration(0.3, animations: {
            scrollView.contentInset = self.scrollViewInsetsDefaultValue
        }) { finished in
            self.animator.pullToRefresh(self, progressDidChange: 0)
        }
    }
}
