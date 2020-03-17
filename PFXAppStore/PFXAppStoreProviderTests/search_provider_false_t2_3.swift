//
//  search_provider_false_t2_3.swift
//  PFXAppStoreProviderTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class search_provider_false_t2_3: XCTestCase {
    // long term string
    var disposeBag = DisposeBag()
    let timeout = TimeInterval(10)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.clientType = .mock
        DependencyInjection.stubModel = StubModel(fileName: "provider_stub", key: String(describing: type(of: self)))
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
        let parameterDict = ["term" : "3lMvTNjyoZSj2dxbo77yhGIkEjoua5fy1",
                             "media" : "software",
                             "offset" : "0",
                             "limit" : String(ConstNumbers.maxLoadLimit)]

        // when
        provider.fetchingSearch(parameterDict: parameterDict)
            .subscribe(onSuccess: { model in
                XCTAssertTrue(false)
                expt.fulfill()
            }) { error in
                XCTAssertTrue((error as NSError).code == PBError.network_invalid_parameter.rawValue)
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
