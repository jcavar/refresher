#Refresher  

Refresher is pull to refresh library written in Swift.

![alt preview](https://raw.githubusercontent.com/jcavar/refresher/master/preview.gif)
![alt preview custom](https://raw.githubusercontent.com/jcavar/refresher/master/preview_custom.gif)

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

Refresher supports custom animations on Pull to refresh view. You need to create object that conforms to PullToRefreshViewAnimator protocol.
Then, just pass your custom animator in addPullToRefrshWithAction:

```swift
tableView.addPullToRefreshWithAction({           
  	NSOperationQueue().addOperationWithBlock {
   		sleep(2)
        NSOperationQueue.mainQueue().addOperationWithBlock {
        	self.tableView.stopPullToRefresh()
        }
    }
}, withAnimator: CustomAnimator())
```

##Requirements

*	Xcode 6 Beta 5
*	iOS 8.0

##Installation

##Credits

Refresher is created by [Josip Cavar](https://twitter.com/josip04) and inspired by [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh/)

