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
    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testScrollViewBouncesWhenFalse() {
        
        var scrollView = UIScrollView()
        scrollView.bounces = false;
        scrollView.addPullToRefreshWithAction({ () -> () in
        })
        scrollView.startPullToRefresh()
        XCTAssertTrue(!scrollView.bounces, "bounces should be false")
        scrollView.stopPullToRefresh()
        XCTAssertFalse(scrollView.bounces, "bounces should be false")
    }
    
    func testScrollViewBouncesWhenTrue() {
        
        var scrollView = UIScrollView()
        scrollView.bounces = true;
        scrollView.addPullToRefreshWithAction({ () -> () in
        })
        scrollView.startPullToRefresh()
        XCTAssertTrue(!scrollView.bounces, "bounces should be false")
        scrollView.stopPullToRefresh()
        XCTAssertTrue(scrollView.bounces, "bounces should be true")
    }
    
    func testPullToRefreshViewLoading() {
    
        var scrollView = UIScrollView()
        scrollView.addPullToRefreshWithAction({ () -> () in
        })
        scrollView.startPullToRefresh()
        if (scrollView.pullToRefreshView != nil) {
            XCTAssertTrue(scrollView.pullToRefreshView!.loading, "loading should be true")
            scrollView.stopPullToRefresh()
            XCTAssertFalse(scrollView.pullToRefreshView!.loading, "loading should be false")
        } else {
            XCTAssertNotNil(scrollView.pullToRefreshView, "pullToRefreshView should not be nil")
        }
    }
    
    func testPullToRefreshViewFrame() {
        
        var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 500))
        scrollView.addPullToRefreshWithAction({ () -> () in
        })
        if (scrollView.pullToRefreshView != nil) {
            XCTAssertEqual(scrollView.pullToRefreshView!.frame.width, scrollView.frame.width, "scrollView and pullToRefreshView should have same width")
            XCTAssertGreaterThan(scrollView.pullToRefreshView!.frame.height, 0, "height should be grater than zero")
        } else {
            XCTAssertNotNil(scrollView.pullToRefreshView, "pullToRefreshView should not be nil")
        }
    }
    
}
