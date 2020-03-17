//
//  search_bloc_true_t1_3.swift
//  PFXAppStoreBlocTests
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class search_bloc_true_t1_3: XCTestCase {
    // 32 length request
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
        let parameterDict = ["term" : "3lMvTNjyoZSj2dxbo77yhGIkEjoua5fy",
                             "media" : "software",
                             "offset" : "0",
                             "limit" : String(ConstNumbers.maxLoadLimit)]
        
        let bloc = SearchBloc()
        var fetchingSearchStateCount = 0
        var emptySearchStateCount = 0
        var idleSearchStateCount = 0
        bloc.stateRelay
            .subscribe(onNext: { state in
                if state is FetchingSearchState {
                    fetchingSearchStateCount = fetchingSearchStateCount + 1
                    return
                }
                
                if state is EmptySearchState {
                    emptySearchStateCount = emptySearchStateCount + 1
                    return
                }
                
                if state is IdleSearchState {
                    idleSearchStateCount = idleSearchStateCount + 1
                    expt.fulfill()
                    return
                }
                
                if state is ErrorSearchState {
                    XCTAssertTrue(false)
                    expt.fulfill()
                    return
                }
                
                XCTAssertTrue(false)
                expt.fulfill()
            }, onError: { error in
                
            })
            .disposed(by: self.disposeBag)
        
        bloc.dispatch(event: FetchingSearchEvent(parameterDict: parameterDict))

        waitForExpectations(timeout: self.timeout, handler: nil)
        
        XCTAssertEqual(fetchingSearchStateCount, 1)
        XCTAssertEqual(emptySearchStateCount, 1)
        XCTAssertEqual(idleSearchStateCount, 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
