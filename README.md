#Refresher  

Refresher is pull to refresh library written in Swift.

![alt preview](https://raw.githubusercontent.com/jcavar/refresher/master/preview.gif)

##Usage


###Basic usage
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
###Custom animations

##Requirements

##Installation

##Credits

Refresher is created by [Josip Cavar](https://twitter.com/josip04) and inspired by [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh/)

