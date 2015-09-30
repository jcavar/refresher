//
// ViewController.swift
//
// Copyright (c) 2014 Josip Cavar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Refresher

enum ExampleMode {
    case Default
    case Beat
    case Pacman
    case Custom
}

class PullToRefreshViewController: UIViewController {
                            
    @IBOutlet weak var tableView: UITableView!
    var exampleMode = ExampleMode.Default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch exampleMode {
        case .Default:
            tableView.addPullToRefreshWithAction {
                NSOperationQueue().addOperationWithBlock {
                    sleep(2)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.stopPullToRefresh()
                    }
                }
            }
        case .Beat:
            let beatAnimator = BeatAnimator(frame: CGRectMake(0, 0, 320, 80))
            tableView.addPullToRefreshWithAction({
                NSOperationQueue().addOperationWithBlock {
                    sleep(2)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.stopPullToRefresh()
                    }
                }
            }, withAnimator: beatAnimator)
        case .Pacman:
            let pacmanAnimator = PacmanAnimator(frame: CGRectMake(0, 0, 320, 80))
            tableView.addPullToRefreshWithAction({
                NSOperationQueue().addOperationWithBlock {
                    sleep(2)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.stopPullToRefresh()
                    }
                }
            }, withAnimator: pacmanAnimator)
        case .Custom:
            if let customSubview = NSBundle.mainBundle().loadNibNamed("CustomSubview", owner: self, options: nil).first as? CustomSubview {
                tableView.addPullToRefreshWithAction({
                    NSOperationQueue().addOperationWithBlock {
                        sleep(2)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.tableView.stopPullToRefresh()
                        }
                    }
                }, withAnimator: customSubview)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.startPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Row " + String(indexPath.row + 1)
        return cell
    }
}

