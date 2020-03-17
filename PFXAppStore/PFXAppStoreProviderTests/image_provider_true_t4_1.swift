//
//  image_provider_true_t4_1.swift
//  PFXAppStoreProviderTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class image_provider_true_t4_1: XCTestCase {
    // request stub image data
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
        let provider: ImageProviderProtocol = ImageProvider()
        let targetPath = "https://is3-ssl.mzstatic.com/image/thumb/Purple113/v4/49/7c/9c/497c9cbf-092c-9bdf-44a9-2d505ed21214/pr_source.png/392x696bb.png"

        // when
        provider.requestImageData(targetPath: targetPath)
            .subscribe(onSuccess: { data in
                XCTAssertTrue(true)
                expt.fulfill()
            }) { error in
                XCTAssertFalse(true, error.localizedDescription)
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
