//
//  ConnectionLostViewController.swift
//  PullToRefresh
//
//  Created by Ievgen Rudenko on 23/10/15.
//  Copyright © 2015 Josip Cavar. All rights reserved.
//

import UIKit

class ConnectionLostViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var rowsCount = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addReachability { status in
            print("reachability changed \(status)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.rowsCount
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Row " + String(indexPath.row + 1)
        return cell
    }

    @IBAction func showView(sender: AnyObject) {
        tableView.showReachabilityView()
    }

    @IBAction func hideView(sender: AnyObject) {
        tableView.hideReachabilityView()
    }
}
