//
//  image_event_false_t5_1.swift
//  PFXAppStoreEventTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class image_event_false_t5_1: XCTestCase {
    // invalid target path
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
        let targetPath = ""

        let event: ImageEventProtocol = DownloadImageEvent(targetPath: targetPath)
        // when
        event.applyAsync()
            .subscribe(onNext: { state in
                if state is ErrorImageState {
                    XCTAssertTrue(true)
                    expt.fulfill()
                    return
                }
                
                if let _ = state as? DownloadImageState {
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
