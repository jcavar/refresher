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
    case `default`
    case beat
    case pacman
    case custom
}

class PullToRefreshViewController: UIViewController {
                            
    @IBOutlet weak var tableView: UITableView!
    var exampleMode = ExampleMode.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch exampleMode {
        case .default:
            tableView.addPullToRefreshWithAction {
                OperationQueue().addOperation {
                    sleep(2)
                    OperationQueue.main.addOperation {
                        self.tableView.stopPullToRefresh()
                    }
                }
            }
        case .beat:
            let beatAnimator = BeatAnimator(frame: CGRect(x: 0, y: 0, width: 320, height: 80))
            tableView.addPullToRefreshWithAction({
                OperationQueue().addOperation {
                    sleep(2)
                    OperationQueue.main.addOperation {
                        self.tableView.stopPullToRefresh()
                    }
                }
            }, withAnimator: beatAnimator)
        case .pacman:
            let pacmanAnimator = PacmanAnimator(frame: CGRect(x: 0, y: 0, width: 320, height: 80))
            tableView.addPullToRefreshWithAction({
                OperationQueue().addOperation {
                    sleep(2)
                    OperationQueue.main.addOperation {
                        self.tableView.stopPullToRefresh()
                    }
                }
            }, withAnimator: pacmanAnimator)
        case .custom:
            if let customSubview = Bundle.main.loadNibNamed("CustomSubview", owner: self, options: nil)?.first as? CustomSubview {
                tableView.addPullToRefreshWithAction({
                    OperationQueue().addOperation {
                        sleep(2)
                        OperationQueue.main.addOperation {
                            self.tableView.stopPullToRefresh()
                        }
                    }
                }, withAnimator: customSubview)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.startPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tableView(_ tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    @objc func tableView(_ tableView: UITableView!, cellForRowAtIndexPath indexPath: IndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Row " + String(indexPath.row + 1)
        return cell
    }
}

