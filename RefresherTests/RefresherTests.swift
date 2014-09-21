//
// RefresherTests.swift
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
