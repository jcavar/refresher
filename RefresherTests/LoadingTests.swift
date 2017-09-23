//
// LoadingTests.swift
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

class LoadingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPullToRefreshViewLoading() {
        let scrollView = UIScrollView()
        scrollView.addPullToRefreshWithAction { }
        scrollView.startPullToRefresh()
        XCTAssertNotNil(scrollView.pullToRefreshView, "pullToRefreshView should not be nil")
        XCTAssertTrue(scrollView.pullToRefreshView!.loading, "loading should be true")
        scrollView.stopPullToRefresh()
        XCTAssertFalse(scrollView.pullToRefreshView!.loading, "loading should be false")
    }
    
    func testPullToRefreshViewLoadingWithInsets() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 500))
        scrollView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)

        scrollView.addPullToRefreshWithAction { }
        scrollView.startPullToRefresh()
        XCTAssertNotNil(scrollView.pullToRefreshView, "pullToRefreshView should not be nil")
        XCTAssertTrue(scrollView.pullToRefreshView!.loading, "loading should be true")
        scrollView.stopPullToRefresh()
        XCTAssertFalse(scrollView.pullToRefreshView!.loading, "loading should be false")
    }
}
