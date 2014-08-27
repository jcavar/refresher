//
//  ViewController.swift
//  PullToRefresh
//
//  Created by Josip Cavar on 13/08/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import UIKit
import Refresher

class ViewController: UIViewController {
                            
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.addPullToRefreshWithAction({ () -> () in
            
            NSOperationQueue().addOperationWithBlock {
                
                sleep(2)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.stopPullToRefresh()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {

        return 50
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.textLabel.text = "Row " + String(indexPath.row + 1)
        return cell
    }
}

