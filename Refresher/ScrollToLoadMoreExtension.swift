//
//  LoadMoreExtension.swift
//  PullToRefresh
//
//  Created by Ievgen Rudenko on 13/09/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import Foundation

private let scrollToLoadMoreTag = 325
private let scrollToLoadMoreDefaultHeight: CGFloat = 50

//LoadMore extension
extension UIScrollView {
    
    // Actual UIView subclass which is added as subview to desired UIScrollView. If you want customize appearance of this object, do that after addLoadMore
    public var loadMoreView: LoadMoreView? {
        get {
            let loadMoreView = viewWithTag(scrollToLoadMoreTag)
            return loadMoreView as? LoadMoreView
        }
    }
    
    // If you want to add pull to refresh functionality to your UIScrollView just call this method and pass action closure you want to execute while pull to refresh is animating. If you want to stop pull to refresh you must do that manually calling stopPullToRefreshView methods on your scroll view
    public func addLoadMore(#action:(() -> ())) {
        let y = contentSize.height + contentInset.bottom + contentInset.top
        let loadMoreView = LoadMoreView(action: action, frame: CGRectMake(0, y, self.frame.size.width, scrollToLoadMoreDefaultHeight))
        loadMoreView.tag = scrollToLoadMoreTag
        addSubview(loadMoreView)
//        loadMoreView.hidden = true;
    }
    
    // If you want to use your custom animation and custom subview when pull to refresh is animating, you should call this method and pass your animator and view objects.
    public func addLoadMore(#animator: LoadMoreViewDelegate, subview: UIView, action:(() -> ())) {
        let height = subview.frame.height
        let y = contentSize.height + contentInset.bottom + contentInset.top
        let loadMoreView = LoadMoreView(action: action, frame: CGRectMake(0, y, self.frame.size.width, height), animator: animator, subview: subview)
        loadMoreView.tag = scrollToLoadMoreTag
        addSubview(loadMoreView)
//        loadMoreView.hidden = true;
    }
    
    //
    public func addLoadMore<T: UIView where T: LoadMoreViewDelegate>(#animator: T, action:(() -> ())) {
        let height = animator.frame.height
        let y = contentSize.height + contentInset.bottom + contentInset.top
        let loadMoreView = LoadMoreView(action: action, frame: CGRectMake(0, y, self.frame.size.width, height), animator: animator, subview: animator)
        loadMoreView.tag = scrollToLoadMoreTag
        addSubview(loadMoreView)
//        loadMoreView.hidden = true;
    }
    
    // Manually start load more action
    public func startLoadMore() {
        loadMoreView?.loading = true
    }
    
    // Manually stop load more action
    public func stopLoadMore() {
        loadMoreView?.loading = false
    }
}