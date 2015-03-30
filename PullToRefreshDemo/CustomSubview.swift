//
//  CustomSubview.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 30/03/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit
import Refresher

class CustomSubview: UIView, PullToRefreshViewAnimator {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelTitle: UILabel!
    
    func startAnimation() {
        
        activityIndicator.startAnimating()
    }
    
    func stopAnimation() {
        
        activityIndicator.stopAnimating()
    }
    
    func changeProgress(progress: CGFloat) {
        
    }
    
    func layoutLayers(superview: UIView) {
        
    }
}
