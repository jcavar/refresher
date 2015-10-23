//
//  ConnectionLostView.swift
//  Pods
//
//  Created by Ievgen Rudenko on 22/10/15.
//
//

import Foundation
import UIKit
import ReachabilitySwift

private var KVOContext = "NoConnectionKVOContext"
private let ContentOffsetKeyPath = "contentOffset"

internal class ConnectionLostDefaultSubview: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Internet connection lost"
        label.textAlignment = .Center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(titleLabel)
        //#FF3B30
        backgroundColor = UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1)

        let leftTitleConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 16)
        let rightTitleConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 16)
        let centerTitleConstraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0)
        addConstraints([rightTitleConstraint, leftTitleConstraint, centerTitleConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ConnectionLostView: UIView {
    
    private var connectionStateChanged: ((newStatus: Reachability.NetworkStatus) -> ()) = { status in }
    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsetsZero
    private let reachability: Reachability?
    
    //When internet is unreachable, siable bounces to block load more and pull to refresh
    public var disableBouncesOnShow:Bool = true
    //Stick mode put view not in the inset area, but stick on top of scrollView
    public var stickMode:Bool = false {
        didSet {
            changeStickMode()
        }
    }

    

    
    //MARK: Object lifecycle methods

    convenience init(view: UIView, action :((newStatus: Reachability.NetworkStatus) -> ())) {
        view.frame.origin = CGPoint(x:0, y:0)
        self.init(frame: view.frame)
        self.addSubview(view)
        self.autoresizingMask = .FlexibleWidth
        view.autoresizingMask = .FlexibleWidth
        self.connectionStateChanged = action
    }

    
    convenience init(frame: CGRect, action :((newStatus: Reachability.NetworkStatus) -> ())) {
        self.init(frame: frame)
        self.connectionStateChanged = action
    }

    
    override init(frame: CGRect) {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            reachability = nil
        }
        var newFrame = frame
        newFrame.origin.y = -newFrame.size.height
        super.init(frame: newFrame)
        self.autoresizingMask = .FlexibleWidth
        
        if let reachability = reachability {
            reachability.whenReachable = { reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    self.becomeReachable()
                }
            }
            reachability.whenUnreachable = { reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    self.becomeUnreachable()
                }
            }
            
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        reachability = nil
        super.init(coder: aDecoder)
        // Currently it is not supported to load view from nib
    }
    
    deinit {
        if stickMode == true {
            superview?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
        }
        reachability?.stopNotifier()
    }


    
    //MARK: UIView methods
    public override func willMoveToSuperview(newSuperview: UIView!) {
        if stickMode == true {
            superview?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
        }
        if let scrollView = newSuperview as? UIScrollView {
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
            if stickMode == true {
                scrollView.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: .Initial, context: &KVOContext)
            }
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext) {
            if let scrollView = superview as? UIScrollView where object as? NSObject == scrollView {
                if keyPath == ContentOffsetKeyPath {
                    self.updateStickyViewPosition(scrollView)
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    

    //MARK: Reachability methods
    
    internal func becomeReachable() {
        //always happends in main thread
        if let scrollView = superview as? UIScrollView {
            scrollViewBouncesDefaultValue = scrollView.bounces
            UIView.animateWithDuration(0.3, animations: {
                scrollView.contentInset = self.scrollViewInsetsDefaultValue
                self.alpha = 0.0
            }) { finished in
                self.hidden = true
                self.connectionStateChanged(newStatus: self.reachability?.currentReachabilityStatus ?? .ReachableViaWWAN)
            }
        }
    }
    
    internal func becomeUnreachable() {
        //always happends in main thread
        if let scrollView = superview as? UIScrollView {
            if let pullToRefreshView  = scrollView.pullToRefreshView {
                pullToRefreshView.stopAnimating(false)
            }
            if let loadMoreView = scrollView.loadMoreView {
                loadMoreView.startAnimating(false)
            }
            
            var insets = scrollView.contentInset
            insets.top += self.frame.size.height
            
            scrollView.bounces = disableBouncesOnShow
            self.hidden = false
            self.alpha = 0.0
            UIView.animateWithDuration(0.3, delay: 0, options:[], animations: {
                scrollView.contentInset = insets
                self.alpha = 1.0
                if self.stickMode == false {
                    scrollView.contentOffset = CGPoint(x: 0, y: -insets.top)
                }
            }, completion: {finished in
                if self.stickMode == true {
                    self.updateStickyViewPosition(scrollView)
                }
                self.connectionStateChanged(newStatus: .NotReachable)
            })
        }
    }
    
    
    
    //MARK: Private methods
    
    private func updateStickyViewPosition(scrollView:UIScrollView) {
        self.frame.origin.y = scrollView.contentOffset.y
    }
    
    private func changeStickMode() {
        if stickMode ==  true {
            if let scrollView = superview as? UIScrollView {
                scrollView.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: .Initial, context: &KVOContext)
                updateStickyViewPosition(scrollView)
                if self.hidden == false {
                    scrollView.contentInset = self.scrollViewInsetsDefaultValue
                }
            }
        } else {
            superview?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &KVOContext)
            self.frame.origin.y = -frame.size.height
            if let scrollView = superview as? UIScrollView where self.hidden == false {
                var insets = scrollView.contentInset
                insets.top += self.frame.size.height
                scrollView.contentInset = insets
            }
        }
    }
    
}
