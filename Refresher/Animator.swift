//
// Animator.swift
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
import QuartzCore
import UIKit

class Animator: PullToRefreshViewAnimator {

    private var animating = false {
        didSet {

            configureLabelTitle()
        }
    }
    private var progress: CGFloat = 0.0 {
        didSet {

            configureLabelTitle()
        }
    }

    private let labelTitle = UILabel()
    private let layerLoader = CAShapeLayer()
    private let layerSeparator = CAShapeLayer()
    
    init() {

        labelTitle.textAlignment = .Center
        labelTitle.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin

        layerLoader.lineWidth = 4
        layerLoader.strokeColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1).CGColor
        layerLoader.strokeEnd = 0
        
        layerSeparator.lineWidth = 1
        layerSeparator.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).CGColor
    }

    func configureLabelTitle() {

        if animating {
            labelTitle.text = NSLocalizedString("Loading ...", comment: "Refresher")
        } else if progress >= 1.0 {
            labelTitle.text = NSLocalizedString("Release to refresh", comment: "Refresher")
        } else {
            labelTitle.text = NSLocalizedString("Pull to refresh", comment: "Refresher")
        }
    }

    func startAnimation() {

        animating = true
        
        let pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationEnd.duration = 0.5
        pathAnimationEnd.repeatCount = 100
        pathAnimationEnd.autoreverses = true
        pathAnimationEnd.fromValue = 0.2
        pathAnimationEnd.toValue = 1
        layerLoader.addAnimation(pathAnimationEnd, forKey: "strokeEndAnimation")
        
        let pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationStart.duration = 0.5
        pathAnimationStart.repeatCount = 100
        pathAnimationStart.autoreverses = true
        pathAnimationStart.fromValue = 0
        pathAnimationStart.toValue = 0.8
        layerLoader.addAnimation(pathAnimationStart, forKey: "strokeStartAnimation")
    }
    
    func stopAnimation() {

        animating = false
        layerLoader.removeAllAnimations()
    }
    
    func layoutLayers(superview: UIView) {

        if labelTitle.superview == nil {
          labelTitle.frame = superview.bounds
          superview.addSubview(labelTitle)
        }
        if layerLoader.superlayer == nil {
            superview.layer.addSublayer(layerLoader)
        }
        if layerSeparator.superlayer == nil {
            superview.layer.addSublayer(layerSeparator)
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

        self.progress = progress
        layerLoader.strokeEnd = progress
    }
}