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

var KVOContext = "RefresherKVOContext"
let contentOffsetKeyPath = "contentOffset"

public protocol PullToRefreshViewAnimator {
    
    func startAnimation()
    func stopAnimation()
    func changeProgress(progress: CGFloat)
    func layoutLayers(superview: UIView)
}

public class PullToRefreshView: UIView {
    
    public let labelTitle = UILabel() // this maybe should be added in animator???

    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsetsZero

    private var animator: PullToRefreshViewAnimator = Animator()
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
        
        self.init(frame: frame)
        self.action = action;
    }
    
    convenience init(action :(() -> ()), frame: CGRect, animator: PullToRefreshViewAnimator) {
        
        self.init(frame: frame)
        self.action = action;
        self.animator = animator
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
        labelTitle.frame = bounds
        labelTitle.textAlignment = .Center
        labelTitle.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin
        labelTitle.textColor = UIColor.blackColor()
        labelTitle.text = NSLocalizedString("Pull to refresh", comment: "Refresher")
        addSubview(labelTitle)
    }
    
    public required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        // Currently it is not supported to load view from nib
    }
    
    deinit {
        
        var scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
    
    
    //MARK: UIView methods
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        animator.layoutLayers(self)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView!) {

        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
        if let scrollView = newSuperview as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
        }
    }
    
    
    //MARK: KVO methods

    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        
        if (context == &KVOContext) {
            if let scrollView = superview as? UIScrollView where object as? NSObject == scrollView {
                if keyPath == contentOffsetKeyPath {
                    var offsetWithoutInsets = previousOffset + scrollViewInsetsDefaultValue.top
                    if (offsetWithoutInsets < -self.frame.size.height) {
                        if (scrollView.dragging == false && loading == false) {
                            loading = true
                        } else if (loading == true) {
                            labelTitle.text = NSLocalizedString("Loading ...", comment: "Refresher")
                        } else {
                            labelTitle.text = NSLocalizedString("Release to refresh", comment: "Refresher")
                            animator.changeProgress(-offsetWithoutInsets / self.frame.size.height)
                        }
                    } else if (loading == true) {
                        labelTitle.text = NSLocalizedString("Loading ...", comment: "Refresher")
                    } else if (offsetWithoutInsets < 0) {
                        labelTitle.text = NSLocalizedString("Pull to refresh", comment: "Refresher")
                        animator.changeProgress(-offsetWithoutInsets / self.frame.size.height)
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
        
        var scrollView = superview as! UIScrollView
        var insets = scrollView.contentInset
        insets.top += self.frame.size.height
        
        // we need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset
        scrollView.bounces = false
        UIView.animateWithDuration(0.3, delay: 0, options:nil, animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets.top)
        }, completion: {finished in
            self.animator.startAnimation()
            self.action()
        })
    }
    
    private func stopAnimating() {
        
        self.animator.stopAnimation()
        var scrollView = superview as! UIScrollView
        scrollView.bounces = self.scrollViewBouncesDefaultValue
        UIView.animateWithDuration(0.3, animations: {
            scrollView.contentInset = self.scrollViewInsetsDefaultValue
        }) { finished in
            self.animator.changeProgress(0)
        }
    }
}
