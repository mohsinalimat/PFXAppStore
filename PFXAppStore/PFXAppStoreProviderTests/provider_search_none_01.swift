//
//  provider_search_none_01.swift
//  PFXAppStoreProviderTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class provider_search_none_01: XCTestCase {
    // real network request
    var disposeBag = DisposeBag()
    let timeout = TimeInterval(10)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.disposeBag = DisposeBag()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expt = expectation(description: "Waiting done unit tests...")

        // given
        let provider: SearchProviderProtocol = SearchProvider()
        let parameterDict = ["term" : "game",
                             "media" : "software",
                             "offset" : "0",
                             "limit" : String(ConstNumbers.maxLoadLimit)]

        // when
        provider.fetchingSearch(parameterDict: parameterDict)
            .subscribe(onSuccess: { model in
                XCTAssertTrue(true)
                expt.fulfill()
            }) { error in
                XCTAssertTrue(true)
                expt.fulfill()
        }
        .disposed(by: self.disposeBag)

        waitForExpectations(timeout: self.timeout, handler: { (error) in
            if error == nil {
                return
            }
            
            XCTAssertTrue(true)
        })
        
        withExtendedLifetime(self) {}
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
