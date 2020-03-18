//
//  coredata_update_true_t3_1.swift
//  PFXAppStoreCoreDataTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift
import RxCoreData

class coredata_update_true_t3_1: XCTestCase {
    let timeout = TimeInterval(10)
    var disposeBag = DisposeBag()

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

        CoreDataHelper.shared.updateHistory(model: HistoryModel(text: "game", date: Date()))
        CoreDataHelper.shared.updateHistory(model: HistoryModel(text: "은행", date: Date()))
        CoreDataHelper.shared.updateHistory(model: HistoryModel(text: "3lMvTNjyoZSj2dxbo77yhGIkEjoua5fy", date: Date()))
        // true면 옛날것부터
        // false면 최근것부터
        CoreDataHelper.shared.entityHistories(isAscending: true, limit: 10)
            .subscribe(onNext: { models in
                print(models.first!.text)
                XCTAssertTrue(models.first!.text == "game")
                expt.fulfill()

            }, onError: { error in
                XCTAssertTrue(false)
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
