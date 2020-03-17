//
//  search_event_false_t2_3.swift
//  PFXAppStoreEventTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class search_event_false_t2_3: XCTestCase {
    // term length is long
    var disposeBag = DisposeBag()
    let timeout = TimeInterval(10)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.clientType = .mock
        DependencyInjection.stubModel = StubModel(fileName: "event_stub", key: String(describing: type(of: self)))
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
        let parameterDict = ["term" : "3lMvTNjyoZSj2dxbo77yhGIkEjoua5fy1",
                             "media" : "software",
                             "offset" : "0",
                             "limit" : String(ConstNumbers.maxLoadLimit)]

        let event: SearchEventProtocol = FetchingSearchEvent(parameterDict: parameterDict)
        // when
        event.applyAsync()
            .subscribe(onNext: { state in
                if let errorState = state as? ErrorSearchState {
                    XCTAssertTrue(errorState.error.code == PBError.network_invalid_parameter.rawValue)
                    expt.fulfill()
                    return
                }
                
                if let _ = state as? FetchedSearchState {
                    XCTAssertTrue(false)
                    expt.fulfill()
                    return
                }
                
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
