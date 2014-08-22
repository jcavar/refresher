//
//  PullToRefreshView.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 17/08/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import UIKit

var KVOContext = ""

public class PullToRefreshView: UIView {
    
    var previousOffset: CGFloat?
    var pullToRefreshAction: (() -> ())
    var label: UILabel = UILabel()
    var activityIndicator: UIActivityIndicatorView
    var loading: Bool = false {
        
        didSet {
            if loading {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    convenience init(action :(() -> ()), frame: CGRect) {
        
        self.init(frame: frame)
        pullToRefreshAction = action;
    }
    
    override init(frame: CGRect) {
        
        pullToRefreshAction = {}
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.White)
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        label.frame = bounds
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.text = "pull to refresh"
        addSubview(label)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        addSubview(activityIndicator)
    }
    
    public required init(coder aDecoder: NSCoder) {
        
        pullToRefreshAction = {}
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.White)
        super.init(coder: aDecoder)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        addSubview(activityIndicator)
    }
    
    deinit {
        
        var scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &KVOContext)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView!) {

        superview?.removeObserver(self, forKeyPath: "contentOffset", context: &KVOContext)
        if (newSuperview != nil && newSuperview.isKindOfClass(UIScrollView)) {
            newSuperview.addObserver(self, forKeyPath: "contentOffset", options: .Initial, context: &KVOContext)
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        
        if (context == &KVOContext) {
            var scrollView = superview as? UIScrollView
            if (keyPath == "contentOffset" && object as? UIScrollView == scrollView) {
                var scrollView = object as? UIScrollView
                if (scrollView != nil) {
                    println(scrollView?.contentOffset.y)
                    if (scrollView?.contentOffset.y <= -50) {
                        label.text = "release to refresh"
                        if (scrollView?.dragging == false && loading == false) {
                            loading = true
                        }
                    } else {
                        label.text = "pull to refresh"
                    }
                    previousOffset = scrollView?.contentOffset.y
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func startAnimating() {
        
        label.alpha = 0
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        
        // we need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset!
        scrollView.bounces = false
        UIView.animateWithDuration(0.3, delay: 0, options:nil, animations: {
            scrollView.contentInset = UIEdgeInsets(top: 50, left: insets.left, bottom: insets.bottom, right: insets.right)
            }, completion: {finished in
                self.activityIndicator.startAnimating()
                self.pullToRefreshAction()
                scrollView.bounces = true
        })
    }
    
    func stopAnimating() {
        
        activityIndicator.stopAnimating()
        label.alpha = 1
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        UIView.animateWithDuration(0.3, animations: {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: insets.left, bottom: insets.bottom, right: insets.right)
        })
    }
}
