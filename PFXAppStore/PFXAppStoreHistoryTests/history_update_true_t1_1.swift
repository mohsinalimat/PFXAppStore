//
//  history_update_true_t1_1.swift
//  PFXAppStoreHistoryTests
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift
import CoreData

class history_update_true_t1_1: XCTestCase {
    let timeout = TimeInterval(10)
    var disposeBag = DisposeBag()
    var provider: HistoryProviderProtocol = HistoryProvider()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.coreDataType = NSInMemoryStoreType
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.disposeBag = DisposeBag()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expt = expectation(description: "Waiting done unit tests...")
        self.provider.update(model: HistoryModel(text: "game", date: Date()))
            .subscribe(onCompleted: {
                XCTAssertTrue(true)
                expt.fulfill()
            }) { error in
                XCTAssertTrue(false, error.localizedDescription)
                expt.fulfill()
            }
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
