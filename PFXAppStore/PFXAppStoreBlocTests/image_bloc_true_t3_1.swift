//
//  image_bloc_true_t3_1.swift
//  PFXAppStoreBlocTests
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift

class image_bloc_true_t3_1: XCTestCase {
    // mock up image data
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
        let targetPath = "https://is3-ssl.mzstatic.com/image/thumb/Purple113/v4/49/7c/9c/497c9cbf-092c-9bdf-44a9-2d505ed21214/pr_source.png/392x696bb.png"
        
        let bloc = ImageBloc()
        var downloadingImageStateCount = 0
        var downloadImageStateCount = 0
        var idleImageStateCount = 0
        bloc.stateRelay
            .subscribe(onNext: { state in
                if state is DownloadingImageState {
                    downloadingImageStateCount = downloadingImageStateCount + 1
                    return
                }
                
                if state is DownloadImageState {
                    downloadImageStateCount = downloadImageStateCount + 1
                    return
                }
                
                if state is IdleImageState {
                    idleImageStateCount = idleImageStateCount + 1
                    expt.fulfill()
                    return
                }
                
                if state is ErrorImageState {
                    XCTAssertTrue(false)
                    expt.fulfill()
                    return
                }
                
                XCTAssertTrue(false)
                expt.fulfill()
            }, onError: { error in
                
            })
            .disposed(by: self.disposeBag)
        
        bloc.dispatch(event: DownloadImageEvent(targetPath: targetPath))

        waitForExpectations(timeout: self.timeout, handler: nil)
        
        XCTAssertEqual(downloadingImageStateCount, 1)
        XCTAssertEqual(downloadImageStateCount, 1)
        XCTAssertEqual(idleImageStateCount, 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
