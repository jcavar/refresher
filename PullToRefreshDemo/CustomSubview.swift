//
//  CustomSubview.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 30/03/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit
import Refresher


class CustomSubview: UIView, PullToRefreshViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelTitle: UILabel!
    
    func pullToRefreshAnimationDidStart(view: PullToRefreshView) {
        activityIndicator.startAnimating()
        labelTitle.text = "Loading"
    }
    
    func pullToRefreshAnimationDidEnd(view: PullToRefreshView) {
        activityIndicator.stopAnimating()
        labelTitle.text = ""
    }
    
    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
    
    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        
        switch state {
        case .Loading:
            labelTitle.text = "Loading"
        case .PullToRefresh:
            labelTitle.text = "Pull to refresh"
        case .ReleaseToRefresh:
            labelTitle.text = "Release to refresh"
        }
    }
}