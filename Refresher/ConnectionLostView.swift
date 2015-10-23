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
    public var disableBouncesOnShow:Bool = false
    private let reachability: Reachability?
    

    
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
        reachability?.stopNotifier()
    }


    
    //MARK: UIView methods
    public override func willMoveToSuperview(newSuperview: UIView!) {
        if let scrollView = newSuperview as? UIScrollView {
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
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
            
            scrollView.bounces = false
            self.hidden = false
            self.alpha = 0.0
            UIView.animateWithDuration(0.3, delay: 0, options:[], animations: {
                scrollView.contentInset = insets
                self.alpha = 1.0
                scrollView.contentOffset = CGPoint(x: 0, y: -insets.top)
            }, completion: {finished in
                self.connectionStateChanged(newStatus: .NotReachable)
            })
        }
    }
    
}
