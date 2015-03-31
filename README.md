<img src="https://raw.githubusercontent.com/jcavar/refresher/master/refresher.png" width="250" />

[![Build Status](https://travis-ci.org/jcavar/refresher.svg)](https://travis-ci.org/jcavar/refresher)
 
Refresher is pull to refresh library written in Swift. It provides easy to use UIScrollView methods to add pull to refresh to your view. 
Refresher also supports custom animations.

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

Refresher supports custom animations on `PullToRefreshView`. You need to create object that conforms to `PullToRefreshViewAnimator` protocol.
Then, just pass your custom animator in `addPullToRefrshWithAction`:

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

Required methods that your custom object need to implement are:

*   `func startAnimation()` - Called when user release finger from phone and when loading actually starts. Here you need to start your animations.
*   `func stopAnimation()` - Called when loading is over. Stop your animations here.
*   `func changeProgress(progress: CGFloat)` - Called when user is pulling view. If you want to implement some progress like behaviour on pull this method is called.
*   `func layoutLayers(superview: UIView)` - Called when layoutSubviews method is called. Here you want to implement layout changes and add your layers or views to view.

##Requirements

*	Xcode 6
*	iOS 8.0

##Installation

###Git submodule

1.	Add Refresher as a git submodule into your top-level project directory or simply copy whole folder
2.	Find `PullToRefresh.xcodeproj` and drag it into the file navigator of your app project.
3.	In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4.	Under "General" panel go to "Linked Frameworks and Libraries" and add `Refresher.framework`

###Framework

1.	Simply download Refresher
2.	Build it and you should find `Refresher.framework` under "Products" group.
3.	Right click on it and select "Show in Finder" option.
4.	Just drag and drop `Refresher.framework` to your project

###Cocoapods

1.	Add `pod 'Refresher'` to your Podfile
2.	Run `pod install`

##Examples

![Refresher: preview default](https://raw.githubusercontent.com/jcavar/refresher/master/previews/anim_default.gif)
![Refresher: preview beat](https://raw.githubusercontent.com/jcavar/refresher/master/previews/anim_beat.gif)
![Refresher: preview pacman](https://raw.githubusercontent.com/jcavar/refresher/master/previews/anim_pacman.gif)

##Credits

Refresher is created by [Josip Ćavar](https://twitter.com/josip04) and inspired by [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh/). If you have suggestions or bug reports, feel free to send pull request or [create new issue](https://github.com/jcavar/refresher/issues/new).

