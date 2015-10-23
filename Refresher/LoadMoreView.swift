//
//  LoadMoreView.swift
//  PullToRefresh
//
//  Created by Ievgen Rudenko on 13/09/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit

private var LoadMoreKVOContext = "LoadMoreKVOContext"
private let ContentOffsetKeyPath = "contentOffset"
private let ContentSizeKeyPath = "contentSize"


public enum LoadMoreViewState {
    case Loading
    case ScrollToLoadMore
    case ReleaseToLoadMore
}

public protocol LoadMoreViewDelegate {
    func loadMoreAnimationDidStart(view: LoadMoreView)
    func loadMoreAnimationDidEnd(view: LoadMoreView)
    func loadMore(view: LoadMoreView, progressDidChange progress: CGFloat)
    func loadMore(view: LoadMoreView, stateDidChange state: LoadMoreViewState)
}

public class LoadMoreView: UIView {
    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsetsZero
    
    private var animator: LoadMoreViewDelegate
    private var action: (() -> ()) = {}
    
    private var previousOffset: CGFloat = 0
    
    public var disabled = false {
        didSet {
            hidden = disabled
            if disabled == true {
                if loading == true {
                    loading = false
                }
                animator.loadMore(self, stateDidChange: .ScrollToLoadMore)
                animator.loadMore(self, progressDidChange: 0)
            }
        }
    }
    
    internal var loading: Bool = false {
        didSet {
            if loading {
                startAnimating(true)
            } else {
                stopAnimating(true)
            }
        }
    }

    //MARK: Object lifecycle methods
    convenience init(action :(() -> ()), frame: CGRect) {
        var bounds = frame
        bounds.origin.y = 0
        let animator = Animator(frame: bounds)
        self.init(frame: frame, animator: animator)
        self.action = action;
        addSubview(animator.animatorView)
    }
    
    convenience init(action :(() -> ()), frame: CGRect, animator: LoadMoreViewDelegate, subview: UIView) {
        self.init(frame: frame, animator: animator)
        self.action = action;
        subview.frame = self.bounds
        addSubview(subview)
    }
    
    convenience init(action :(() -> ()), frame: CGRect, animator: LoadMoreViewDelegate) {
        self.init(frame: frame, animator: animator)
        self.action = action;
    }
    
    init(frame: CGRect, animator: LoadMoreViewDelegate) {
        self.animator = animator
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.animator = Animator(frame: CGRectZero)
        super.init(coder: aDecoder)
        // Currently it is not supported to load view from nib
        //it's little bit hacky
    }
    
    deinit {
        let scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &LoadMoreKVOContext)
        scrollView?.removeObserver(self, forKeyPath: ContentSizeKeyPath, context: &LoadMoreKVOContext)
    }
    

    //MARK: UIView methods
    
    public override func willMoveToSuperview(newSuperview: UIView!) {
        superview?.removeObserver(self, forKeyPath: ContentOffsetKeyPath, context: &LoadMoreKVOContext)
        superview?.removeObserver(self, forKeyPath: ContentSizeKeyPath, context: &LoadMoreKVOContext)
        self.animator.loadMore(self, progressDidChange: 0.0)

        if let scrollView = newSuperview as? UIScrollView {
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
            processContentChange(scrollView: scrollView)
            scrollView.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: .Initial, context: &LoadMoreKVOContext)
            scrollView.addObserver(self, forKeyPath: ContentSizeKeyPath, options: .Initial, context: &LoadMoreKVOContext)

        }
    }
    
    
    //MARK: KVO methods
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &LoadMoreKVOContext) {
            if let scrollView = superview as? UIScrollView where object as? NSObject == scrollView {
                if keyPath == ContentOffsetKeyPath {
                    processOffsetChange(scrollView: scrollView)
                } else if keyPath == ContentSizeKeyPath {
                    processContentChange(scrollView: scrollView)
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func processOffsetChange(scrollView scrollView: UIScrollView) {

        if disabled == true { return }
        
        var contentHeight:CGFloat = 0
        if let collectionView = scrollView as? UICollectionView {
            contentHeight = collectionView.collectionViewLayout.collectionViewContentSize().height
        } else {
            contentHeight = scrollView.contentSize.height
        }
        

        
        let overOffset = scrollView.contentSize.height <  scrollView.frame.size.height ?
            previousOffset:
            (previousOffset + scrollView.frame.size.height) - contentHeight
        
        if (overOffset > frame.size.height) {
            if (scrollView.dragging == false && loading == false) {
                loading = true
            } else if (loading) {
                self.animator.loadMore(self, stateDidChange: .Loading)
            } else {
                self.animator.loadMore(self, stateDidChange: .ReleaseToLoadMore)
                self.animator.loadMore(self, progressDidChange: overOffset / frame.size.height)
            }
        } else if (loading) {
            self.animator.loadMore(self, stateDidChange: .Loading)
        } else if (overOffset > 0) {
            self.animator.loadMore(self, stateDidChange: .ScrollToLoadMore)
            self.animator.loadMore(self, progressDidChange: overOffset / frame.size.height)
        }
        previousOffset = scrollView.contentOffset.y

    }

    func processContentChange(scrollView scrollView: UIScrollView) {
        
        // change contentSize
        
        if scrollView.contentSize.height == 0 {
            frame.origin.y = scrollView.frame.size.height
        } else if scrollView.contentSize.height <  scrollView.frame.size.height {
            frame.origin.y = scrollView.frame.size.height
        } else {
            frame.origin.y = scrollView.contentSize.height
        }
    }

    
    //MARK: ScrollToLoadMore methods
    
    internal func startAnimating(animated:Bool) {
        if let scrollView = superview as? UIScrollView {
            var insets = scrollView.contentInset
            insets.bottom += scrollView.contentSize.height <  scrollView.frame.size.height ?
                scrollView.frame.size.height - scrollView.contentSize.height + frame.size.height:
                frame.size.height
            
            self.scrollViewBouncesDefaultValue = scrollView.bounces
            scrollView.bounces = false
            if animated == true {
                UIView.animateWithDuration(0.3, delay: 0, options:[], animations: {
                    scrollView.contentInset = insets
                }, completion: {finished in
                    self.animator.loadMoreAnimationDidStart(self)
                    self.action()
                })
            } else {
                scrollView.contentInset = insets
                self.animator.loadMoreAnimationDidStart(self)
                self.action()
            }
        }
    }
    
    internal func stopAnimating(animated:Bool) {
        self.animator.loadMoreAnimationDidEnd(self)
        if let scrollView = superview as? UIScrollView {
            scrollView.bounces = self.scrollViewBouncesDefaultValue
            if animated == true {
                UIView.animateWithDuration(0.3, animations: {
                    scrollView.contentInset = self.scrollViewInsetsDefaultValue
                }) { finished in
                    self.animator.loadMore(self, progressDidChange: 0.0)
                }
            } else {
                scrollView.contentInset = self.scrollViewInsetsDefaultValue
                self.animator.loadMore(self, progressDidChange: 0.0)
            }
        }
    }
    
}
