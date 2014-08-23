//
//  RefresherTests.swift
//  RefresherTests
//
//  Created by Josip Cavar on 23/08/14.
//  Copyright (c) 2014 Josip Cavar. All rights reserved.
//

import UIKit
import XCTest

class RefresherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*
    func testPullToRefreshViewLoading() {
    
    var scrollView = UIScrollView()
    scrollView.addPullToRefreshWithAction({ () -> () in
    })
    scrollView.startPullToRefresh()
    XCTAssertNotNil(scrollView.pullToRefreshView, "pullToRefreshView should not be nil")
    if (scrollView.pullToRefreshView != nil) {
    XCTAssertTrue(scrollView.pullToRefreshView!.loading, "loading should be true")
    scrollView.stopPullToRefresh()
    XCTAssertFalse(scrollView.pullToRefreshView!.loading, "loading should be false")
    }
    }
    */
    
    func testPullToRefreshViewFrame() {
        
        var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 500))
        scrollView.addPullToRefreshWithAction({ () -> () in
        })
        //scrollView.pullToRefreshView!
        /*
        if (scrollView.pullToRefreshView != nil) {
        XCTAssertEqual(scrollView.pullToRefreshView!.frame.width, scrollView.frame.width, "scrollView and pullToRefreshView should have same width")
        XCTAssertGreaterThan(scrollView.pullToRefreshView!.frame.height, 0, "height should be grater than zero")
        } else {
        XCTAssertNotNil(scrollView.pullToRefreshView, "pullToRefreshView should not be nil")
        }
        */
    }
    
}
