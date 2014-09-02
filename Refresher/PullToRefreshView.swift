//
//  PullToRefreshView.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 17/08/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import UIKit
import QuartzCore

var KVOContext = ""
let contentOffsetKeyPath = "contentOffset"

public protocol PullToRefreshViewAnimator {
    
    func startAnimation()
    func stopAnimation()
    func changeProgress(progress: CGFloat)
    func layoutLayers(superview: UIView)
}

public class PullToRefreshView: UIView {
    
    public let labelTitle = UILabel()

    private var scrollViewBouncesDefaultValue: Bool = false
    
    private var animator: PullToRefreshViewAnimator = Animator()
    
    private var previousOffset: CGFloat = 0
    private var pullToRefreshAction: (() -> ()) = {}

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
        pullToRefreshAction = action;
    }
    
    convenience init(action :(() -> ()), frame: CGRect, animator: PullToRefreshViewAnimator) {
        
        self.init(frame: frame)
        self.pullToRefreshAction = action;
        self.animator = animator
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
        labelTitle.frame = bounds
        labelTitle.textAlignment = .Center
        labelTitle.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin
        labelTitle.textColor = UIColor.blackColor()
        labelTitle.text = "Pull to refresh"
        addSubview(labelTitle)
    }
    
    public required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
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
        if (newSuperview != nil && newSuperview.isKindOfClass(UIScrollView)) {
            newSuperview.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
            scrollViewBouncesDefaultValue = (newSuperview as UIScrollView).bounces
        }
    }
    
    
    //MARK: KVO methods

    public override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        
        if (context == &KVOContext) {
            var scrollView = superview as? UIScrollView
            if (keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
                var scrollView = object as? UIScrollView
                if (scrollView != nil) {
                    println(scrollView?.contentOffset.y)
                    
                    if (previousOffset < -pullToRefreshDefaultHeight) {
                        if (scrollView?.dragging == false && loading == false) {
                            loading = true
                        } else if (loading == true) {
                            labelTitle.text = "Loading ..."
                        } else {
                            labelTitle.text = "Release to refresh"
                            animator.changeProgress(-previousOffset / pullToRefreshDefaultHeight)
                        }
                    } else if (loading == true) {
                        labelTitle.text = "Loading ..."
                    } else if (previousOffset < 0) {
                        labelTitle.text = "Pull to refresh"
                        animator.changeProgress(-previousOffset / pullToRefreshDefaultHeight)
                    }
                    previousOffset = scrollView!.contentOffset.y
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    //MARK: PullToRefreshView methods

    func startAnimating() {
        
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        insets.top = pullToRefreshDefaultHeight
        
        // we need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset
        scrollView.bounces = false
        UIView.animateWithDuration(0.3, delay: 0, options:nil, animations: {
            scrollView.contentInset = insets
        }, completion: {finished in
                self.animator.startAnimation()
                self.pullToRefreshAction()
        })
    }
    
    func stopAnimating() {
        
        self.animator.stopAnimation()
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        scrollView.bounces = self.scrollViewBouncesDefaultValue
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            scrollView.contentInset = UIEdgeInsets(top: 0, left: insets.left, bottom: insets.bottom, right: insets.right)
        }) { (Bool) -> Void in
            self.animator.changeProgress(0)
        }
    }
}
