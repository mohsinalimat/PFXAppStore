//
//  repository_search_true_02.swift
//  PFXAppStoreTests
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

// korean request
class repository_search_true_02: XCTestCase {
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
        let repository = AppStoreRepository()
//        let repository: AppStoreProtocol = AppStoreStubRepository()
        let parameterDict = ["term" : "은행",
                             "media" : "software",
                             "offset" : "0",
                             "limit" : String(ConstNumbers.maxLoadLimit)]

        // when
        repository.requestSearchList(parameterDict: parameterDict)
            .subscribe(onNext: { result in
                // then
                XCTAssertTrue(result.resultCount > 0)
                expt.fulfill()

            }, onError: { error in
                expt.fulfill()
                XCTAssertFalse(true, error.localizedDescription)
            })
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: self.timeout, handler: { (error) in
            if error == nil {
                return
            }
            
            XCTFail("Fail timeout")
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
