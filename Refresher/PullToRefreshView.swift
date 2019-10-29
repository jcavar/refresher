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

public enum PullToRefreshViewState {
    case loading
    case pullToRefresh
    case releaseToRefresh
}

public protocol PullToRefreshViewDelegate {
    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView)
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView)
    func pullToRefresh(_ view: PullToRefreshView, progressDidChange progress: CGFloat)
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshViewState)
}

open class PullToRefreshView: UIView {
    private var observation: NSKeyValueObservation?
    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsets.zero

    private var animator: PullToRefreshViewDelegate
    private var action: (() -> ()) = {}

    private var previousOffset: CGFloat = 0

    internal var loading: Bool = false {
        
        didSet {
            if loading != oldValue {
                if loading {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }
    
    
    // MARK: Object lifecycle methods

    convenience init(action: @escaping (() -> ()), frame: CGRect) {
        var bounds = frame
        bounds.origin.y = 0
        let animator = Animator(frame: bounds)
        self.init(frame: frame, animator: animator)
        self.action = action;
        addSubview(animator.animatorView)
    }

    convenience init(action: @escaping (() -> ()), frame: CGRect, animator: PullToRefreshViewDelegate, subview: UIView) {
        self.init(frame: frame, animator: animator)
        self.action = action;
        subview.frame = self.bounds
        addSubview(subview)
    }
    
    convenience init(action: @escaping (() -> ()), frame: CGRect, animator: PullToRefreshViewDelegate) {
        self.init(frame: frame, animator: animator)
        self.action = action;
    }
    
    init(frame: CGRect, animator: PullToRefreshViewDelegate) {
        self.animator = animator
        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.animator = Animator(frame: CGRect.zero)
        super.init(coder: aDecoder)
        // It is not currently supported to load view from nib
    }
    
    
    // MARK: UIView methods
    
    open override func willMove(toSuperview newSuperview: UIView!) {
        self.observation?.invalidate()
        if let scrollView = newSuperview as? UIScrollView {
            self.observation = scrollView.observe(\.contentOffset, options: [.initial]) { [unowned self] (scrollView, change) in
                let offsetWithoutInsets = self.previousOffset + self.scrollViewInsetsDefaultValue.top
                if (offsetWithoutInsets < -self.frame.size.height) {
                    if (scrollView.isDragging == false && self.loading == false) {
                        self.loading = true
                    } else if (self.loading) {
                        self.animator.pullToRefresh(self, stateDidChange: .loading)
                    } else {
                        self.animator.pullToRefresh(self, stateDidChange: .releaseToRefresh)
                        self.animator.pullToRefresh(self, progressDidChange: -offsetWithoutInsets / self.frame.size.height)
                    }
                } else if (self.loading) {
                    self.animator.pullToRefresh(self, stateDidChange: .loading)
                } else if (offsetWithoutInsets < 0) {
                    self.animator.pullToRefresh(self, stateDidChange: .pullToRefresh)
                    self.animator.pullToRefresh(self, progressDidChange: -offsetWithoutInsets / self.frame.size.height)
                }
                self.previousOffset = scrollView.contentOffset.y
            }
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
        }
    }
    
    
    // MARK: PullToRefreshView methods

    private func startAnimating() {
        let scrollView = superview as! UIScrollView
        var insets = scrollView.contentInset
        insets.top += self.frame.size.height
        
        // We need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset
        scrollView.bounces = false
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions(), animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets.top)
        }, completion: {finished in
            self.animator.pullToRefreshAnimationDidStart(self)
            self.action()
        })
    }
    
    private func stopAnimating() {
        self.animator.pullToRefreshAnimationDidEnd(self)
        let scrollView = superview as! UIScrollView
        scrollView.bounces = self.scrollViewBouncesDefaultValue
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset = self.scrollViewInsetsDefaultValue
        }, completion: { finished in
            self.animator.pullToRefresh(self, progressDidChange: 0)
        }) 
    }
}
