#refresher  

refresher is pull to refresh library written in Swift.

![alt preview](https://raw.githubusercontent.com/jcavar/refresher/master/preview.gif)

##Usage

```swift
tableView.addPullToRefreshWithAction {
	NSOperationQueue().addOperationWithBlock {
    	sleep(2)
        NSOperationQueue.mainQueue().addOperationWithBlock {
        	self.tableView.stopPullToRefresh()
        }
    }
}
```

##Requirements

##Installation

##Credits

refresher is created by [Josip Cavar](https://twitter.com/josip04) and inspired by [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh/)

