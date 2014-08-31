//
//  Animator.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 31/08/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

class Animator: PullToRefreshViewAnimator {
    
    private var layerLoader: CAShapeLayer = CAShapeLayer()
    private var layerSeparator: CAShapeLayer = CAShapeLayer()
    
    init() {
    
        layerLoader.lineWidth = 4
        layerLoader.strokeColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1).CGColor
        layerLoader.strokeEnd = 0
        
        layerSeparator.lineWidth = 1
        layerSeparator.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).CGColor
        
    }
    
    func startAnimation() {
        
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
    }
    
    func stopAnimation() {
        
        self.layerLoader.removeAllAnimations()
    }
    
    func layoutLayers(superview: UIView) {
        
        if layerLoader.superlayer == nil {
            superview.layer .addSublayer(layerLoader)
        }
        if layerSeparator.superlayer == nil {
            superview.layer .addSublayer(layerSeparator)
        }
        var bezierPathLoader = UIBezierPath()
        bezierPathLoader.moveToPoint(CGPointMake(0, superview.frame.height - 3))
        bezierPathLoader.addLineToPoint(CGPoint(x: superview.frame.width, y: superview.frame.height - 3))
        
        var bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPointMake(0, superview.frame.height - 1))
        bezierPathSeparator.addLineToPoint(CGPoint(x: superview.frame.width, y: superview.frame.height - 1))
        
        layerLoader.path = bezierPathLoader.CGPath
        layerSeparator.path = bezierPathSeparator.CGPath
    }
    
    func changeProgress(progress: CGFloat) {
        
        self.layerLoader.strokeEnd = progress
    }
}