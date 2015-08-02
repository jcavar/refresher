//
//  ChooseModeViewController.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 01/08/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit

class ChooseModeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func defaultAction(sender: AnyObject) {
        showControllerWithMode(.Default)
    }

    @IBAction func beatAction(sender: AnyObject) {
        showControllerWithMode(.Beat)
    }
    
    @IBAction func pacmanAction(sender: AnyObject) {
        showControllerWithMode(.Pacman)
    }
    
    @IBAction func customAction(sender: AnyObject) {
        showControllerWithMode(.Custom)
    }
    
    func showControllerWithMode(mode: ExampleMode) {
        if let pullToRefreshViewControler = self.storyboard?.instantiateViewControllerWithIdentifier("PullToRefreshViewController") as? PullToRefreshViewController {
            pullToRefreshViewControler.exampleMode = mode
            navigationController?.pushViewController(pullToRefreshViewControler, animated: true)
        }
    }
}
