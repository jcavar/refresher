//
// PullToRefreshView.swift
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

import UIKit
import QuartzCore

private var KVOContext = "RefresherKVOContext"
private let ContentOffsetKeyPath = "contentOffset"

public class PullToRefreshView: UIView {
    public typealias PullToRefreshAction = () -> ()
    public enum State {
//        case Inactive = 0 // Maybe in the future we will want to distinguish here
        case Pulling
        case ReadyToRelease
        case Refreshing
    }
    
    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsetsZero
    
    private let animationOptions: UIViewAnimationOptions = (.AllowAnimatedContent | .BeginFromCurrentState)
    public let animationDuration: NSTimeInterval = 0.3
    
    internal var action: PullToRefreshAction = {}
    
    private var previousOffset: CGFloat = 0
    
    internal var loading: Bool = false {
        didSet {
            if loading {
                state = .Refreshing
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    public private(set) var state: State = .Pulling {
        didSet { stateChanged(oldValue) }
    }
    
    // MARK: Object lifecycle methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
//    public override init() {
//        super.init()
//    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    public func initialize() { } // Overridden by subclasses
    
    deinit {
        (superview as? UIScrollView)?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
    }
    
    // MARK: - UIView methods
    public override func willMoveToSuperview(newSuperview: UIView!) {
        superview?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
    }
    
    public override func didMoveToSuperview() {
        if let scrollView = superview as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: .Initial, context: &KVOContext)
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
        }
    }
    
    // MARK: - KVO method
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        if context == &KVOContext && keyPath == ContentOffsetKeyPath && object as? UIView == superview {
            if let scrollView = object as? UIScrollView {
//                println("Refresher: y content offset: \(scrollView.contentOffset.y)")
                let offsetWithoutInsets = previousOffset + scrollViewInsetsDefaultValue.top
                if offsetWithoutInsets < -frame.size.height {
                    if !scrollView.dragging && !loading {
                        loading = true
                    } else if !loading {
                        state = .ReadyToRelease
                        changeProgress(-offsetWithoutInsets / frame.size.height)
                    }
                } else if !loading && offsetWithoutInsets < 0.0 {
                    state = .Pulling
                    changeProgress(-offsetWithoutInsets / frame.size.height)
                }
                previousOffset = scrollView.contentOffset.y
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - PullToRefreshView methods
    public func startAnimating() {
        if let scrollView = superview as? UIScrollView {
            var insets = scrollView.contentInset
            insets.top += frame.size.height
            // we need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
            scrollView.contentOffset.y = previousOffset
            scrollView.bounces = false
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationOptions, animations: {
                scrollView.contentInset = insets
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets.top)
                }) { finished in
                    self.action()
            }
        }
    }
    
    public func stopAnimating() {
        if let scrollView = superview as? UIScrollView {
            scrollView.bounces = scrollViewBouncesDefaultValue
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationOptions, animations: {
                scrollView.contentInset = self.scrollViewInsetsDefaultValue
                }) { finished in
                    self.changeProgress(0.0)
            }
        }
    }
    
    public func changeProgress(progress: CGFloat) { } // Overridden by subclasses
    
    public func stateChanged(previousState: State) { } // Overridden by subclasses
}
