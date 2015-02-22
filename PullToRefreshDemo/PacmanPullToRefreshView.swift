//
// PacmanPullToRefreshView.swift
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
import UIKit

class PacmanPullToRefreshView: PullToRefreshView {
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = .Center
        return label
        }()
    
    private let layerLoader: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 8.0
        layer.strokeColor = UIColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0).CGColor
        layer.strokeEnd = 0.0
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
        }()
    private let layerSeparator: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 8.0
        layer.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0).CGColor
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
        }()
    
    override func initialize() {
        super.initialize()
        layer.addSublayer(layerSeparator)
        layer.addSublayer(layerLoader)
        
        addSubview(labelTitle)
        let views = ["labelTitle": labelTitle]
        let formats = ["H:|-(>=10)-[labelTitle]-(>=10)-|", "V:|-(>=15,==15@500)-[labelTitle]-(>=15,==15@500)-|"]
        let constraints = formats.reduce([AnyObject]()) { constraints, format in
            return constraints + NSLayoutConstraint.constraintsWithVisualFormat(format, options: nil, metrics: nil, views: views)
            } + [
                NSLayoutConstraint(item: labelTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: labelTitle, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        ]
        addConstraints(constraints)
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50.0))
    }
    
    override func startAnimating() {
        super.startAnimating()
        
        let pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationEnd.duration = 0.5
        pathAnimationEnd.repeatCount = 100
        pathAnimationEnd.autoreverses = true
        pathAnimationEnd.fromValue = 1.0
        pathAnimationEnd.toValue = 0.8
        layerLoader.addAnimation(pathAnimationEnd, forKey: "strokeEndAnimation")
        
        let pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationStart.duration = 0.5
        pathAnimationStart.repeatCount = 100
        pathAnimationStart.autoreverses = true
        pathAnimationStart.fromValue = 0.0
        pathAnimationStart.toValue = 0.2
        layerLoader.addAnimation(pathAnimationStart, forKey: "strokeStartAnimation")
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        layerLoader.removeAllAnimations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: 30.0, y: frame.size.height / 2.0)
        let endAngle = CGFloat(2.0 * M_PI)
        let bezierPathLoader = UIBezierPath(arcCenter: center, radius: 10.0, startAngle: 0.0, endAngle: endAngle, clockwise: true)
        let bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPoint(x: 0.0, y: frame.height - 1.0))
        bezierPathSeparator.addLineToPoint(CGPoint(x: frame.width, y: frame.height - 1.0))
        
        layerLoader.path = bezierPathLoader.CGPath
        layerSeparator.path = bezierPathLoader.CGPath
    }
    
    override func changeProgress(progress: CGFloat) {
        super.changeProgress(progress)
        layerLoader.strokeEnd = progress
    }
    
    override func stateChanged(previousState: State) {
        super.stateChanged(previousState)
        switch state {
        case .Pulling:
            labelTitle.text = "Pull to refresh"
        case .ReadyToRelease:
            labelTitle.text = "Release to refresh"
        case .Refreshing:
            labelTitle.text = "Loading ..."
        }
    }
}