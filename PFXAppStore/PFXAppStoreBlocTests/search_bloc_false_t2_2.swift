//
//  search_bloc_false_t2_2.swift
//  PFXAppStoreBlocTests
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class search_bloc_false_t2_2: XCTestCase {
    // invalid response data
    var disposeBag = DisposeBag()
    let timeout = TimeInterval(1)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.clientType = .mock
        DependencyInjection.stubModel = StubModel(fileName: "bloc_stub", key: String(describing: type(of: self)))
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
        let parameterDict = ["term" : "game",
                             "media" : "software",
                             "offset" : "0",
                             "limit" : String(ConstNumbers.maxLoadLimit)]
        
        let bloc = SearchBloc()
        var fetchingSearchStateCount = 0
        var errorSearchStateCount = 0
        var idleSearchStateCount = 0
        bloc.stateRelay
            .subscribe(onNext: { state in
                if state is FetchingSearchState {
                    fetchingSearchStateCount = fetchingSearchStateCount + 1
                    return
                }
                
                if state is FetchedSearchState {
                    XCTAssertTrue(false)
                    expt.fulfill()
                    return
                }
                
                if state is IdleSearchState {
                    idleSearchStateCount = idleSearchStateCount + 1
                    expt.fulfill()
                    return
                }
                
                if state is ErrorSearchState {
                    errorSearchStateCount = errorSearchStateCount + 1
                    return
                }
                
                XCTAssertTrue(false)
                expt.fulfill()
            }, onError: { error in
                
            })
            .disposed(by: self.disposeBag)
        // when
        bloc.dispatch(event: FetchingSearchEvent(parameterDict: parameterDict))

        waitForExpectations(timeout: self.timeout, handler: nil)
        // then
        XCTAssertEqual(fetchingSearchStateCount, 1)
        XCTAssertEqual(errorSearchStateCount, 1)
        XCTAssertEqual(idleSearchStateCount, 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
