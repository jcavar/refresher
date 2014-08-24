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

public class PullToRefreshView: UIView {
    
    var previousOffset: CGFloat = 0
    var pullToRefreshAction: (() -> ())
    var label: UILabel = UILabel()
    var shapeLayer: CAShapeLayer
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
        shapeLayer = CAShapeLayer()
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        label.frame = bounds
        label.textAlignment = .Center
        label.textColor = UIColor.blackColor()
        label.text = "pull to refresh"
        addSubview(label)
        
        
        
        //shapeLayer.path = UIBezierPath(ovalInRect:CGRect(x: frame.height / 2 - 15, y: frame.height / 2 - 15, width: 30, height: 30)).CGPath;
        //// Bezier Drawing
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(0, frame.height - 2))
        bezierPath.addLineToPoint(CGPoint(x: frame.width, y: frame.height - 2))
        
        shapeLayer.path = bezierPath.CGPath
        shapeLayer.lineWidth = 4

        //[UIColor colorWithRed:0.12 green:0.49 blue:0.98 alpha:1]
        shapeLayer.strokeColor = UIColor(red: 0.12, green: 0.49, blue: 0.98, alpha: 1).CGColor
        shapeLayer.fillColor = UIColor.greenColor().CGColor
        shapeLayer.strokeEnd = 0
        //shapeLayer.strokeEnd = 0.5
        layer.addSublayer(shapeLayer)
    }
    
    public required init(coder aDecoder: NSCoder) {
        
        pullToRefreshAction = {}
        shapeLayer = CAShapeLayer()
        super.init(coder: aDecoder)
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
                    
                    // this should be done with tuples
                    /*
                    let state = (previousOffset, scrollView?.dragging, loading)
                    switch state {
                    
                    case (let offset, false, false) where offset < -pullToRefreshDefaultHeight:
                        println()
                    }
                    */
                    if (previousOffset < -pullToRefreshDefaultHeight) {
                        if (scrollView?.dragging == false && loading == false) {
                            loading = true
                        } else if (loading == true) {
                            label.text = "loading ..."
                        } else {
                            label.text = "release to refresh"
                            self.shapeLayer.strokeEnd = -previousOffset / pullToRefreshDefaultHeight
                        }
                    } else if (loading == true) {
                        label.text = "loading ..."
                    } else if (previousOffset < 0) {
                        label.text = "pull to refresh"
                        self.shapeLayer.strokeEnd = -previousOffset / pullToRefreshDefaultHeight
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
                //self.activityIndicator.startAnimating()
                
                var pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
                pathAnimationEnd.duration = 0.5
                pathAnimationEnd.repeatCount = 100
                pathAnimationEnd.autoreverses = true
                pathAnimationEnd.fromValue = 0.2
                pathAnimationEnd.toValue = 1
                self.shapeLayer.addAnimation(pathAnimationEnd, forKey: "strokeEndAnimation")
                
                var pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
                pathAnimationStart.duration = 0.5
                pathAnimationStart.repeatCount = 100
                pathAnimationStart.autoreverses = true
                pathAnimationStart.fromValue = 0
                pathAnimationStart.toValue = 0.8
                self.shapeLayer.addAnimation(pathAnimationStart, forKey: "strokeStartAnimation")
                
                
                self.pullToRefreshAction()
                scrollView.bounces = true
        })
    }
    
    func stopAnimating() {
        
        //activityIndicator.stopAnimating()
        self.shapeLayer.removeAllAnimations()
        
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        UIView.animateWithDuration(0.3, animations: {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: insets.left, bottom: insets.bottom, right: insets.right)
        })
    }
}
