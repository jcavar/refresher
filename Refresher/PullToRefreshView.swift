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

public class PullToRefreshView: UIView {
    
    public let labelTitle: UILabel = UILabel()

    private var scrollViewBouncesDefaultValue = false
    
    private var previousOffset: CGFloat = 0
    private var pullToRefreshAction: (() -> ()) = {}
    private var layerLoader: CAShapeLayer = CAShapeLayer()
    private var layerSeparator: CAShapeLayer = CAShapeLayer()
    private var loading: Bool = false {
        
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
        
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
        labelTitle.frame = bounds
        labelTitle.textAlignment = .Center
        labelTitle.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin
        labelTitle.textColor = UIColor.blackColor()
        labelTitle.text = "Pull to refresh"
        addSubview(labelTitle)
        
        layerLoader.lineWidth = 4
        layerLoader.strokeColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1).CGColor
        layerLoader.strokeEnd = 0
        layer.addSublayer(layerLoader)
        
        layerSeparator.lineWidth = 1
        layerSeparator.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).CGColor
        layer.addSublayer(layerSeparator)
    }
    
    public required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        var scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var bezierPathLoader = UIBezierPath()
        bezierPathLoader.moveToPoint(CGPointMake(0, frame.height - 3))
        bezierPathLoader.addLineToPoint(CGPoint(x: frame.width, y: frame.height - 3))
        
        var bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPointMake(0, frame.height - 1))
        bezierPathSeparator.addLineToPoint(CGPoint(x: frame.width, y: frame.height - 1))
        
        layerLoader.path = bezierPathLoader.CGPath
        layerSeparator.path = bezierPathSeparator.CGPath
    }
    
    public override func willMoveToSuperview(newSuperview: UIView!) {

        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
        if (newSuperview != nil && newSuperview.isKindOfClass(UIScrollView)) {
            newSuperview.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
            scrollViewBouncesDefaultValue = (newSuperview as UIScrollView).bounces
        }
    }
    
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
                            self.layerLoader.strokeEnd = -previousOffset / pullToRefreshDefaultHeight
                        }
                    } else if (loading == true) {
                        labelTitle.text = "Loading ..."
                    } else if (previousOffset < 0) {
                        labelTitle.text = "Pull to refresh"
                        self.layerLoader.strokeEnd = -previousOffset / pullToRefreshDefaultHeight
                    }
                    previousOffset = scrollView!.contentOffset.y
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func startAnimating() {
        
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        
        // we need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset
        scrollView.bounces = false
        UIView.animateWithDuration(0.3, delay: 0, options:nil, animations: {
            scrollView.contentInset = UIEdgeInsets(top: 50, left: insets.left, bottom: insets.bottom, right: insets.right)
            }, completion: {finished in
                
                var pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
                pathAnimationEnd.duration = 0.5
                pathAnimationEnd.repeatCount = 100
                pathAnimationEnd.autoreverses = true
                pathAnimationEnd.fromValue = 0.2
                pathAnimationEnd.toValue = 1
                self.layerLoader.addAnimation(pathAnimationEnd, forKey: "strokeEndAnimation")
                
                var pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
                pathAnimationStart.duration = 0.5
                pathAnimationStart.repeatCount = 100
                pathAnimationStart.autoreverses = true
                pathAnimationStart.fromValue = 0
                pathAnimationStart.toValue = 0.8
                self.layerLoader.addAnimation(pathAnimationStart, forKey: "strokeStartAnimation")
                
                
                self.pullToRefreshAction()
        })
    }
    
    func stopAnimating() {
        
        self.layerLoader.removeAllAnimations()

        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        scrollView.bounces = self.scrollViewBouncesDefaultValue
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            scrollView.contentInset = UIEdgeInsets(top: 0, left: insets.left, bottom: insets.bottom, right: insets.right)
        }) { (Bool) -> Void in
            self.layerLoader.strokeEnd = 0
        }
    }
}
