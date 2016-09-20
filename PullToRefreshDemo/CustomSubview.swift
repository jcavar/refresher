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
    
    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        activityIndicator.startAnimating()
        labelTitle.text = "Loading"
    }
    
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        activityIndicator.stopAnimating()
        labelTitle.text = ""
    }
    
    func pullToRefresh(_ view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
    
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        
        switch state {
        case .loading:
            labelTitle.text = "Loading"
        case .pullToRefresh:
            labelTitle.text = "Pull to refresh"
        case .releaseToRefresh:
            labelTitle.text = "Release to refresh"
        }
    }
}
