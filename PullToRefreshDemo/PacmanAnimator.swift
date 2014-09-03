//
//  CircleAnimator.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 02/09/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import Foundation
import Refresher
import QuartzCore
import UIKit

class PacmanAnimator: PullToRefreshViewAnimator {
    
    private var layerLoader: CAShapeLayer = CAShapeLayer()
    private var layerSeparator: CAShapeLayer = CAShapeLayer()
    
    init() {
        
        layerLoader.lineWidth = 8
        layerLoader.strokeColor = UIColor(red: 0, green: 0.7, blue: 1, alpha: 1).CGColor
        layerLoader.strokeEnd = 0
        layerLoader.fillColor = UIColor.clearColor().CGColor
        
        layerSeparator.lineWidth = 8
        layerSeparator.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).CGColor
        layerSeparator.fillColor = UIColor.clearColor().CGColor
        
    }
    
    func startAnimation() {
        
        var pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationEnd.duration = 0.5
        pathAnimationEnd.repeatCount = 100
        pathAnimationEnd.autoreverses = true
        pathAnimationEnd.fromValue = 1
        pathAnimationEnd.toValue = 0.8
        self.layerLoader.addAnimation(pathAnimationEnd, forKey: "strokeEndAnimation")
        
        var pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationStart.duration = 0.5
        pathAnimationStart.repeatCount = 100
        pathAnimationStart.autoreverses = true
        pathAnimationStart.fromValue = 0
        pathAnimationStart.toValue = 0.2
        self.layerLoader.addAnimation(pathAnimationStart, forKey: "strokeStartAnimation")
    }
    
    func stopAnimation() {
        
        self.layerLoader.removeAllAnimations()
    }
    
    func layoutLayers(superview: UIView) {
        
        if layerSeparator.superlayer == nil {
            superview.layer.addSublayer(layerSeparator)
        }
        if layerLoader.superlayer == nil {
            superview.layer.addSublayer(layerLoader)
        }
        var center = CGPoint(x: 30, y: superview.frame.size.height / 2)
        var bezierPathLoader = UIBezierPath(arcCenter: center, radius: CGFloat(10), startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        var bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPointMake(0, superview.frame.height - 1))
        bezierPathSeparator.addLineToPoint(CGPoint(x: superview.frame.width, y: superview.frame.height - 1))
        
        layerLoader.path = bezierPathLoader.CGPath
        layerSeparator.path = bezierPathLoader.CGPath
    }
    
    func changeProgress(progress: CGFloat) {
        
        self.layerLoader.strokeEnd = progress
    }
}