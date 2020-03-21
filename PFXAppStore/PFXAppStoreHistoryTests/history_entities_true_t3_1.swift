//
//  history_entities_true_t3_1.swift
//  PFXAppStoreHistoryTests
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift
import CoreData

class history_entities_true_t3_1: XCTestCase {
    let timeout = TimeInterval(10)
    var disposeBag = DisposeBag()
    var provider: HistoryProviderProtocol = HistoryProvider()
    var historyBloc = HistoryBloc()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.coreDataType = NSInMemoryStoreType
        // 비동기라... 임시 데이터 넣어야 함...
        self.historyBloc.dispatch(event: UpdateHistoryEvent(historyModel: HistoryModel(text: "game", date: Date())))
        self.historyBloc.dispatch(event: UpdateHistoryEvent(historyModel: HistoryModel(text: "은행", date: Date())))
        self.historyBloc.dispatch(event: UpdateHistoryEvent(historyModel: HistoryModel(text: "3lMvTNjyoZSj2dxbo77yhGIkEjoua5fy", date: Date())))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.disposeBag = DisposeBag()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expt = expectation(description: "Waiting done unit tests...")

        self.provider.recent(isAscending: true, limit: ConstNumbers.maxRecentHistoryCount)
            .subscribe(onSuccess: { models in
                XCTAssertTrue(models.first!.text == "game")
                expt.fulfill()
            }, onError: { error in
                XCTAssertTrue(false, error.localizedDescription)
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
