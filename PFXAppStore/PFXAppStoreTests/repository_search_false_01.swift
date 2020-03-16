//
//  repository_search_false_01.swift
//  PFXAppStoreRepositoryTests
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

// offset is string
class repository_search_false_01: XCTestCase {
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
//        let repository: AppStoreProtocol = AppStoreStubRepository(config: .default)
        let parameterDict = ["term" : "game",
                             "media" : "software",
                             "offset" : "start",
                             "limit" : String(ConstNumbers.maxLoadLimit)]

        // when
        repository.requestSearchList(parameterDict: parameterDict)
            .subscribe(onNext: { result in
                // then
                XCTAssertFalse(true, "invalid parameter")
                expt.fulfill()

            }, onError: { error in
                XCTAssertTrue(true, error.localizedDescription)
                expt.fulfill()
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
