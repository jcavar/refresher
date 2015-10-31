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

internal class AnimatorView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(titleLabel)
        addSubview(activityIndicatorView)
        
        let leftActivityConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 16)
        let centerActivityConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        let leftTitleConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: activityIndicatorView, attribute: .Right, multiplier: 1, constant: 16)
        let centerTitleConstraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0)

        addConstraints([leftActivityConstraint, centerActivityConstraint, leftTitleConstraint, centerTitleConstraint])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Animator: PullToRefreshViewDelegate {
    
    internal let animatorView: AnimatorView

    init(frame: CGRect) {
        animatorView = AnimatorView(frame: frame)
    }
    
    func pullToRefreshAnimationDidStart(view: PullToRefreshView) {
        animatorView.activityIndicatorView.startAnimating()
        animatorView.titleLabel.text = "Loading"
    }
    
    func pullToRefreshAnimationDidEnd(view: PullToRefreshView) {
        animatorView.activityIndicatorView.stopAnimating()
        animatorView.titleLabel.text = ""
    }
    
    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
    
    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .Loading:
            animatorView.titleLabel.text = "Loading"
        case .PullToRefresh:
            animatorView.titleLabel.text = "Pull to refresh"
        case .ReleaseToRefresh:
            animatorView.titleLabel.text = "Release to refresh"
        }
    }
}