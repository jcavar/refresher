//
// BeatAnimator.swift
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
import Refresher
import QuartzCore


class BeatAnimator: UIView, PullToRefreshViewDelegate {
    
    private let layerLoader = CAShapeLayer()
    private let layerSeparator = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layerLoader.lineWidth = 4
        layerLoader.strokeColor = UIColor(red: 0.13, green: 0.79, blue: 0.31, alpha: 1).cgColor
        layerLoader.strokeEnd = 0
        
        layerSeparator.lineWidth = 1
        layerSeparator.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).cgColor
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pullToRefresh(_ view: PullToRefreshView, progressDidChange progress: CGFloat) {
        layerLoader.strokeEnd = progress
    }
    
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        
    }
    
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        layerLoader.removeAllAnimations()
    }
    
    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        let pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationEnd.duration = 0.5
        pathAnimationEnd.repeatCount = 100
        pathAnimationEnd.autoreverses = true
        pathAnimationEnd.fromValue = 1
        pathAnimationEnd.toValue = 0.8
        layerLoader.add(pathAnimationEnd, forKey: "strokeEndAnimation")
        
        let pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationStart.duration = 0.5
        pathAnimationStart.repeatCount = 100
        pathAnimationStart.autoreverses = true
        pathAnimationStart.fromValue = 0
        pathAnimationStart.toValue = 0.2
        layerLoader.add(pathAnimationStart, forKey: "strokeStartAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let superview = superview {
            if layerLoader.superlayer == nil {
                superview.layer.addSublayer(layerLoader)
            }
            if layerSeparator.superlayer == nil {
                superview.layer.addSublayer(layerSeparator)
            }
            let bezierPathLoader = UIBezierPath()
            bezierPathLoader.move(to: CGPoint(x: 0, y: superview.frame.height - 3))
            bezierPathLoader.addLine(to: CGPoint(x: superview.frame.width, y: superview.frame.height - 3))
            
            let bezierPathSeparator = UIBezierPath()
            bezierPathSeparator.move(to: CGPoint(x: 0, y: superview.frame.height - 1))
            bezierPathSeparator.addLine(to: CGPoint(x: superview.frame.width, y: superview.frame.height - 1))
            
            layerLoader.path = bezierPathLoader.cgPath
            layerSeparator.path = bezierPathSeparator.cgPath
        }
    }
}
