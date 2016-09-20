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
    
    @IBAction func defaultAction(_ sender: AnyObject) {
        showControllerWithMode(.default)
    }

    @IBAction func beatAction(_ sender: AnyObject) {
        showControllerWithMode(.beat)
    }
    
    @IBAction func pacmanAction(_ sender: AnyObject) {
        showControllerWithMode(.pacman)
    }
    
    @IBAction func customAction(_ sender: AnyObject) {
        showControllerWithMode(.custom)
    }
    
    func showControllerWithMode(_ mode: ExampleMode) {
        if let pullToRefreshViewControler = self.storyboard?.instantiateViewController(withIdentifier: "PullToRefreshViewController") as? PullToRefreshViewController {
            pullToRefreshViewControler.exampleMode = mode
            navigationController?.pushViewController(pullToRefreshViewControler, animated: true)
        }
    }
}
